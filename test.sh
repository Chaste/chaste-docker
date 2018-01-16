#!/bin/sh
set -e

ctest -j"$(nproc)" -L Continuous
