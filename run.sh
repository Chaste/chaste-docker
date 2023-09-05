#!/bin/sh
docker run --init -it --rm -v chaste_data:/home/chaste -v "${PWD}":/home/chaste/projects chaste
