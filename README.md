Chaster
=======

*Dockerfiles for Chaste*

Quickstart
----------

To build and launch a contianer with a specific chaste version run: 

```build_images.sh [VERSION] [REPO_TAG] [NCORES]```

e.g.:

* For the latest release: `build_images.sh`
* Master branch: `build_images.sh master master 4`
* Older release: `build_images.sh 3.4`


Installing and running Chaste
-----------------------------

Install Docker and increase the number of CPUs as you would like, and amount of RAM to around or above 4GB.

*N.B. If you don't increase the amount of available RAM from the default 2GB then compilation will fail with strange errors!*

## Build the docker container with the chaste dependencies

`docker build -t chaste:dependencies .`

## Run the container

`docker run -it -v $(pwd):/usr/chaste chaste:dependencies`

TODO
----

Test GitHub build: docker build https://github.com/docker/rootfs.git#container:docker
Setup Travis-CI
Consider naming system e.g.:
* `dependencies/chaste` or `chaste/dependencies:latest`
* `release/chaste:3.4` or `chaste/release:3.4`

Creating your own Chaste build
------------------------------

## Clone and build the Chaste code

Before running make, set the following options in ccmake:
* Change CMAKE_BUILD_TYPE from Debug to Release
* Chaste_ERROR_ON_WARNING OFF
* Chaste_UPDATE_PROVENANCE OFF
Use `-D <var>:<type>=<value>`
The number after `-j` is the number of cores to use.

```
git clone -b develop https://chaste.cs.ox.ac.uk/git/chaste.git src
cd build
cmake -DCMAKE_BUILD_TYPE:STRING=Release -DChaste_ERROR_ON_WARNING:BOOL=OFF -DChaste_UPDATE_PROVENANCE:BOOL=OFF /usr/chaste/src
make -j4
```

* This can be achieved by changing to the `build` directory and running the script: `build_chaste.sh`


## [Optional] Build and run the Continuous Test pack

https://chaste.cs.ox.ac.uk/trac/wiki/ChasteGuides/CmakeFirstRun
```
make -j4 Continuous
ctest -j4 -L Continuous
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


