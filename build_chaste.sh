#!/bin/sh
set -e

VERSION=${1:-master}
NCORES=${2:-2}
CHASTE_DIR=/home/chaste
SOURCE_DIR=${3:-$CHASTE_DIR/src}
BUILD_DIR=${4:-$CHASTE_DIR/lib}
GIT_REMOTE=${5:-https://github.com/Chaste/Chaste.git}
#               https://chaste.cs.ox.ac.uk/git/chaste.git


if [ $# -ge 2 ]; then
    git clone -b $VERSION $GIT_REMOTE $SOURCE_DIR
fi
cmake -DCMAKE_BUILD_TYPE:STRING=Release \
      -DChaste_ERROR_ON_WARNING:BOOL=OFF \
      -DChaste_UPDATE_PROVENANCE:BOOL=OFF \
      -B$BUILD_DIR \
      -H$SOURCE_DIR && \
make -j $NCORES -C $BUILD_DIR # -f $BUILD_DIR/Makefile
