# docker run -it -v chaste_data:/usr/chaste chaste

# https://github.com/tianon/docker-brew-ubuntu-core/blob/1637ff264a1654f77807ce53522eff7f6a57b773/xenial/Dockerfile
FROM ubuntu:xenial
LABEL maintainer "Chaste Developers <chaste-admin@maillist.ox.ac.uk>"

USER root
ARG DEBIAN_FRONTEND noninteractive

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

RUN apt-get update && \
    apt-get install -y \
    chaste-source \
    sudo \
    git \
    nano \
    wget \
    python-dev \
    python-pip \
    python-vtk \
    libvtk5.10 \
    libvtk5.10-qt4 \
    libvtk-java \
    openjdk-8-jdk \
    mencoder \
    mplayer \
    valgrind \
    libfltk1.1 \
    hdf5-tools \
    cmake-curses-gui \
    libgoogle-perftools-dev \
    doxygen \
    graphviz \
    gnuplot && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Remove Chaste tar from chaste-source (only used for dependencies)
RUN rm /usr/src/chaste-source.tar.bz2

# Install TextTest for regression testing. TODO: Check this is necessary
# This requires pygtk
RUN pip install --upgrade pip
RUN sudo pip install texttest
#ENV TEXTTEST_HOME /usr/local/bin/texttest

# Create working directory for Chaste files
#RUN useradd -ms /bin/bash chaste
#RUN usermod -aG sudo chaste
#RUN passwd chaste
RUN useradd chaste && echo "chaste:chaste" | chpasswd && adduser chaste sudo

USER chaste

COPY build_chaste.sh /home/chaste/scripts/
COPY build_project.sh /home/chaste/scripts/
COPY new_project.sh /home/chaste/scripts/
COPY test.sh /home/chaste/scripts/

ENV PATH="/home/chaste/scripts:${PATH}"

WORKDIR /home/chaste

RUN mkdir -p /home/chaste/lib
#RUN mkdir -p /home/chaste/output
ENV CHASTE_TEST_OUTPUT /home/chaste/testoutput
#RUN ln -s /home/chaste/src/testoutput testoutput
RUN ln -s /home/chaste/src/projects projects

ARG TAG=master
ENV BRANCH=$TAG
RUN build_chaste.sh $BRANCH

# Hook to link to host chaste source folder, and set it as the working dir
# New method for automatically mounting volumes
# N.B. Changing the volume from within the Dockerfile: If any build steps change the data within the volume after it has been declared, those changes will be discarded.
VOLUME /home/chaste

# Use baseimage-docker's init system, and switch to the chaste user running
# bash as a login shell by default (see entrypoint.sh).
# If no specific command is given the default CMD will drop us into an
# interactive shell.
#ENTRYPOINT ["/sbin/my_init", "--quiet", "--", "/usr/local/bin/entrypoint.sh"]
#CMD ["/bin/bash -i"]
CMD ["bash"]
