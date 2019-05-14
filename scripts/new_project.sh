#!/bin/bash

# See: https://chaste.cs.ox.ac.uk/trac/wiki/ChasteGuides/UserProjects
if [ -z "$CHASTE_DIR" ]; then
    export CHASTE_DIR="/home/chaste"
fi
if [ -z "$CHASTE_SOURCE_DIR" ]; then
    export CHASTE_SOURCE_DIR="${CHASTE_DIR}/src"
fi
if [ -z "$CHASTE_PROJECTS_DIR" ]; then
    export CHASTE_PROJECTS_DIR="${CHASTE_SOURCE_DIR}/projects"
fi
REPO=${1:-template_project}
git clone https://github.com/Chaste/template_project.git ${CHASTE_PROJECTS_DIR}/${REPO}
python ${CHASTE_PROJECTS_DIR}/${REPO}/setup_project.py
