Chaster
=======

*Dockerfiles for Chaste*

[![Chaste logo](https://chaste.cs.ox.ac.uk/logos/chaste-266x60.jpg "Chaste")](http://www.cs.ox.ac.uk/chaste/)
[![Docker logo](https://www.docker.com/sites/default/files/horizontal.png)](https://docs.docker.com/)

[![Build Status](https://travis-ci.org/bdevans/chaste-docker.svg?branch=master)](https://travis-ci.org/bdevans/chaste-docker)
[![Docker Pulls](https://img.shields.io/docker/pulls/bdevans/chaste-docker.svg)](https://hub.docker.com/r/bdevans/chaste-docker/)

[Docker](https://docs.docker.com/) is a lightweight virtualisation technology allowing applications with all of their dependencies to be quickly and easily run in a platform-independent manner. This project provides an image containing [Chaste](http://www.cs.ox.ac.uk/chaste/) (and some additional scripts for convenience) which can be launched with a single command, to provide a portable, homogeneous computational environment (across several operating systems and countless hardware configurations) for the simulation of cancer, heart and soft tissue.

<a href="https://docs.docker.com/"><img src="https://www.docker.com/sites/default/files/Container%402x.png" alt="Docker schematic" align="middle" width="402px"/></a>

*Docker container schematic*

*N.B. Docker containers are ephemeral by design and no changes will be saved after exiting (except to files in volumes or folders mounted from the host). The contents of the container's home directory (including the Chaste source code and binaries) are stored in a Docker [`volume`](https://docs.docker.com/storage/volumes/). If you reset Docker, the data stored in the `chaste_data` volume will be lost, so be sure to regularly push your projects to a remote git repository!*

Quickstart
----------

### Prerequisites
Install [Docker](https://www.docker.com/community-edition#/download) and configure it to have at least 4GB of RAM and as many cores as you have (more than four cores will need more RAM). On [Linux](https://docs.docker.com/install/#docker-ce) all available RAM and processing cores are shared by default.
If you use [macOS](https://docs.docker.com/docker-for-mac/install/) you may need to [configure the preferences](https://docs.docker.com/docker-for-mac/#preferences) to increase the available RAM and share any additional areas of the hard disk.
For [Windows](https://docs.docker.com/docker-for-windows/install/#download-docker-for-windows) you may be prompted to install Hyper-V, in which case do so. Next [configure the preferences](https://docs.docker.com/docker-for-windows/#docker-settings) to increase RAM and select which local drives should be available to containers (e.g. the `C:` drive). On Windows, it is also recommended that you [install git](https://www.atlassian.com/git/tutorials/install-git#windows) for tracking changes in your projects and to enable you to build the Docker image directly from GitHub if required. It is recommend to [use PowerShell on Windows](https://docs.microsoft.com/en-us/powershell/scripting/setup/installing-windows-powershell) as a more powerful alternative to the Command Prompt. Optionally, PowerShell can be further customised with the modules [`posh-docker`](https://docs.docker.com/docker-for-windows/#set-up-tab-completion-in-powershell) and [`posh-git`](https://git-scm.com/book/uz/v2/Appendix-A%3A-Git-in-Other-Environments-Git-in-Powershell) which enable tab completion for docker and git commands respectively.

*N.B. If you don't increase the amount of available RAM from the default 2GB then compilation will fail with strange errors!*

### Users
If you're a Chaste user and want to get up and running with the latest release fully compiled and ready to go, after installing and configuring Docker simply run:
```
docker run -it --rm -v chaste_data:/home/chaste bdevans/chaste-docker:2017.1
```
This should present you with a bash prompt within an isolated Docker container with all the dependencies and pre-compiled code you need to start building your own Chaste projects. If you don't already have a project, just use the provided script `new_project.sh` to create a project template in `~/projects` as a starting point. Many tutorials for projects can be found here: https://chaste.cs.ox.ac.uk/trac/wiki/UserTutorials.

Once you have a project ready to build, use the script `build_project.sh <TestMyProject> c` (replacing `<TestMyProject>` with the name of your project) and you will find the output in `~/testoutput` (the `c` argument is only necessary when new files are created). If you wish to mount your `projects` and `testoutput` directories from the host to make them more easily accessible (recommended), see the instructions and accompanying table on bind-mounting them [below](#mounting-host-directories).

### Developers
If you're a Chaste developer and want to build your own image with a particular code branch, make sure you have Docker up and running then read on!

1. Build the Chaste image:
    1. From the latest commit on Chaste's GitHub `develop` branch:
        ```
        docker build -t chaste --build-arg TAG=develop https://github.com/bdevans/chaste-docker.git
        ```
    2. Alternatively a specific branch or tag may be specified through the argument `--build-arg TAG=<branch/tag>` (with the same tag appended onto the docker image name for clarity) e.g.:
        ```
        docker build -t chaste:2017.1 --build-arg TAG=2017.1 https://github.com/bdevans/chaste-docker.git
        ```
    3. Finally, if you want a bare container ready for you to clone and compile your own Chaste code, run this command omitting the `--build-arg TAG=<branch/tag>` (or explicitly using `--build-arg TAG=-` argument which will skip building Chaste):
        ```
        docker build -t chaste https://github.com/bdevans/chaste-docker.git
        ```
        (When the container is running you may then edit `build_chaste.sh` in the `scripts` directory to configure the process with your own options before executing it.)

2. Launch the container:
    ```
    docker run -it --rm -v chaste_data:/home/chaste chaste
    ```
    (Or run `docker run -it --rm -v chaste_data:/home/chaste chaste:2017` if you tagged your image name as above.)
    The first time will take a little longer than usual as the volume has to be populated with data. For information on accessing the contents of this volume, see [below](#accessing-volume-data).

Once the container has successfully launched, you should see a command prompt a bit like this:

```
chaste@301291afbedf:~$
```

In here you can build and test your projects without interfering with the rest of your system. You may also find it useful to open another terminal and run `docker stats` so you can see system resource usage for your running containers. When you are finished with the container, simply type `exit` to close it.

Container directory structure
-----------------------------

Once launched, the container will launch in the `chaste` user's home directory at `/home/chaste` with the following structure:

```bash
.
|-- lib
|-- projects -> /home/chaste/src/projects
|-- scripts
|-- src
`-- testoutput
```

These folders contain the following types of data:

- `lib`: precompiled Chaste binaries and libraries
- `projects`: a symlink to `/home/chaste/src/projects` for user projects
- `scripts`: convenience scripts for creating, building and testing projects
- `src`: the Chaste source code
- `testoutput`: the output folder for the project testing framework (set with `$CHASTE_TEST_OUTPUT`)

Any changes made in the home folder (`/home/chaste`) will persist between restarting containers as it is designated as a `VOLUME`. Additionally, specific folders may be mounted over any of these subfolders, for example, to gain access to the test outputs for visualising in ParaView or for mounting a different version of the Chaste source code.

Mounting host directories
-------------------------

Any host directory (specified with an absolute path) may be mounted in the container as e.g. the `projects` directory and another for the `testoutput`. Navigate to the folder on the host which contains these directories e.g. `C:\Users\$USERNAME\chaste` (Windows) or `~/chaste` (Linux/macOS). The next command depends upon which OS (and shell) you are using:

| Operating System         | Command                                                       |
| ------------------------ | ------------------------------------------------------------- |
| Linux & macOS (*nix)     | `docker run -it --rm -v chaste_data:/home/chaste -v $(pwd)/projects:/home/chaste/projects -v $(pwd)/testoutput:/home/chaste/testoutput chaste` |
| Windows (PowerShell [[2]](#FN2)) | `docker run -it --rm -v chaste_data:/home/chaste -v ${PWD}/projects:/home/chaste/projects -v ${PWD}/testoutput:/home/chaste/testoutput chaste` |
| Windows (Command Prompt) | `docker run -it --rm -v chaste_data:/home/chaste -v %cd%/projects:/home/chaste/projects -v %cd%/testoutput:/home/chaste/testoutput chaste`     |

Accessing volume data
---------------------

This image is set up to store the Chaste source code (along with compiled libraries and scripts) in a [Docker volume](https://docs.docker.com/storage/volumes/) as this is the [recommended mechanism](https://docs.docker.com/storage/) for data persistence and yields the best File I/O performance across multiple platforms.

[![Docker mount options](https://docs.docker.com/storage/images/types-of-mounts-volume.png)](https://docs.docker.com/storage/)

*Docker mount options*

One drawback of this type of mount is that the contents are more difficult to access from the host. While most users will not need direct access to the contents of the volume, it can be convenient for searching and editing the Chaste source files with your favourite code editor. Some possible solutions are provided below.

### Within the container
To edit the Chaste code (in `~/src`), nano is installed in the image for convenience when small tweaks need to be made, along with `git` for pushing the changes.

### From the host
On a Linux host, the `chaste_data` volume contents may be directly accessed at `/var/lib/docker/volumes/chaste_data/_data`. A symlink can me made for easier access in the present working directory:
```
ln -s /var/lib/docker/volumes/chaste_data/_data chaste_data
```

The situation is less straightforward for Windows and macOS [[1]](#FN1) hosts due to the intermediary Linux virtual machine (Moby based on Alpine Linux) in which images, containers and volumes are stored.

1. For more extensive editing, files may be copied out of the volume, edited on the host, then copied back in with [`docker cp`](https://docs.docker.com/engine/reference/commandline/cp/). For example use the following commands to copy the whole folder, where the container has been labelled `chaste` with the `docker run` argument `--name chaste`:
    ```
    docker cp chaste:/home/chaste/src .
    < Make changes to the source files here >
    docker cp src/. chaste:/home/chaste/src
    ```

2. For more sustained Chaste development, you may wish to use another [bind mount](https://docs.docker.com/storage/bind-mounts/) to overlay the volume's `~/src` folder with a host directory containing the Chaste source code e.g. `-v /path/to/chaste_code:/home/chaste/src`. Chaste may then need to be recompiled within the container with `build_chaste.sh <branch/tag>` or if you already have the code in the mounted host folder, cloning can be skipped before recompiling with `build_chaste.sh .`. This will make the same source files easily accessible on both the host and within the Docker container, avoiding the need to copy files back and forth. This may result in slower I/O than when stored in a Docker volume, however this problem may be ameliorated on [macOS](https://docs.docker.com/storage/bind-mounts/#configure-mount-consistency-for-macos) with the [`delegated` option](https://docs.docker.com/docker-for-mac/osxfs-caching/#examples) e.g. `--mount type=bind,source="$(pwd)"/chaste_code,destination=/home/chaste/src,consistency=delegated`.

3. Alternatively, use the utility `docker-sync`: http://docker-sync.io/. This works on OSX, Windows, Linux (where it maps on to a native mount) and FreeBSD.

Troubleshooting
---------------

Firstly, make sure you have given Docker at least 4GB RAM, especially if you compiling Chaste from source.

If you get a message beginning: `Unexpected end of /proc/mounts line ...`, this can be safely ignored!

If you ran a container before and explicitly gave it a name (e.g. using `--name chaste` as an argument to `docker run`) but it now refuses to launch with an error message like below, it's because you need to remove the existing (stopped) container before one can be recreated with the same name.

```
docker: Error response from daemon: Conflict. The container name "/chaste" is already in use by container "1711bce2674e399b6084c6d452857377f6ed4dd8ee3aa19460de00fac7b86bc7". You have to remove (or rename) that container to be able to reuse that name.
```

To remove the container, simply run the following command then rerun the `docker run ...` command to launch the container (N.B. This will not delete the data stored in the `chaste_data` volume):

```
docker rm chaste
```

N.B. You can find out the names of existing containers (and their status) with the command: `docker ps -a`.

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

For more general troubleshooting, opening a terminal and running `docker events` then launching the container in another terminal will provide logging information of the events happening behind the scenes.

Testing
-------

To check Chaste compiled correctly you may wish to [run the continuous test pack](https://chaste.cs.ox.ac.uk/trac/wiki/ChasteGuides/CmakeFirstRun#Testingstep):
```
ctest -j$(nproc) -L Continuous
```
The script `test.sh` (in `/home/chaste/scripts`) is provided in the users's path for convenience.

Software
--------

If you want to use a package which is not installed within the image, you can install it with the command:

```
sudo apt-get update && sudo apt-get install <PackageName>
```
Replacing `<PackageName>` as appropriate. Enter the password: `chaste` when prompted to do so.

Note that packages installed this way will not persist after the container is shut-down and relaunched (because the relevant files are not stored in `/home/chaste`). If there is a package you think would be a particularly useful permanent addition to the Docker image, then email your suggestion to me or submit a pull request.

Notes
-----

- <a name=FN1>[1]</a>: On macOS the Linux virtual machine which hosts the containers can be inspected with the command:
```
screen ~/Library/Containers/com.docker.docker/Data/com.docker.driver.amd64-linux/tty
```
- <a name=FN2>[2]</a>: If you are using PowerShell, you can enable tab completion by installing the PowerShell module [`posh-docker`](https://docs.docker.com/docker-for-windows/#set-up-tab-completion-in-powershell). Similarly, for tab completion of git commands in PowerShell, install [`posh-git`](https://git-scm.com/book/uz/v2/Appendix-A%3A-Git-in-Other-Environments-Git-in-Powershell).

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

TODO
----

* Make cmake build options flexible for developers vs. users.
* Modify scripts to [parse arguments flexibly](https://sookocheff.com/post/bash/parsing-bash-script-arguments-with-shopts/)
* Add help (-h) option to all scripts.
* Add commands to run.sh to [launch a second terminal](https://stackoverflow.com/questions/7910211/is-there-a-way-to-open-a-series-of-new-terminal-window-and-run-commands-in-a-si) with `docker stats`:
* [Dockerfile best practices](https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices/)
* Use [multi-stage builds](https://docs.docker.com/engine/userguide/eng-image/multistage-build/) for building apps.
* Use [tmpfs mounts](https://docs.docker.com/storage/tmpfs/#use-a-tmpfs-mount-in-a-container) to store temporary data in RAM for extra speed.
