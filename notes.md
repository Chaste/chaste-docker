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