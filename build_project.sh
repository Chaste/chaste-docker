#!/bin/sh

set -e

echo "Building and testing project: $1"

if [ $# -lt 1 ]; then
    echo "Please pass the name of the project"
    exit 1
fi

NCORES=${2:-2}

if [ $# -eq 3 ] && [ "$3" == "c" ]; then
    cmake /usr/chaste/src  # Only run if new files have been created
fi
make -j$NCORES $1
ctest -V -R $1
