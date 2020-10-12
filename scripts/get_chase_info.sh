#!/bin/bash
set -e

if [ -z "$CHASTE_DIR" ]; then
    export CHASTE_DIR="/home/chaste"
fi
if [ -z "$CHASTE_BUILD_DIR" ]; then
    export CHASTE_BUILD_DIR="${CHASTE_DIR}/lib"
fi

( cd $CHASTE_BUILD_DIR && ctest --verbose -R TestChasteBuildInfo$ )
