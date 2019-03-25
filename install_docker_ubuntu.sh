#!/bin/sh
# Script to install Docker on Ubuntu
# https://docs.docker.com/install/linux/docker-ce/ubuntu/

sudo apt-get remove docker docker-engine docker.io
sudo apt-get update
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

sudo apt-get update
sudo apt-get install docker-ce

# Verify installation
# sudo docker run hello-world

# https://docs.docker.com/install/linux/linux-postinstall/
# Add docker group to run without sudo
sudo groupadd docker
sudo usermod -aG docker $USER

# Verify installation
docker run hello-world
