#!/bin/sh
docker run -it -v chaste_data:/home/chaste -v "$(pwd)":/home/chaste/projects chaste
