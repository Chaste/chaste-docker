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
#     cmake -DCMAKE_BUILD_TYPE:STRING=Release \
#           -DChaste_ERROR_ON_WARNING:BOOL=OFF \
#           -DChaste_UPDATE_PROVENANCE:BOOL=ON \
#           -H$CHASTE_SOURCE_DIR \
#           -B$CHASTE_BUILD_DIR
    if [ "$CMAKE_BUILD_TYPE" != "Release" ] || [ "$Chaste_ERROR_ON_WARNING" != "OFF" ]; then
        echo "WARNING: Chaste ${VERSION} branch should be built with Release and ERROR_ON_WARNING=OFF."
        echo "The environment variables are currently set as: "
        echo "CMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}"
        echo "Chaste_ERROR_ON_WARNING=${Chaste_ERROR_ON_WARNING}"
    fi
else # if [ $VERSION = 'develop' ]; then
#     cmake -DCMAKE_BUILD_TYPE:STRING=Debug \
#           -DChaste_ERROR_ON_WARNING:BOOL=ON \
#           -DChaste_UPDATE_PROVENANCE:BOOL=OFF \
#           -H$CHASTE_SOURCE_DIR \
#           -B$CHASTE_BUILD_DIR
        echo "WARNING: Chaste ${VERSION} branch should be built with Debug and ERROR_ON_WARNING=ON."
        echo "The environment variables are currently set as: "
        echo "CMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}"
        echo "Chaste_ERROR_ON_WARNING=${Chaste_ERROR_ON_WARNING}"
fi

# Only run if new files have been created
cmake -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE} \
        -DChaste_ERROR_ON_WARNING:BOOL=${Chaste_ERROR_ON_WARNING} \
        -DChaste_UPDATE_PROVENANCE:BOOL=${Chaste_UPDATE_PROVENANCE} \
        -H$CHASTE_SOURCE_DIR \
        -B$CHASTE_BUILD_DIR

make --no-print-directory -j$NCORES -C $CHASTE_BUILD_DIR # -f $CHASTE_BUILD_DIR/Makefile

# Save the build info
get_chaste_info.sh > "${CHASTE_TEST_OUTPUT}/chaste-info.txt"

echo "Done!"
echo "New projects may be initialised with the provided script new_project.sh"
