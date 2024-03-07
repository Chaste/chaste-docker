Benchmarking
============

docker-volume
-------------

```
docker run -it --rm --name chaste -v chaste_data:/home/chaste bdevans/chaste-docker:2017.1
test.sh
```

docker-bind
-----------

```
docker run -it --rm --name chaste -v $(pwd)/chaste:/home/chaste bdevans/chaste-docker:2017.1
build_chaste.sh
test.sh
```

Benchmarks
----------

Running the continuous test pack (`test.sh`):

| OS                  | src in Volume | src on host | Difference |
| ------------------- | ------------: | ----------: | :--------- |
| Linux [[1]](#BM1)   |               |             |            |
| macOS [[2]](#BM2)   |               |             |            |
| Windows [[3]](#BM3) |    19m21.260s |   6m48.780s | -64.8%     |

- <a name=BM1>[1]</a>: Ubuntu 18.04 LTS;
- <a name=BM2>[2]</a>: macOS 10.13.5; Intel i7 @ 3.1GHz; 8GB (of 16GB) RAM. Docker: 18.03.1-ce-mac65 (24312)
- <a name=BM3>[3]</a>: Windows 10; Intel i7 6700 CPU @ 3.40GHz; 8GB (of 64GB) RAM. Docker: 18.03.1-ce-win65 (17513)

Collect system information
--------------------------

e.g.
`Windows 10; Intel i7 6700 CPU @ 3.40GHz; 8GB (of 64GB) RAM. Docker: 18.03.1-ce-win65 (17513)`

```python
from os import environ, system
from time import time
from statistics import mean, stdev

cmake_times = []
make_core_times = []
make_mesh_times = []
test_mesh_times = []

num_cores = '-j3'
num_runs = 5

for i in range(num_runs):

    # Reset environment
    environ['CC'] = ""
    environ['CXX'] = ""
    environ['PETSC_DIR'] = ""
    environ['PETSC_ARCH'] = ""

    # Reset build directory
    system('rm CMakeCache.txt')
    system('make clean')

    # Time configuration
    start = time()
    system('cmake ..')
    cmake_times.append(time() - start)

    # Time building libraries
    start = time()
    system('make %s chaste_core' % num_cores)
    make_core_times.append(time() - start)

    # Time building tests
    start = time()
    system('make %s mesh' % num_cores)
    make_mesh_times.append(time() - start)

    # Time running tests
    start = time()
    system('ctest %s -L mesh -E Parallel' % num_cores)
    test_mesh_times.append(time() - start)


with open('times.csv', 'w') as f:
    f.write(',mean,std\n')
    f.write('configure,%s,%s\n' % (mean(cmake_times), stdev(cmake_times)))
    f.write('build_libs,%s,%s\n' % (mean(make_core_times), stdev(make_core_times)))
    f.write('build_tests,%s,%s\n' % (mean(make_mesh_times), stdev(make_mesh_times)))
    f.write('run_tests,%s,%s\n' % (mean(test_mesh_times), stdev(test_mesh_times)))
```
