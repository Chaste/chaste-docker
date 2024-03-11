#!/bin/bash
set -e

( cd $CHASTE_BUILD_DIR && ctest --verbose -R TestChasteBuildInfo$ )
