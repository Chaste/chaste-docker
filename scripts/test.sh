#!/bin/bash
set -e

TEST_SUITE=${1:-"Continuous"}
CMAKE_FLAG=${2:-"n"}
NCORES=${3:-$(nproc)}

if [ $TEST_SUITE = '-' ]; then
    echo "Skipping tests!"
    exit 0
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
