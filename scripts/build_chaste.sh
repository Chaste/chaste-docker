#!/bin/sh
set -e

VERSION=${1:-main}
GIT_REMOTE=${2:-https://github.com/Chaste/Chaste.git}
NCORES=${3:-$(nproc)}

if [ $VERSION = '-' ]; then
    echo "Skipping build!"
    exit 0
fi

if [ $VERSION != '.' ]; then
    echo "Cloning Chaste from ${GIT_REMOTE}#${VERSION} into ${CHASTE_SOURCE_DIR}..."
    mkdir -p $CHASTE_SOURCE_DIR
    git clone --recursive -b $VERSION $GIT_REMOTE $CHASTE_SOURCE_DIR
fi

echo "Building Chaste $VERSION in $CHASTE_BUILD_DIR with $NCORES cores..."
if [ $VERSION = 'main' ] || [ $VERSION = 'release' ]; then
    cmake -DCMAKE_BUILD_TYPE:STRING=Release \
          -DChaste_ERROR_ON_WARNING:BOOL=OFF \
          -DChaste_UPDATE_PROVENANCE:BOOL=ON \
          -H$CHASTE_SOURCE_DIR \
          -B$CHASTE_BUILD_DIR
else # if [ $VERSION = 'develop' ]; then
    cmake -DCMAKE_BUILD_TYPE:STRING=Debug \
          -DChaste_ERROR_ON_WARNING:BOOL=ON \
          -DChaste_UPDATE_PROVENANCE:BOOL=OFF \
          -H$CHASTE_SOURCE_DIR \
          -B$CHASTE_BUILD_DIR
fi

make --no-print-directory -j$NCORES -C $CHASTE_BUILD_DIR # -f $CHASTE_BUILD_DIR/Makefile
echo "Done!"
echo "New projects may be initialised with the provided script new_project.sh"
