#!/bin/sh
set -e

VERSION=${1:-master}
GIT_REMOTE=${2:-https://github.com/Chaste/Chaste.git}
#               https://chaste.cs.ox.ac.uk/git/chaste.git
NCORES=${3:-$(nproc)}
CHASTE_DIR=/home/chaste
SOURCE_DIR=${4:-$CHASTE_DIR/src}
BUILD_DIR=${5:-$CHASTE_DIR/lib}

if [ $VERSION != '-' ]; then
    echo "Cloning Chaste from $GIT_REMOTE#$VERSION into $SOURCE_DIR..."
    mkdir -p $SOURCE_DIR
    git clone -b $VERSION $GIT_REMOTE $SOURCE_DIR
fi

echo "Building Chaste $VERSION in $BUILD_DIR with $NCORES cores..."
cmake -DCMAKE_BUILD_TYPE:STRING=Release \
      -DChaste_ERROR_ON_WARNING:BOOL=OFF \
      -DChaste_UPDATE_PROVENANCE:BOOL=OFF \
      -H$SOURCE_DIR \
      -B$BUILD_DIR && \
make -j $NCORES -C $BUILD_DIR # -f $BUILD_DIR/Makefile
echo "Done!"
echo "New projects may be initialised with the provided script new_project.sh"
