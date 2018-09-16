#!/bin/bash

# See: https://chaste.cs.ox.ac.uk/trac/wiki/ChasteGuides/UserProjects

PROJECTS_DIR=/home/chaste/src/projects
REPO=${1:-template_project}
git clone https://github.com/Chaste/template_project.git $PROJECTS_DIR/$REPO
python $PROJECTS_DIR/$REPO/setup_project.py
