Chaster
=======

*Dockerfiles for Chaste*

Quickstart
----------

### Prerequisites
Install [Docker](https://www.docker.com) and configure it to have at least 4GB of RAM and as many cores as you have. For [Windows](https://docs.docker.com/docker-for-windows/install/#download-docker-for-windows) you may be prompted to install Hyper-V, in which case do so. Also select which local drives to be available to containers (e.g. the `C:` drive in Windows).

*N.B. If you don't increase the amount of available RAM from the default 2GB then compilation will fail with strange errors!*

### Users
If you're a user and want to get up and running with the latest release fully compiled and ready to go, after installing and configuring Docker simply run:
```
docker run -it -v chaste_data:/home/chaste bdevans/chaste-docker:2017.1
```
This should present you with a bash prompt within an isolated Docker container with all the dependencies and pre-compiled code you need to start building your own Chaste projects. If you don't already have a project, just use the provided script `new_project.sh` to create a project template in `~/projects` as a starting point. Many tutorials for projects can be found here: https://chaste.cs.ox.ac.uk/trac/wiki/UserTutorials. Once you have a project ready to build, use the script `build_project.sh <TestMyProject>` (replacing `<TestMyProject>` with the name of your project) and you will find the output in `~/testoutput`.

### Developers
If you're a developer and want to build your own image with a particular code branch, make sure you have Docker up and running then read on!

1. Build the Chaste image from the latest commit with the following command:
```
docker build -t chaste --build-arg TAG=develop https://github.com/bdevans/chaste-docker.git
```
This will build from Chaste's GitHub `develop` branch.
Alternatively a specific branch or tag may be specified by adding the argument `--build-arg TAG=<branch/tag>` (with the same tag appended onto the docker image name) e.g.:
```
docker build -t chaste:2017.1 --build-arg TAG=2017.1 https://github.com/bdevans/chaste-docker.git
```
Finally, if you want a bare container ready for you to clone and compile your own Chaste code, run this command omitting the `--build-arg TAG=<branch/tag>` (or explicitly using `--build-arg TAG=-` argument which will skip building Chaste):
```
docker build -t chaste https://github.com/bdevans/chaste-docker.git
```
(When the container is running you may then edit `build_chaste.sh` in the `scripts` directory to configure the process with your own options.)

2. Launch the container:
```
docker run -it -v chaste_data:/home/chaste chaste
```
Or run `docker run -it -v chaste_data:/home/chaste chaste:2017` if you tagged your image name as above.
The first time will take a little longer than usual as the volume has to be populated with data.

On Linux hosts, the contents of the volume `chaste_data` may be accessed at `/var/lib/docker/volumes/chaste_data/_data`. On Windows and macOS, it is not so straight-forward and easiest to mount additional directories for data you wish to access easily.
Any host directory (specified with an absolute path) may be mounted in the container as e.g. the `projects` directory and another for the `testoutput`:
```
docker run -it -v chaste_data:/home/chaste -v $(pwd)/projects:/home/chaste/src/projects -v $(pwd)/testoutput:/home/chaste/testoutput chaste
```

3. [Optional] Run the continuous test pack to check Chaste compiled correctly (https://chaste.cs.ox.ac.uk/trac/wiki/ChasteGuides/CmakeFirstRun):
```
ctest -j$(nproc) -L Continuous
```
The script `test.sh` is provided in the users's path for convenience.

*N.B. Docker containers are ephemeral by design and no changes will be saved after exiting except to files in the home directory which is where the host's present working directory is mounted. If you reset Docker, the data stored in the `chaste_data` volume will be lost, so be sure to regularly push your projects to a remote git repository!*

Notes
-----

§ If you are using PowerShell, you can enable tab completion by installing the PowerShell module `posh-docker`: https://docs.docker.com/docker-for-windows/#set-up-tab-completion-in-powershell


TODO
----

* Make cmake build options flexible for devs vs users.
* Add help (-h) option to all scripts.
* Modify scripts to parse arguments flexibly.
* Add commands to run.sh to launch a second terminal with `docker stats`: https://stackoverflow.com/questions/7910211/is-there-a-way-to-open-a-series-of-new-terminal-window-and-run-commands-in-a-si
* Setup Travis-CI and add badge to repo
* GitHub/Chaste release > build and tag image e.g. chaste:2017.1 > push image to Docker Cloud
* Consider naming system e.g.:
  - `dependencies/chaste` or `chaste/dependencies:latest`
  - `release/chaste:3.4` or `chaste/release:3.4`
* Link GitHub to DockerHub and push images automatically: https://docs.docker.com/docker-hub/github/
* Dockerfile best practices: https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices/
* Use multi-stage builds? https://docs.docker.com/engine/userguide/eng-image/multistage-build/
