# docker run -it -v $(pwd):/usr/chaste chaste:dependencies

#FROM phusion/baseimage:latest
# https://github.com/tianon/docker-brew-ubuntu-core/blob/1637ff264a1654f77807ce53522eff7f6a57b773/xenial/Dockerfile
FROM ubuntu:xenial
# > yakkety > zesty > artful
MAINTAINER Chaste Developers <chaste-admin@maillist.ox.ac.uk>

USER root
ENV DEBIAN_FRONTEND noninteractive

# libcurl3-gnutls
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    apt-utils \
    apt-transport-https \
    ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install the Chaste repo list and key
# https://chaste.cs.ox.ac.uk/trac/wiki/InstallGuides/UbuntuPackage
RUN echo "deb http://www.cs.ox.ac.uk/chaste/ubuntu xenial/" >> /etc/apt/sources.list
RUN apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 422C4D99

# https://chaste.cs.ox.ac.uk/trac/wiki/InstallGuides/DependencyVersions
# Install the chaste source metapackage for its dependencies
# chaste-source
# Version: 3.4.93224.rea10412117df767b9f0bc0f88fa1cc5aaef9d160
#Depends: cmake | scons, g++, libopenmpi-dev, petsc-dev (>= 3.0), libhdf5-openmpi-dev, xsdcxx, libboost-serialization-dev, libboost-filesystem-dev, libboost-program-options-dev, libparmetis-dev, libmetis-dev, libxerces-c-dev, libsundials-serial-dev, libvtk6-dev | libvtk5-dev, python-lxml, python-amara, python-rdflib, libproj-dev
#Recommends: valgrind, libfltk1.1, hdf5-tools, cmake-curses-gui
#Suggests: libgoogle-perftools-dev, doxygen, graphviz, eclipse-cdt, gnuplot, paraview

# Install mencoder and mplayer for creating animation movies
RUN apt-get update && \
    apt-get install -y \
    chaste-source \
    sudo \
    git \
    wget \
    python-dev \
    python-pip \
    libboost-all-dev \
    openjdk-8-jdk \
    libvtk5.10 \
    libvtk5.10-qt4 \
    python-vtk \
    libvtk-java \
    libparmetis-dev \
    libhdf5-openmpi-dev \
    mencoder \
    mplayer && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# TODO: Check this is necessary
RUN pip install --upgrade pip
RUN sudo pip install texttest
ENV TEXTTEST_HOME /usr/chaste/texttest

# See https://github.com/phusion/baseimage-docker/issues/186
#RUN touch /etc/service/syslog-forwarder/down

# The entrypoint script below will ensure our new chaste user (for doing builds)
# has the same userid as the host user owning the source code volume, to avoid
# permission issues.
# Based on https://denibertovic.com/posts/handling-permissions-with-docker-volumes/
#COPY entrypoint.sh /usr/local/bin/entrypoint.sh

# Create working directory for Chaste files
RUN useradd -ms /bin/bash chaste
#RUN usermod -aG sudo chaste

RUN mkdir /usr/chaste

#USER chaste

WORKDIR /usr/chaste
RUN mkdir -p /usr/chaste/build

COPY build_chaste.sh /usr/chaste/build/build_chaste.sh
COPY build_project.sh /usr/chaste/build/build_project.sh

RUN mkdir -p /usr/chaste/output
ENV CHASTE_TEST_OUTPUT /usr/chaste/output

# Hook to link to host chaste source folder, and set it as the working dir
# New method for automatically mounting volumes
# N.B. Changing the volume from within the Dockerfile: If any build steps change the data within the volume after it has been declared, those changes will be discarded.
#VOLUME /usr/chaste

#RUN chown chaste:chaste -R /usr/chaste
#USER chaste

# Use baseimage-docker's init system, and switch to the chaste user running
# bash as a login shell by default (see entrypoint.sh).
# If no specific command is given the default CMD will drop us into an
# interactive shell.
#ENTRYPOINT ["/sbin/my_init", "--quiet", "--", "/usr/local/bin/entrypoint.sh"]
#CMD ["/bin/bash -i"]
CMD ["bash"]
