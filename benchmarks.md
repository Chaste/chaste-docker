Benchmarks
----------

Running the continuous test pack (`test.sh`):

| OS                  | src in Volume | src on host | Difference |
| ------------------- | -------------:| -----------:|:---------- |
| Linux [[1]](#BM1)   |               |             |            |
| macOS [[2]](#BM2)   |               |             |            |
| Windows [[3]](#BM3) | 19m21.260s    | 6m48.780s   | -64.8%     |

- <a name=BM1>[1]</a>: Ubuntu 18.04 LTS;
- <a name=BM2>[2]</a>: macOS 10.13.5; Intel i7 @ 3.1GHz; 8GB (of 16GB) RAM. Docker: 18.03.1-ce-mac65 (24312)
- <a name=BM3>[3]</a>: Windows 10; Intel i7 6700 CPU @ 3.40GHz; 8GB (of 64GB) RAM. Docker: 18.03.1-ce-win65 (17513)