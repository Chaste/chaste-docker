Chaster
=======

*Dockerfiles for Chaste*

Quickstart
----------

1. Build the Chaste image with the following command:
```
docker build -t chaste https://github.com/bdevans/chaste-docker.git#volume
```
This will build from Chaste's GitHub `master` branch by default.
Optionally an alternative branch or tag may be specified by adding the argument `--build-arg TAG=<branch or tag>` e.g.:
```
docker build -t chaste --build-arg TAG=2017.1 https://github.com/bdevans/chaste-docker.git#volume
```

3. Launch the container:
```
docker run -it -v chaste_data:/home/chaste chaste
```
The first time will take a little longer than usual as the volume has to be populated with data.

On Linux hosts, the contents of the volume `chaste_data` may be accessed at `/var/lib/docker/volumes/chaste_data/_data`. On Windows and macOS, it is not so straight-forward and easiest to mount additional directories for data you wish to access easily.
Any host directory (specified with an absolute path) may be mounted in the container as e.g. the `projects` directory and another for the `testoutput`:
```
docker run -it -v chaste_data:/home/chaste -v $(pwd)/projects:/home/chaste/src/projects -v $(pwd)/testoutput:/home/chaste/testoutput chaste
```

4. [Optional] Run the continuous test pack to check Chaste compiled correctly (https://chaste.cs.ox.ac.uk/trac/wiki/ChasteGuides/CmakeFirstRun):
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

`ccmake /home/chaste`

Create new “Test” header files for simulations in the projects folder then run:
```
cd ~/lib
cmake ~/src
make -j4 TestProject && ctest -V -R TestProject
```

* This can be achieved by changing to the `build` directory and running the script: `build_project.sh`


TODO
----
* Stop this creating a new volume on each run of a container!
* Add user to sudo and set password
* Add help (-h) option to all scripts.
* Modify scripts to parse arguments flexibly.
* Add commands to run.sh to launch a second terminal with `docker stats`: https://stackoverflow.com/questions/7910211/is-there-a-way-to-open-a-series-of-new-terminal-window-and-run-commands-in-a-si
* Test GitHub build: docker build https://github.com/docker/rootfs.git#container:docker
* Setup Travis-CI
* Consider naming system e.g.:
  - `dependencies/chaste` or `chaste/dependencies:latest`
  - `release/chaste:3.4` or `chaste/release:3.4`
* Link GitHub to DockerHub and push images automatically: https://docs.docker.com/docker-hub/github/
* Dockerfile best practices: https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices/

Notes
-----

Create a volume for data persistence:
```
docker volume create chaste_data
```
This will be stored in `/var/lib/docker/volumes/` on Linux. On macOS this can be inspected with: `screen ~/Library/Containers/com.docker.docker/Data/com.docker.driver.amd64-linux/tty`
