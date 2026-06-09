#!/bin/bash
set -e

cmake -H$CHASTE_SOURCE_DIR -B$CHASTE_BUILD_DIR
make --no-print-directory -j$(nproc) -C $CHASTE_BUILD_DIR $TEST_SUITE
#-j$(nproc)
( cd $CHASTE_BUILD_DIR && ctest --verbose -R TestChasteBuildInfo$ )
