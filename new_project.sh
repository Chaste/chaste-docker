#!/bin/bash

# See: https://chaste.cs.ox.ac.uk/trac/wiki/ChasteGuides/UserProjects

REPO=${1:-/usr/chaste/src/projects/template_project}
git clone https://github.com/Chaste/template_project.git $REPO
python $REPO/setup_project.py
