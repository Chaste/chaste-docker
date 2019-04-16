#!/bin/bash
set -e

TEST_SUITE=${1:-"Continuous"}
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

echo "Building and running $TEST_SUITE tests..."
echo "Test outputs will be written to: $CHASTE_TEST_OUTPUT"


if [ "$CMAKE_FLAG" = "c" ]; then
    # Only run if new files have been created
    cmake -H$CHASTE_SOURCE_DIR \
          -B$CHASTE_BUILD_DIR
          # -DCMAKE_BUILD_TYPE:STRING=Release \
          # -DChaste_ERROR_ON_WARNING:BOOL=OFF \
          # -DChaste_UPDATE_PROVENANCE:BOOL=OFF \
else
    echo "Skipping cmake. If the tests fail to build, try rerunning with:"
    echo "`basename "$0"` $TEST_SUITE c"
fi
make --no-print-directory -j$NCORES -C $CHASTE_BUILD_DIR $TEST_SUITE
( cd $CHASTE_BUILD_DIR && ctest -j$NCORES -L $TEST_SUITE )
