#!/bin/bash

# See: https://chaste.cs.ox.ac.uk/trac/wiki/ChasteGuides/UserProjects
REPO=${1:-new_project}
# git clone https://github.com/Chaste/template_project.git ${CHASTE_PROJECTS_DIR}/${REPO}
( cd ${CHASTE_PROJECTS_DIR} && gh repo create ${REPO} --public --clone --template https://github.com/Chaste/template_project.git )
python ${CHASTE_PROJECTS_DIR}/${REPO}/setup_project.py
