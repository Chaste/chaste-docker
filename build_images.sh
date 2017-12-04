#!/bin/bash

VER=${1:-3.4.93221}
REPO_TAG=${2:-release_$VER}
NCORES=${3:-4}
docker build -t chaste:dependencies .

#for each Dockerfile...
# Automatically attach volume?
docker build -t chaste:$VER --build-arg TAG=$REPO_TAG \
                            --build-arg NCORES=$NCORES \
                            -f Dockerfile_Release .

# TODO: Push to docker hub

docker run -it -v $(pwd):/usr/chaste/src/projects chaste:$VER
