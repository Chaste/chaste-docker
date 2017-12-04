#!/bin/bash

VER=${1:-3.4.93221}
BRANCH=release_$VER
NCORES=${2:-4}
docker build -t chaste:dependencies .

#for each Dockerfile...
# Automatically attach volume?
docker build -t chaste:$VER --build-arg TAG=$BRANCH \
                            --build-arg NCORES=$NCORES \
                            -f Dockerfile_Release .

# TODO: Push to docker hub

docker run -it -v $(pwd):/usr/chaste/src/projects chaste:$VER
