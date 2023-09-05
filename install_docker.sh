#!/bin/sh
# Script to install Docker on Linux
# https://docs.docker.com/engine/install/

curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

echo ""
echo "You may now wish to follow the post-installation steps for Linux:"
echo "https://docs.docker.com/engine/install/linux-postinstall/"
echo "These will enable you to run Docker without sudo, and to start Docker on boot."
echo ""
