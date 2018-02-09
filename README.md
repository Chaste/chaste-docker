Chaster
=======

[![Chaste logo](https://chaste.cs.ox.ac.uk/logos/chaste-266x60.jpg "Chaste")](http://www.cs.ox.ac.uk/chaste/)

*Dockerfiles for Chaste*

[![Build Status](https://travis-ci.org/bdevans/chaste-docker.svg?branch=master)](https://travis-ci.org/bdevans/chaste-docker)
[![Docker Pulls](https://img.shields.io/docker/pulls/bdevans/chaste-docker.svg)](https://hub.docker.com/r/bdevans/chaste-docker/)

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

1. Build the Chaste image from the latest commit on Chaste's GitHub `develop` branch with the following command:
```
docker build -t chaste --build-arg TAG=develop https://github.com/bdevans/chaste-docker.git
```
Alternatively a specific branch or tag may be specified through the argument `--build-arg TAG=<branch/tag>` (with the same tag appended onto the docker image name for clarity) e.g.:
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

On Linux hosts, the contents of the volume `chaste_data` may be accessed at `/var/lib/docker/volumes/chaste_data/_data`. On Windows and macOS<sup>[[1]](#FN1)</sup>, it is not so straight-forward and easiest to mount additional directories for data you wish to access easily.
Any host directory (specified with an absolute path) may be mounted in the container as e.g. the `projects` directory and another for the `testoutput`. Navigate to the folder on the host which contains these directories e.g. `C:\Users\$USERNAME\chaste` (Windows) or `~/chaste` (Linux/macOS). The next command depends upon which OS (and shell) you are using:

| Operating System         | Command                                                     |
| ------------------------ | ----------------------------------------------------------- |
| Linux & macOS (*nix)     | `docker run -it -v chaste_data:/home/chaste -v $(pwd)/projects:/home/chaste/projects -v $(pwd)/testoutput:/home/chaste/testoutput chaste` |
| Windows (PowerShell<sup>[[2]](#FN2)</sup>) | `docker run -it -v chaste_data:/home/chaste -v ${PWD}/projects:/home/chaste/projects -v ${PWD}/testoutput:/home/chaste/testoutput chaste` |
| Windows (Command Prompt) | `docker run -it -v chaste_data:/home/chaste -v %cd%/projects:/home/chaste/projects -v %cd%/testoutput:/home/chaste/testoutput chaste`   |

3. [Optional] Run the continuous test pack to check Chaste compiled correctly (https://chaste.cs.ox.ac.uk/trac/wiki/ChasteGuides/CmakeFirstRun):
```
ctest -j$(nproc) -L Continuous
```
The script `test.sh` is provided in the users's path for convenience.

*N.B. Docker containers are ephemeral by design and no changes will be saved after exiting except to files in the home directory which is where the host's present working directory is mounted. If you reset Docker, the data stored in the `chaste_data` volume will be lost, so be sure to regularly push your projects to a remote git repository!*


Troubleshooting
---------------

Firstly, make sure you have given Docker at least 4GB RAM, especially if you compiling Chaste from source.

If building the image from scratch, occasionally problems can occur if a dependency fails to download and install correctly. If such an issue occurs, try resetting your Docker environment (i.e. remove all containers, images and their intermediate layers) with the following command:

```
docker system prune -a
```

This will give you a clean slate from which to restart the building process described above.

If you have deleted or otherwise corrupted the persistent data in the `chaste_data` volume, the command can be used with the `--volumes` flag. Warning - this will completely reset any changes to data in the image home directory along with any other Docker images on your system (except where other host folders have been bind-mounted). Commit and push any changes made to the Chaste source code or projects and save any important test outputs before running the command with this flag. If you are unsure, do not use this flag - instead list the volumes on your system with `docker volume ls` and then use the following command to delete a specific volume once you are happy that no important data remains within it:

```
docker volume rm <volume_name>
```

For more information on cleaning up Docker, see [this tutorial](https://www.digitalocean.com/community/tutorials/how-to-remove-docker-images-containers-and-volumes).


Notes
-----

<a name=FN1>[1]</a>: On macOS the Linux virtual machine which hosts the containers can be inspected with:
```
screen ~/Library/Containers/com.docker.docker/Data/com.docker.driver.amd64-linux/tty
```

<a name=FN2>[2]</a>: If you are using PowerShell, you can enable tab completion by installing the PowerShell module `posh-docker`: https://docs.docker.com/docker-for-windows/#set-up-tab-completion-in-powershell


TODO
----

* Make cmake build options flexible for devs vs users.
* Modify scripts to [parse arguments flexibly](https://sookocheff.com/post/bash/parsing-bash-script-arguments-with-shopts/)
* Add help (-h) option to all scripts.
* Add commands to run.sh to [launch a second terminal](https://stackoverflow.com/questions/7910211/is-there-a-way-to-open-a-series-of-new-terminal-window-and-run-commands-in-a-si) with `docker stats`:
* [Dockerfile best practices](https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices/)
* Use [multi-stage builds](https://docs.docker.com/engine/userguide/eng-image/multistage-build/)?
