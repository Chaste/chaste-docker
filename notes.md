Building Multi-architecture Images
==================================

1. Install the emulators
`docker run --privileged --rm tonistiigi/binfmt --install all`

2. Create a new buildx environment
`docker buildx create --name multiarch --driver docker-container --bootstrap --use`

NOTE: It may be necessary to uninstall incorrectly registered emulators e.g. `docker run --privileged --rm tonistiigi/binfmt --uninstall qemu-x86_64` before reinstalling them. 

References
----------

1. https://docs.docker.com/build/building/multi-platform/
2. https://github.com/docker/buildx/issues/464

TODO <!-- omit in toc -->
----

* [ ] Add a layer for automatically building statically linked binaries for small containers or to be copied out and run natively
* [ ] Add [`.vscode` and `.devcontainer`](https://github.com/microsoft/vscode-remote-try-cpp) (for `launch.json`, [`devcontainer.json`](https://code.visualstudio.com/docs/remote/containers), etc.) to [automatically configure VS Code](https://code.visualstudio.com/docs/remote/containers-advanced).
* [ ] Modify scripts to [parse arguments flexibly](https://sookocheff.com/post/bash/parsing-bash-script-arguments-with-shopts/)
* [ ] Add help (-h) option to all scripts.
* [ ] Add commands to run.sh to [launch a second terminal](https://stackoverflow.com/questions/7910211/is-there-a-way-to-open-a-series-of-new-terminal-window-and-run-commands-in-a-si) with `docker stats`:
* [ ] [Dockerfile best practices](https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices/)
* [ ] Use [tmpfs mounts](https://docs.docker.com/storage/tmpfs/#use-a-tmpfs-mount-in-a-container) to store temporary data in RAM for extra speed on Linux.
* [ ] Add support for singularity #4
* [ ] Automate `base` and `release` builds on [Docker Hub](https://docs.docker.com/docker-hub/builds/advanced/) and/or [GitHub Actions](https://github.com/marketplace/actions/build-and-push-docker-images) or [GitHub Packages](https://docs.github.com/en/free-pro-team@latest/packages/getting-started-with-github-container-registry).
* [ ] [![Build Status](https://travis-ci.org/Chaste/chaste-docker.svg?branch=master)](https://travis-ci.org/Chaste/chaste-docker) Migrate Travis-CI from .org to .com
* [x] Use [multi-stage builds](https://docs.docker.com/engine/userguide/eng-image/multistage-build/) for building apps.
* [x] Split into base and release images
* [x] Make cmake build options flexible for developers vs. users.