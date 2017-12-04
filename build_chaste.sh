#!/bin/sh

set -e

# Must be run in the build directory e.g. /usr/chaste/build/

NCORES=${1:-2}
VERSION=${2:-'master'}
SRC_DIR=${3:-/usr/chaste/src}
if [ $# -ge 2 ]; then
    git clone -b $VERSION https://chaste.cs.ox.ac.uk/git/chaste.git $SRC_DIR
fi
cmake /usr/chaste/src
make -j $NCORES
