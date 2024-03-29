#!/bin/sh

# This script can be used to set all environment variables to their default values e.g.
# $ source /home/chaste/scripts/set_env_vars.sh

set -e

if [ -z "$NCORES" ]; then
    NCORES=$(nproc)
    export NCORES
fi
echo "Number of cores allocated: $NCORES"

if [ -z "$CHASTE_DIR" ]; then
    export CHASTE_DIR="/home/chaste"
fi
echo "Chaste directory: $CHASTE_DIR"

if [ -z "$CHASTE_SOURCE_DIR" ]; then
    export CHASTE_SOURCE_DIR="${CHASTE_DIR}/src"
fi
echo "Chaste source directory: $CHASTE_SOURCE_DIR"

if [ -z "$CHASTE_BUILD_DIR" ]; then
    export CHASTE_BUILD_DIR="${CHASTE_DIR}/build"
fi
echo "Chaste build directory: $CHASTE_BUILD_DIR"

if [ -z "$CHASTE_PROJECTS_DIR" ]; then
    export CHASTE_PROJECTS_DIR="$CHASTE_SOURCE_DIR/projects"
fi
echo "Chaste projects directory: $CHASTE_PROJECTS_DIR"

if [ -z "$CHASTE_TEST_OUTPUT" ]; then
    export CHASTE_TEST_OUTPUT="${CHASTE_DIR}/output"
fi
echo "Chaste test outputs directory: $CHASTE_TEST_OUTPUT"

if [ -z "$CMAKE_BUILD_TYPE" ]; then
    export CMAKE_BUILD_TYPE="Debug"
fi
echo "CMake build type: $CMAKE_BUILD_TYPE"

if [ -z "$Chaste_ERROR_ON_WARNING" ]; then
    export Chaste_ERROR_ON_WARNING="ON"
fi
echo "CMake error on warning: $Chaste_ERROR_ON_WARNING"

if [ -z "$Chaste_UPDATE_PROVENANCE" ]; then
    export Chaste_UPDATE_PROVENANCE="OFF"
fi
echo "CMake update provenance: $Chaste_UPDATE_PROVENANCE"
