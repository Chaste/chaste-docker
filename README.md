Chaster
=======

*Dockerfiles for Chaste*

Quickstart
----------

1. Build the Chaste image with the following command:
```
docker build -t chaste/volume https://github.com/bdevans/chaste-docker.git#volume
```
This will build from the `master` branch by default. Optionally an alternative brnach or tag may be specified by adding the `--build-arg TAG=<branch or tag>` e.g.:
```
docker build -t chaste/volume --build-arg TAG=2017.1 https://github.com/bdevans/chaste-docker.git#volume
```

2. Launch the container:
```
docker run -it chaste
```
If desired, your projects directory (on the host) may be mounted in the container:
```
docker run -it -v $(pwd):/home/chaste/src/projects chaste
```

3. [Optional] Run the continuous test pack to check Chaste compiled correctly (https://chaste.cs.ox.ac.uk/trac/wiki/ChasteGuides/CmakeFirstRun):
```
ctest -j$(nproc) -L Continuous
```


## Compiling and running simulations

https://chaste.cs.ox.ac.uk/trac/wiki/ChasteGuides/UserProjects
```
git clone https://github.com/Chaste/template_project.git
cd template_project
python setup_project.py
```

* This can be done with the script: `new_project.sh`

To check that your user project compiles correctly, at the command line navigate to a build folder (outside the Chaste or project source folder - see ChasteGuides/CmakeBuildGuide) and run

`ccmake path/to/Chaste`

Create new “Test” header files for simulations in the projects folder then run:
```
cd ~/build/
cmake ~/src
make -j4 TestProject && ctest -V -R TestProject
```

* This can be achieved by changing to the `build` directory and running the script: `build_project.sh`


TODO
----

Test GitHub build: docker build https://github.com/docker/rootfs.git#container:docker
Setup Travis-CI
Consider naming system e.g.:
* `dependencies/chaste` or `chaste/dependencies:latest`
* `release/chaste:3.4` or `chaste/release:3.4`
