#!/bin/bash
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
    # Only run if new files have been created
    cmake -DCMAKE_BUILD_TYPE:STRING=Release \
          -DChaste_ERROR_ON_WARNING:BOOL=OFF \
          -DChaste_UPDATE_PROVENANCE:BOOL=OFF \
          -B$BUILD_DIR \
          -H$SRC_DIR
else
    echo "Skipping cmake. If the project fails to build, try rerunning with:"
    echo "`basename "$0"` $1 c"
fi
make -j$NCORES -C $BUILD_DIR $1 # -f $BUILD_DIR/Makefile
( cd $BUILD_DIR && ctest -V -R $1 ) # -j$NCORES
