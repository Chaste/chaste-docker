#!/bin/sh

set -e

echo "Building and testing project: $1 in build folder: $(pwd)"

if [ $# -lt 1 ]; then
    echo "Please pass the name of the project"
    exit 1
fi

CMAKE_FLAG=${2:-"n"}
NCORES=${3:-$(nproc)}
SRC_DIR=${4:-/home/chaste/src}
BUILD_DIR=${5:-/home/chaste/lib}

if [ "$CMAKE_FLAG" = "c" ]; then
    #cmake $SRC_DIR  # Only run if new files have been created
    cmake -DCMAKE_BUILD_TYPE:STRING=Release \
          -DChaste_ERROR_ON_WARNING:BOOL=OFF \
          -DChaste_UPDATE_PROVENANCE:BOOL=OFF \
          -B$BUILD_DIR \
          -H$SRC_DIR
fi
make -j$NCORES -C $BUILD_DIR $1 # -f $BUILD_DIR/Makefile
ctest -V -R $1
