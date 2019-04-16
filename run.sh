#!/bin/sh
docker run -it --rm -v chaste_data:/home/chaste -v "$(pwd)":/home/chaste/projects chaste
