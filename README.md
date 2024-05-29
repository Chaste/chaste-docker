[![Chaste logo](https://chaste.cs.ox.ac.uk/logos/chaste-266x60.jpg "Chaste")](https://chaste.github.io/)
<a href="https://docs.docker.com/"><img alt="Docker logo" src="https://www.docker.com/wp-content/uploads/2022/03/horizontal-logo-monochromatic-white.png" width="25%"></a>

[*Docker images for Chaste*](https://github.com/Chaste/chaste-docker)

[![Docker Pulls](https://img.shields.io/docker/pulls/chaste/release)](https://hub.docker.com/r/chaste/release/)
[![MIT License](https://img.shields.io/badge/license-MIT-green)](https://raw.githubusercontent.com/Chaste/chaste-docker/master/LICENSE.txt)
[![DOI](https://joss.theoj.org/papers/10.21105/joss.01848/status.svg)](https://doi.org/10.21105/joss.01848)
[![Build chaste/base](https://github.com/Chaste/chaste-docker/actions/workflows/docker-image.yml/badge.svg)](https://github.com/Chaste/chaste-docker/actions/workflows/docker-image.yml)


- [TL;DR](#tldr)
- [Introduction](#introduction)
- [Getting started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [\[Recommended\] Using a pre-built image](#recommended-using-a-pre-built-image)
  - [\[Alternative\] Use the VS Code devcontainer](#alternative-use-the-vs-code-devcontainer)
- [Container directory structure](#container-directory-structure)
- [Sharing data between the host and container](#sharing-data-between-the-host-and-container)
  - [Bind mounts](#bind-mounts)
  - [Copying data in and out](#copying-data-in-and-out)
- [Developing code within the container](#developing-code-within-the-container)
- [Installing additional software](#installing-additional-software)
- [Testing](#testing)
- [Advanced usage](#advanced-usage)
  - [Building your own image](#building-your-own-image)
  - [Writing your own Dockerfile](#writing-your-own-dockerfile)
- [Citation](#citation)
- [Troubleshooting](#troubleshooting)

## TL;DR

1. [Install Docker](https://docs.docker.com/get-docker/) and allocate it at least 4GB RAM
2. `docker run -it --init --rm -v chaste_data:/home/chaste chaste/release`
3. This is your terminal on [Chaste](https://chaste.github.io/): 
`chaste@301291afbedf:~$` 
GL HF! ;)

## Introduction
[Docker](https://docs.docker.com/) is a lightweight virtualisation technology allowing applications with all of their dependencies to be quickly and easily run in a platform-independent manner. This project provides an image containing [Chaste](http://www.cs.ox.ac.uk/chaste/) (and some additional scripts for convenience) which can be launched with a single command, to provide a portable, homogeneous computational environment (across several operating systems and countless hardware configurations) for the simulation of cancer, heart and soft tissue.

Docker lets you build and run a computational environment from a plaintext `Dockerfile`. This is analogous to compiling an executable file from source code (equivalent to using `docker build` to produce an image from a `Dockerfile`) and then executing it as a running program (akin to using `docker run` to run a container). The steps of this analogy are illustrated in the figure below from [Nüst et al. 2020](https://journals.plos.org/ploscompbiol/article?id=10.1371/journal.pcbi.1008316).

<a href="https://journals.plos.org/ploscompbiol/article?id=10.1371/journal.pcbi.1008316"><img alt="Docker analogy" src="https://raw.githubusercontent.com/nuest/ten-simple-rules-dockerfiles/master/figures/analogy.png" width="60%"></a>

*Docker container analogy*

More generally, Docker also has an image registry which stores prebuilt images: https://hub.docker.com/. Users may upload images from their own computer (with `docker push`) and download those from others (e.g. with `docker pull`) including official dockerised applications (e.g. [Python](https://hub.docker.com/_/python) and [WordPress](https://hub.docker.com/_/wordpress)) as well as base images (e.g. [Ubuntu](https://hub.docker.com/_/ubuntu) and [Alpine](https://hub.docker.com/_/alpine)) to build upon for creating your own images. The Docker architecture and wider ecosystem are illustrated [here](https://docs.docker.com/get-started/overview/#docker-architecture). 

Some slides from a workshop introducing Docker and how to use this Chaste image can be found [here](https://docs.google.com/presentation/d/1UqpN_9Jwfl-c1I9UpDGaIgm2GVSWffwk9rGkFhaq5_U/edit?usp=sharing).

Getting started
---------------

### Prerequisites
Install [Docker](https://www.docker.com/products/docker-desktop/) and configure it to have at least 4GB of RAM and as many cores as you have (more than four cores will need more RAM). 

| OS      | Instructions                                                     |
| ------- | ----------------------------------------------------------------- |
| Linux   | Install [Docker for Linux](https://docs.docker.com/desktop/install/linux-install/). All available RAM and processing cores are shared by default. |
| macOS   | 1. Install [Docker for mac](https://docs.docker.com/desktop/install/mac-install/). <br>2. [Configure the preferences](https://docs.docker.com/desktop/settings/mac/) to increase the available RAM and share any desired areas of the hard disk. |
| Windows | 0. On Windows 10 or later, install WSL2 (if not already installed) then install the latest Ubuntu "App" from the Microsoft store. This can be accomplished by [opening PowerShell as an administrator](https://ubuntu.com/tutorials/install-ubuntu-on-wsl2-on-windows-10#2-install-wsl) and running: `wsl --install -d ubuntu`. <br>1. Install [Docker for Windows](https://docs.docker.com/desktop/install/windows-install/). <br>2. [Configure the preferences](https://docs.docker.com/desktop/settings/windows/) to [enable WSL extension integration in Docker Settings](https://learn.microsoft.com/en-us/windows/wsl/tutorials/wsl-containers) (in particular for the Ubuntu App) then [increase the available RAM](https://gist.github.com/jctosta/a8942ff4f8fbf01e339a0579172cb9fe) and select which local drives should be available to containers (e.g. the `C:` drive). <br>3. Launch the Ubuntu App which will provide a shell to type commands in. You can then either run a container [using a pre-built image](#recommended-using-a-pre-built-image) or [use the VS Code devcontainer](#alternative-use-the-vs-code-devcontainer) by cloning the Chaste repository within the Ubuntu environment, then opening VS Code by typing `code .` and finally clicking "Reopen in Container" in the VS Code popup window. Keeping the files within the Ubuntu filesystem in this way will greatly improve File I/O performance. <br>4. [Optional] [Install git on the host](https://www.atlassian.com/git/tutorials/install-git#windows) for tracking changes in your projects and to enable you to build the Docker image directly from GitHub if required. Installing [`posh-git`](https://git-scm.com/book/uz/v2/Appendix-A%3A-Git-in-Other-Environments-Git-in-Powershell) enables tab completion for git commands. |

> :warning:  Allocate at least 4GB of RAM to Docker or compilation will fail with strange errors!

### [Recommended] Using a pre-built image
1. If you want to get up and running with the latest release fully compiled and ready to go, after installing and configuring Docker simply run:
    ```
    docker run --init -it --rm -v chaste_data:/home/chaste chaste/develop
    ```
    If needed, you can also specify an [available tag](https://hub.docker.com/r/chaste/release/tags) in the image name in the form `chaste/release:<tag>` to pull a particular release (e.g. `chaste/release:2024.1`) rather than defaulting to the latest version. 
2. Alternatively, if you want to use the latest development code from the `develop` branch, use this command to pull and run the latest `chaste/develop` image instead:
    ```
    docker run --init -it --rm -v chaste_data:/home/chaste chaste/develop
    ```

Once the container has successfully launched, you should see a command prompt similar to this:

```
chaste@301291afbedf:~$
```

This is a bash prompt within an isolated Docker container (based on [ubuntu](https://hub.docker.com/_/ubuntu)) with all the dependencies and pre-compiled code you need to start building your own Chaste projects. In here you can build and test your projects without interfering with the rest of your system. 

> :information_source:  To see system resource usage for your running containers, open another terminal and run `docker stats`. 

If you don't already have a project, just use the provided script `new_project.sh` to create a project template in `~/projects` as a starting point. Many tutorials for projects can be found here: https://chaste.cs.ox.ac.uk/trac/wiki/UserTutorials.

Once you have a project ready to build, use the script `build_project.sh <TestMyProject> c` (replacing `<TestMyProject>` with the name of your project) and you will find the output in `~/output` (the `c` argument is only necessary when new files are created). 

> :information_source:  To easily share data between the Docker container and the host e.g. the `output` directory, a bind-mount argument can be added to the command: `-v /host/path/to/output:/home/chaste/output`. See the instructions on [bind mounts](#bind-mounts) for further details.

When you are finished with the container, simply type `exit` or press `Ctrl+D` to close it (if necessary, pressing `Ctrl+C` first to stop any running processes). Any changes made in `/home/chaste` will persist when you relaunch a container, however if the container is deleted, everything else (e.g. installed packages, changes to system files) will be reset to how it was when the image was first used. 

### [Alternative] Use the VS Code devcontainer
If you use [VS Code](https://code.visualstudio.com/) and have installed Docker, you can simply clone the [Chaste code repository](https://github.com/Chaste/Chaste) and open it in VS Code (installing the [Remote Development extension pack](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.vscode-remote-extensionpack) if prompted to do so). Finally, when prompted by the extension, click `Reopen in Container`. This will seamlessly pull, run and mount the latest `chaste/develop` image for you. 

> :information_source:  Note, this will mount the locally cloned copy of the Chaste code into the container, overlaying the copy already included in the image. While the pre-compiled binaries are built against the image's internal copy of the code, they will be relatively up-to-date, so will not take long to recompile against changes you make to the locally cloned code, bringing them back into synchrony. 

Further details of the `devcontainer` can be found [here](https://github.com/Chaste/Chaste/tree/develop/.devcontainer). 

For more advanced use cases, see [Building your own image](#building-your-own-image) below. 

Container directory structure
-----------------------------

Once launched, the container will start in the `chaste` user's home directory at `/home/chaste` with the following structure:

```bash
.
|-- build
|-- projects -> /home/chaste/src/projects
|-- scripts
|-- src
`-- output
```

These folders contain the following types of data:

- `build`: precompiled Chaste binaries and libraries
- `projects`: a symlink to `/home/chaste/src/projects` for user projects
- `scripts`: convenience scripts for creating, building and testing projects
- `src`: the Chaste source code
- `output`: the output folder for the project testing framework (set with `$CHASTE_TEST_OUTPUT`)

Corresponding environment variables are also set as follows:
- `CHASTE_DIR="/home/chaste"`
- `CHASTE_BUILD_DIR="${CHASTE_DIR}/build"`
- `CHASTE_PROJECTS_DIR="${CHASTE_DIR}/src/projects"`
- `CHASTE_SOURCE_DIR="${CHASTE_DIR}/src"`
- `CHASTE_TEST_OUTPUT="${CHASTE_DIR}/output"`

> :information_source:  If [building your own image](#building-your-own-image), the `CHASTE_DIR` path can be changed at buildtime with a build argument e.g. `--build-arg CHASTE_DIR=/path/to/alternative` which will then set the other directories relative to that path. 

Any changes made in the home folder (`/home/chaste`) will persist between restarting containers as it is designated as a `VOLUME`. Additionally, specific folders may be mounted over any of these subfolders, for example, to gain access to the test outputs for visualising in [ParaView](https://www.paraview.org/) or for mounting a different version of the Chaste source code. In general, data should be left in a (named) volume, as file I/O performance will be best that way. However, bind mounting host directories can be convenient e.g. for access to output files and so is explained next.

> :warning:  Docker containers are ephemeral by design and no changes will be saved after exiting (except to files in volumes or folders bind-mounted from the host). The contents of the container's home directory (including the Chaste source code and binaries) are stored in a Docker [`VOLUME`](https://docs.docker.com/storage/volumes/) and so will persist between container instances. However if you reset Docker, all volumes and their contained data will be lost, so be sure to regularly push your projects to a remote git repository!

Sharing data between the host and container
-------------------------------------------

This image is set up to store the Chaste source code, compiled libraries and scripts in a [Docker volume](https://docs.docker.com/storage/volumes/) as this is the [recommended mechanism](https://docs.docker.com/storage/) for data persistence and yields the best File I/O performance across multiple platforms.

One drawback of this type of mount is that the contents are more difficult to access from the host. However, to gain direct access to e.g. the `output` of the container from the host, or share datasets on the host with the container, a bind mount can be used (even overlaying a directory within the volume if needed). 

For further details and illustrations of the Docker mount options see the [storage documentation](https://docs.docker.com/storage/).

### Bind mounts

Any host directory (specified with an absolute path e.g. `/path/to/output`) may be mounted in the container e.g. the `output` directory. Alternatively, navigate to the folder on the host which contains these directories e.g. `C:\Users\$USERNAME\chaste` (Windows) or `~/chaste` (Linux/macOS) and use `$(pwd)/output` instead as shown below. In the following examples, the image name (final argument) is assumed to be `chaste/release` rather than e.g. `chaste/develop` or `chaste/release:2024.1` for simplicity. 
```
docker run -it --init --rm -v chaste_data:/home/chaste -v "${PWD}"/output:/home/chaste/output chaste/release
```

### Copying data in and out

On macOS and Windows (but *not* Linux), reading and writing files in bind mounts from the host have a greater overhead than for files in Docker volumes. This may slow down simulations where there is a lot of File I/O in those folders (e.g. `output`), so bind mounts should be used sparingly in such scenarios. A faster alternative would be to leave the files in a volume and use [`docker cp`](https://docs.docker.com/engine/reference/commandline/cp/) to copy them out at the end of the simulation (or copy modified files back in). 

For example, use the following commands to copy the whole `src` folder, where the container has been labelled `chaste` e.g. with a command beginning: `docker run --name chaste ...`:
```bash
docker cp chaste:/home/chaste/src .  # copy out
# Make changes to the source files here
docker cp src/. chaste:/home/chaste/src  # copy in
```

Developing code within the container
------------------------------------

We recommend using [VS Code](https://code.visualstudio.com/download) with the "[Remote Development](https://code.visualstudio.com/docs/remote/remote-overview)" extension which allows the files within a container to be directly accessed, edited and searched as if they were on the host system while preserving the performance benefits of keeping the files within the volume. 

> :information_source:  These steps relate to the currently [recommended pre-built image method](#recommended-using-a-pre-built-image). If you are using the new [`devcontainer`](#alternative-use-the-vs-code-devcontainer) instructions, these steps are done automatically.

1. Start the container from a terminal with the command given
2. In VS Code select "`Remote-Containers: Attach to Running Container...`"
3. Choose the chaste-docker container (which will have a random name unless you launch it by adding `--name <name>` to the run command)
4. Open the folder `/home/chaste` with VS Code's built-in file browser and you will be able to access the files and directories described above. 

<details><summary>Alternative approaches [click to expand]</summary><p> 

1. While it is better to leave the code within the volume for better performance you may wish to use another [bind mount](https://docs.docker.com/storage/bind-mounts/) to overlay the volume's `~/src` folder with a host directory containing the Chaste source code e.g. `-v /path/to/chaste_code:/home/chaste/src`. Chaste may then need to be recompiled within the container with `build_chaste.sh <branch/tag>` or if you already have the code in the mounted host folder, cloning can be skipped before recompiling with `build_chaste.sh .`. This will make the same source files directly accessible on both the host and within the Docker container, avoiding the need to copy files back and forth or use VS Code. This may result in slower I/O than when stored in a Docker volume, however this problem may be ameliorated on [macOS](https://docs.docker.com/storage/bind-mounts/#configure-mount-consistency-for-macos) with the [`delegated` option](https://docs.docker.com/docker-for-mac/osxfs-caching/#examples) e.g. `--mount type=bind,source="$(pwd)"/chaste_code,destination=/home/chaste/src,consistency=delegated`.

2. Alternatively, use the utility `docker-sync`: http://docker-sync.io/. This works on OSX, Windows, Linux (where it maps on to a native mount) and FreeBSD.
</p></details>

> :information_source:  For small edits to the code from the terminal, `nano` is installed in the image for convenience, along with `git` for pushing the changes.

Installing additional software
------------------------------

If you want to use a package which is not installed within the image, you can install it with the command:

```
sudo apt-get update && sudo apt-get install <PackageName>
```
Replacing `<PackageName>` as appropriate. Enter the password: `chaste` when prompted to do so.

Note that packages installed this way will not persist after the container is deleted (because the relevant files are not stored in `/home/chaste`). This can be avoided by omitting the `--rm` flag from the `docker run` command and using `docker start <container_name>` to relaunch a previously used container. If there is a package you think would be a particularly useful permanent addition to the Docker image, then email your suggestion to me or submit a pull request.

Testing
-------

To check Chaste compiled correctly you may wish to [run the continuous test pack](https://chaste.cs.ox.ac.uk/trac/wiki/ChasteGuides/CmakeFirstRun#Testingstep) from the `CHASTE_BUILD_DIR` directory:
```
ctest -j$(nproc) -L Continuous
```
The script `test.sh` (in `/home/chaste/scripts`) is provided in the users's path for convenience.

The following test can be run separately to quickly check the build environment and installed dependencies available to chaste:
```
ctest --verbose -R TestChasteBuildInfo$
```
For more information on testing see: https://chaste.cs.ox.ac.uk/trac/wiki/ChasteGuides/CmakeBuildGuide. 

## Advanced usage
### Building your own image
If you're a more advanced developer and want to build your own image with a particular code branch, make sure you have Docker up and running then read on! In these examples, we tag the image `chaste:custom` for illustration but you are encouraged to give it a more descriptive name.

1. Build the Chaste image:
    1. From the latest commit on Chaste's GitHub `develop` branch:
        ```
        docker build -t chaste:custom --build-arg GIT_TAG=develop https://github.com/chaste/chaste-docker.git
        ```
    2. Alternatively a specific branch or tag may be specified through the argument `--build-arg GIT_TAG=<branch|tag>` (with the same tag appended onto the docker image name for clarity) e.g.:
        ```
        docker build -t chaste:custom --build-arg GIT_TAG=2024.1 https://github.com/chaste/chaste-docker.git
        ```
    3. Finally, if you want a bare container ready for you to clone and compile your own Chaste code, pull a `base` image with `docker pull chaste/base` (specifying an [available Ubuntu distribution](https://hub.docker.com/repository/docker/chaste/base/tags) if desired e.g. `chaste/base:focal`) Alternatively, build a fresh image by running the following command (omitting the `--build-arg GIT_TAG=<branch|tag>` argument above, or explicitly passing `--build-arg GIT_TAG=-`, which will skip compiling Chaste within the image):
        ```
        docker build -t chaste:custom https://github.com/chaste/chaste-docker.git
        ```
        (When the container is running you may then edit `build_chaste.sh` in the `scripts` directory to configure the process with your own options before executing it.)

2. Launch the container:
    ```
    docker run --init -it --rm -v chaste_data:/home/chaste chaste:custom
    ```
    The first time will take a little longer than usual as the volume has to be populated with data. For information on accessing the contents of this volume, see the section on [sharing data](#sharing-data-between-the-host-and-container).

### Writing your own Dockerfile

<img alt="Ten Simple Rules for Writing Dockerfiles for Reproducible Research - Summary" src="https://raw.githubusercontent.com/nuest/ten-simple-rules-dockerfiles/master/figures/summary.png" width="25%" align="right">

For more advanced use cases, you can also include your own software, scripts and configuration by writing your own `Dockerfile`. To inherit the base configuration with the necessary dependencies and configuration for Chaste already set up, begin your `Dockerfile` with:
```
FROM chaste/base
```
or e.g. `chaste/base:focal` to specify a particular base image other than the `latest`. 

A full guide to writing a `Dockerfile` is beyond the scope of this project, however for more information, see the Docker [documentation](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/) and [reference](https://docs.docker.com/engine/reference/builder/). There is also a handy list of Ten Simple Rules to help you get started! 

> :information_source:  Pro tip! To write your own `Dockerfile`s, see [Nüst et al. 2020](https://journals.plos.org/ploscompbiol/article?id=10.1371/journal.pcbi.1008316) for best practices. 

Citation
--------

If you found this work helpful, please cite the following publication.

Cooper et al., (2020). Chaste: Cancer, Heart and Soft Tissue Environment. Journal of Open Source Software, 5(47), 1848. https://doi.org/10.21105/joss.01848

[![DOI](https://joss.theoj.org/papers/10.21105/joss.01848/status.svg)](https://doi.org/10.21105/joss.01848)

```
@article{Chaste_2020,
    title = {Chaste: Cancer, Heart and Soft Tissue Environment},
    journal = {Journal of Open Source Software}
    publisher = {The Open Journal},
    year = {2020},
    month = {3},
    volume = {5},
    number = {47},
    pages = {1848},
    author = {Fergus R. Cooper and Ruth E. Baker and Miguel O. Bernabeu and Rafel Bordas and Louise Bowler and Alfonso Bueno-Orovio and Helen M. Byrne and Valentina Carapella and Louie Cardone-Noott and Jonathan Cooper and Sara Dutta and Benjamin D. Evans and Alexander G. Fletcher and James A. Grogan and Wenxian Guo and Daniel G. Harvey and Maurice Hendrix and David Kay and Jochen Kursawe and Philip K. Maini and Beth McMillan and Gary R. Mirams and James M. Osborne and Pras Pathmanathan and Joe M. Pitt-Francis and Martin Robinson and Blanca Rodriguez and Raymond J. Spiteri and David J. Gavaghan},
    doi = {10.21105/joss.01848},
    url = {https://doi.org/10.21105/joss.01848},
}
```

Additionally, if you found the "Ten Simple Rules ..." paper helpful for general advice or writing your own `Dockerfile`, please consider citing that too. 

Nüst D, Sochat V, Marwick B, Eglen SJ, Head T, Hirst T, and Evans, BD. (2020) Ten simple rules for writing Dockerfiles for reproducible data science. PLoS Comput Biol 16(11): e1008316. https://doi.org/10.1371/journal.pcbi.1008316

[![DOI](https://img.shields.io/badge/DOI-10.1371%2Fjournal.pcbi.1008316-yellow)](https://doi.org/10.1371/journal.pcbi.1008316)

```
@article{TSR_Dockerfiles_2020,
    title = {Ten Simple Rules for Writing Dockerfiles for Reproducible Data Science},
    journal = {PLOS Computational Biology},
    publisher = {Public Library of Science},
    year = {2020},
    month = {11},
    volume = {16},
    number = {11},
    pages = {1--24},
    author = {Daniel N{\"u}st and Vanessa Sochat and Ben Marwick and Stephen J. Eglen and Tim Head and Tony Hirst and Benjamin D. Evans},
    doi = {10.1371/journal.pcbi.1008316},
    url = {https://doi.org/10.1371/journal.pcbi.1008316},
}
```

Troubleshooting
---------------

* Firstly, make sure you have given Docker at least 4GB RAM, especially if you are compiling Chaste from source.

* If you get a message beginning: `Unexpected end of /proc/mounts line ...`, this can be safely ignored!

* If you ran a container before and explicitly gave it a name (e.g. using `--name chaste` as an argument to `docker run`) but it now refuses to launch with an error message like below, it's because you need to remove the existing (stopped) container before one can be recreated with the same name.

    ```
    docker: Error response from daemon: Conflict. The container name "/chaste" is already in use by container "1711bce2674e399b6084c6d452857377f6ed4dd8ee3aa19460de00fac7b86bc7". You have to remove (or rename) that container to be able to reuse that name.
    ```

    To remove the container, simply run the following command then rerun the `docker run ...` command to launch the container (N.B. This will *not* delete the data stored in the `chaste_data` volume but other changes made within the container will be lost e.g. installed software):

    ```
    docker rm chaste
    ```

    N.B. You can find out the names of existing containers (and their status) with the command: `docker ps -a`.

* If building the image from scratch, occasionally problems can occur if a dependency fails to download and install correctly. If such an issue occurs, try resetting your Docker environment (i.e. remove all containers, images and their intermediate layers) with the following command:
    ```
    docker system prune -a
    ```

    This will give you a clean slate from which to restart the building process described above.

* If you have deleted or otherwise corrupted the persistent data in the `chaste_data` volume, the command can be used with the `--volumes` flag. :warning:  Warning! :warning:  this will completely reset any changes to data in the image home directory along with any other Docker images on your system (except where other host folders have been bind-mounted). Commit and push any changes made to the Chaste source code or projects and save any important test outputs before running the command with this flag. If you are unsure, do not use this flag - instead list the volumes on your system with `docker volume ls` and then use the following command to delete a specific volume once you are happy that no important data remains within it:
    ```
    docker volume rm <volume_name>
    ```

    For more information on cleaning up Docker, see [this tutorial](https://www.digitalocean.com/community/tutorials/how-to-remove-docker-images-containers-and-volumes).

* For more general troubleshooting, opening a terminal and running `docker events` then launching the container in another terminal will provide logging information of the events happening behind the scenes.
