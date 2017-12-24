#!/bin/bash

REPO_TAG=${1:-2017.1}
NCORES=${2:-2}
docker build -t chaste:dependencies .

#for each Dockerfile...
# Automatically attach volume?
#docker build -t chaste:$VER --build-arg TAG=$REPO_TAG \
#                            --build-arg NCORES=$NCORES \
#                            -f Dockerfile_Release .

# TODO: Push to docker hub

#docker run -it -v $(pwd):/home/chaste chaste:$VER "./build_chaste.sh $REPO_TAG $NCORES"
docker run -it -v $(pwd):/home/chaste chaste:dependencies "./build_chaste.sh $REPO_TAG $NCORES"
