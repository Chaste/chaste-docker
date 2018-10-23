# docker run -it -v chaste_data:/usr/chaste chaste

# https://github.com/tianon/docker-brew-ubuntu-core/blob/404d80486fada09bff68a210b7eddf78f3235156/bionic/Dockerfile
FROM ubuntu:bionic
LABEL maintainer="Ben Evans <ben.d.evans@gmail.com>"
# Written by Benjamin D. Evans

USER root
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    apt-utils \
    apt-transport-https \
    ca-certificates \
    gnupg && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install the Chaste repo list and key
# https://chaste.cs.ox.ac.uk/trac/wiki/InstallGuides/UbuntuPackage
RUN echo "deb http://www.cs.ox.ac.uk/chaste/ubuntu bionic/" >> /etc/apt/sources.list.d/chaste.list
RUN apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 422C4D99

# https://chaste.cs.ox.ac.uk/trac/wiki/InstallGuides/DependencyVersions
# Package: chaste-dependencies
# Version: 2018.04.18
# Depends: cmake | scons, g++, libopenmpi-dev, petsc-dev, libhdf5-openmpi-dev, xsdcxx, libboost-serialization-dev, libboost-filesystem-dev, libboost-program-options-dev, libparmetis-dev, libmetis-dev, libxerces-c-dev, libsundials-dev | libsundials-serial-dev, libvtk7-dev | libvtk6-dev | libvtk5-dev, python-lxml, python-amara, python-rdflib, libproj-dev
# Recommends: git, valgrind, libpetsc3.7.7-dbg | libpetsc3.7.6-dbg | libpetsc3.6.4-dbg | libpetsc3.6.2-dbg | libpetsc3.4.2-dbg, libfltk1.1, hdf5-tools, cmake-curses-gui
# Suggests: libgoogle-perftools-dev, doxygen, graphviz, eclipse-cdt, eclipse-egit, libsvn-java, subversion, git-svn, gnuplot, paraview

RUN apt-get update && \
    apt-get install -y \
    chaste-dependencies \
    sudo \
    git \
    nano \
    wget \
    python-dev \
    python-pip \
    python-vtk6 \
    #python3-vtk7 \
    #libvtk7.1 \
    #libvtk7-dev \
    #libvtk7.1-qt4 \
    libvtk6-dev \
    libvtk6.3-qt \
    #libvtk-java \
    openjdk-11-jdk \
    #libboost-serialization1.62-dev \
    #libboost-filesystem1.62-dev \
    #libboost-program-options1.62-dev \
    libpetsc3.7.7-dbg \
    mencoder \
    mplayer \
    valgrind \
    libfltk1.3 \
    hdf5-tools \
    cmake-curses-gui \
    libgoogle-perftools-dev \
    doxygen \
    graphviz \
    gnuplot && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Fix the CMake warnings
RUN update-alternatives --install /usr/bin/vtk vtk /usr/bin/vtk6 10
# RUN ln -s /usr/bin/vtk6 /usr/bin/vtk
RUN ln -s /usr/lib/python2.7/dist-packages/vtk/libvtkRenderingPythonTkWidgets.x86_64-linux-gnu.so /usr/lib/x86_64-linux-gnu/libvtkRenderingPythonTkWidgets.so

# Install TextTest for regression testing (this requires pygtk)
RUN pip install --upgrade pip
RUN pip install texttest
ENV TEXTTEST_HOME /usr/local/bin/texttest

# Create user and working directory for Chaste files
RUN useradd -ms /bin/bash chaste && echo "chaste:chaste" | chpasswd && adduser chaste sudo
USER chaste
WORKDIR /home/chaste

# Add scripts
#COPY --chown=chaste:chaste scripts /home/chaste/scripts
COPY scripts /home/chaste/scripts
USER root
RUN chown -R chaste:chaste scripts
USER chaste
ENV PATH="/home/chaste/scripts:${PATH}"

# Create Chaste build, projects and output folders
RUN mkdir -p /home/chaste/lib
ENV CHASTE_TEST_OUTPUT /home/chaste/testoutput
RUN ln -s /home/chaste/src/projects projects

# Build Chaste ('-' skips by default)
ARG TAG=-
ENV BRANCH=$TAG
RUN build_chaste.sh $BRANCH

# Automatically mount the home directory in a volume to persist changes made there
# N.B. If any build steps change the data within the volume after it has been declared, those changes will be discarded.
VOLUME /home/chaste

CMD ["bash"]
