#!/bin/bash
set -e

if [ $# -lt 1 ]; then
    echo "Please pass the name of the project!"
    exit 1
else
    PROJECT=$1
fi

#TODO: Set developer options for cmake
CMAKE_FLAG=${2:-"n"}
NCORES=${3:-$(nproc)}
if [ -z "$CHASTE_DIR" ]; then
    export CHASTE_DIR="/home/chaste"
fi
if [ -z "$CHASTE_SOURCE_DIR" ]; then
    export CHASTE_SOURCE_DIR="${CHASTE_DIR}/src"
fi
if [ -z "$CHASTE_BUILD_DIR" ]; then
    export CHASTE_BUILD_DIR="${CHASTE_DIR}/lib"
fi
if [ -z "$CHASTE_TEST_OUTPUT" ]; then
    export CHASTE_TEST_OUTPUT="${CHASTE_DIR}/testoutput"
fi

echo "Building and testing project: ${PROJECT}..."
if [[ -n CHASTE_TEST_OUTPUT ]]; then
    echo "Test outputs will be written to: ${CHASTE_TEST_OUTPUT}"
fi

if [ "$CMAKE_FLAG" = "c" ]; then
    if [ -z "$CMAKE_BUILD_TYPE" ]; then
        export CMAKE_BUILD_TYPE="Release"
    fi
    if [ -z "$Chaste_ERROR_ON_WARNING" ]; then
        export Chaste_ERROR_ON_WARNING="OFF"
    fi
        if [ -z "$Chaste_UPDATE_PROVENANCE" ]; then
        export Chaste_UPDATE_PROVENANCE="OFF"
    fi
    # Only run if new files have been created
    cmake -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE} \
          -DChaste_ERROR_ON_WARNING:BOOL=${Chaste_ERROR_ON_WARNING} \
          -DChaste_UPDATE_PROVENANCE:BOOL=${Chaste_UPDATE_PROVENANCE} \
          -H$CHASTE_SOURCE_DIR \
          -B$CHASTE_BUILD_DIR
else
    echo "Skipping cmake. If the project fails to build, try rerunning with:"
    echo "`basename "$0"` $PROJECT c"
fi
make --no-print-directory -j$NCORES -C $CHASTE_BUILD_DIR $PROJECT # -f $CHASTE_BUILD_DIR/Makefile
( cd $CHASTE_BUILD_DIR && ctest -V -R $PROJECT ) # -j$NCORES
