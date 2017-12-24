#!/bin/sh
set -e

CHASTE_DIR=/home/chaste
SOURCE_DIR=${3:-$CHASTE_DIR/src}

NCORES=${1:-2}
VERSION=${2:-'master'}

if [ $# -ge 2 ]; then
    git clone -b $VERSION https://chaste.cs.ox.ac.uk/git/chaste.git $SRC_DIR
fi
cmake $SRC_DIR
make -j $NCORES -C $BUILD_DIR # -f $BUILD_DIR/Makefile
