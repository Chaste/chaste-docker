#!/bin/bash
set -e

TEST_SUITE=${1:-"Continuous"}
CMAKE_FLAG=${2:-"n"}
NCORES=${3:-$(nproc)}
SOURCE_DIR=${4:-/home/chaste/src}
BUILD_DIR=${5:-/home/chaste/lib}

echo "Building and running $TEST_SUITE tests..."
if [ ! -z "$CHASTE_TEST_OUTPUT" ]; then
    echo "Test outputs will be written to: $CHASTE_TEST_OUTPUT"
fi

if [ "$CMAKE_FLAG" = "c" ]; then
    # Only run if new files have been created
    cmake -H$SOURCE_DIR \
          -B$BUILD_DIR
          # -DCMAKE_BUILD_TYPE:STRING=Release \
          # -DChaste_ERROR_ON_WARNING:BOOL=OFF \
          # -DChaste_UPDATE_PROVENANCE:BOOL=OFF \
else
    echo "Skipping cmake. If the tests fail to build, try rerunning with:"
    echo "`basename "$0"` $TEST_SUITE c"
fi
make --no-print-directory -j$NCORES -C $BUILD_DIR $TEST_SUITE
( cd $BUILD_DIR && ctest -j$NCORES -L $TEST_SUITE )
