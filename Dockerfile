# docker build -t chaste .
# docker build --target base -t chaste/base .
# docker run -it --rm -v chaste_data:/home/chaste chaste

ARG BASE=eoan
FROM ubuntu:${BASE} AS base
LABEL maintainer="Ben Evans <ben.d.evans@gmail.com>"
# Written by Benjamin D. Evans

USER root
ARG DEBIAN_FRONTEND=noninteractive
# Declare BASE in this build stage (the value is inherited from the global stage)
# https://github.com/moby/moby/issues/34482
ARG BASE

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    apt-utils \
    apt-transport-https \
    ca-certificates \
    gnupg

# Install the Chaste repo list and key
# https://chaste.cs.ox.ac.uk/trac/wiki/InstallGuides/UbuntuPackage
RUN echo "deb http://www.cs.ox.ac.uk/chaste/ubuntu ${BASE}/" >> /etc/apt/sources.list.d/chaste.list
RUN apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 422C4D99

# https://chaste.cs.ox.ac.uk/trac/wiki/InstallGuides/DependencyVersions
# Package: chaste-dependencies
# Version: 2019.10.31
# Architecture: all
# Depends: cmake | scons, g++, libopenmpi-dev, petsc-dev, libhdf5-openmpi-dev, xsdcxx, libboost-serialization-dev, libboost-filesystem-dev, libboost-program-options-dev, libparmetis-dev, libmetis-dev, libxerces-c-dev, libsundials-dev | libsundials-serial-dev, libvtk7-dev | libvtk6-dev | libvtk5-dev, python-lxml, python-amara, python-rdflib, libproj-dev
# Recommends: git, valgrind, libpetsc-real3.11-dbg | libpetsc-real3.10-dbg | libpetsc-real3.9-dbg | libpetsc3.7.7-dbg | libpetsc3.6.2-dbg, libfltk1.1, hdf5-tools, cmake-curses-gui
# Suggests: libgoogle-perftools-dev, doxygen, graphviz, eclipse-cdt, eclipse-egit, libsvn-java, subversion, git-svn, gnuplot, paraview

# CMake (cmake) 3.13.4-1build1
# GCC (g++) g++: 9.2.1-9ubuntu2
# PETSc (libpetsc-real3.11-dbg) 3.11.3+dfsg1-2
# Boost (libboost-serialization-dev, libboost-filesystem-dev, libboost-program-options-dev) 1.67
# parMETIS (libparmetis-dev) 4.0.3-5build1
# HDF5 (libhdf5-openmpi-dev, hdf5-tools) 1.10.4+repack-10
# XSD (xsdcxx) 4.0.0-8
# Xerces (libxerces-c-dev) 3.2.2+debian-1build
# Amara (python-amara) 2.0.0
# SUNDIALS CVODE (libsundials-dev) 3.1.2+dfsg-3build3
# VTK (libvtk6-dev, libvtk6.3-qt, python-vtk6) 6.3
# Python (python-dev, python-pip, python-vtk6) 2.7.16-1

# Install dependencies with recommended, applicable suggested and other useful packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    chaste-dependencies \
    git \
    valgrind \
    "libpetsc-real*-dbg" \
    hdf5-tools \
    cmake-curses-gui \
    scons \
    libgoogle-perftools-dev \
    doxygen \
    graphviz \
    gnuplot \
    python-dev \
    python-pip \
    python-setuptools \
    # Needed for /usr/lib/x86_64-linux-gnu/libvtkRenderingPythonTkWidgets.so
    # python3-vtk7 \
    # Match any future version of Python VTK bindings
    # 'python3-vtk[0-9]+' \
    python-vtk6 \
    libvtk6-dev \
    cmake \
    scons \
    sudo \
    nano \
    curl \
    wget \
    rsync \
    mencoder \
    mplayer && \
    rm -rf /var/lib/apt/lists/*

# Fix CMake warnings: https://github.com/autowarefoundation/autoware/issues/795
RUN update-alternatives --install /usr/bin/vtk vtk /usr/bin/vtk6 10
# RUN update-alternatives --install /usr/bin/vtk vtk /usr/bin/vtk7 10
# RUN ln -s /usr/bin/vtk6 /usr/bin/vtk
RUN ln -s /usr/lib/python2.7/dist-packages/vtk/libvtkRenderingPythonTkWidgets.x86_64-linux-gnu.so \
    /usr/lib/x86_64-linux-gnu/libvtkRenderingPythonTkWidgets.so

# Install TextTest for regression testing (this requires pygtk)
RUN pip install --upgrade pip
RUN pip install texttest
ENV TEXTTEST_HOME /usr/local/bin/texttest

# Create user and working directory for Chaste files
ENV USER "chaste"
RUN useradd -ms /bin/bash chaste && echo "chaste:chaste" | chpasswd && adduser chaste sudo

# Allow CHASTE_DIR to be set at build time if desired
ARG CHASTE_DIR="/home/chaste"
ENV CHASTE_DIR=${CHASTE_DIR}
WORKDIR ${CHASTE_DIR}

# Add scripts
# COPY --chown=chaste:chaste scripts /home/chaste/scripts
COPY scripts "${CHASTE_DIR}/scripts"
RUN chown -R chaste:chaste scripts
USER chaste
ENV PATH "${CHASTE_DIR}/scripts:${PATH}"

# Set environment variables
# RUN source /home/chaste/scripts/set_env_vars.sh
ENV CHASTE_SOURCE_DIR="${CHASTE_DIR}/src" \
    CHASTE_BUILD_DIR="${CHASTE_DIR}/lib" \
    CHASTE_PROJECTS_DIR="${CHASTE_DIR}/src/projects" \
    CHASTE_TEST_OUTPUT="${CHASTE_DIR}/testoutput"
# CMake environment variables
ARG CMAKE_BUILD_TYPE="Release"
ARG Chaste_ERROR_ON_WARNING="OFF"
ARG Chaste_UPDATE_PROVENANCE="OFF"
ENV CMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} \
    Chaste_ERROR_ON_WARNING=${Chaste_ERROR_ON_WARNING} \
    Chaste_UPDATE_PROVENANCE=${Chaste_UPDATE_PROVENANCE}

ENV PYTHONPATH="${CHASTE_BUILD_DIR}/lib/python:$PYTHONPATH"

# Create Chaste build, projects and output folders
RUN mkdir -p "${CHASTE_SOURCE_DIR}" "${CHASTE_BUILD_DIR}" "${CHASTE_TEST_OUTPUT}"
RUN ln -s "${CHASTE_PROJECTS_DIR}" projects

CMD ["bash"]


FROM base

# Build Chaste: TAG can be a branch or release ('-' skips by default)
ARG TAG=-
ENV BRANCH=$TAG
RUN build_chaste.sh $BRANCH
# RUN ln -s "${CHASTE_TEST_OUTPUT}" "${CHASTE_SOURCE_DIR}/testoutput"

# Automatically mount the home directory in a volume to persist changes made there
# N.B. After declaring the volume, changes to the contents during build will not persist.
VOLUME "${CHASTE_DIR}"
