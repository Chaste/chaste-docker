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

if [ "$CMAKE_FLAG" = "c" ]; then
    cmake $SRC_DIR  # Only run if new files have been created
fi
make -j$NCORES $1
ctest -V -R $1
