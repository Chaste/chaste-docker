# docker build -t chaste .
# docker build --target base -t chaste/base .  # Alternative: build base image
# docker run -it --rm -v chaste_data:/home/chaste chaste

ARG BASE=focal
FROM ubuntu:${BASE} AS base
LABEL maintainer="Ben Evans <ben.d.evans@gmail.com>" \
    author.orcid="https://orcid.org/0000-0002-1734-6070" \
    image.publication="https://doi.org/10.21105/joss.01848" \
    org.opencontainers.image.authors="Benjamin D. Evans" \
    org.opencontainers.image.url="https://github.com/Chaste/chaste-docker" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.title="Chaste Docker Image" \
    org.opencontainers.image.description="Chaste: Cancer, Heart and Soft Tissue Environment" \
    org.opencontainers.image.documentation="http://www.cs.ox.ac.uk/chaste/"

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
# Version: 2020.10.05
# Architecture: all
# Depends: cmake | scons, g++, libopenmpi-dev, petsc-dev, libhdf5-openmpi-dev, xsdcxx, libboost-serialization-dev, libboost-filesystem-dev, libboost-program-options-dev, libparmetis-dev, libmetis-dev, libxerces-c-dev, libsundials-dev, libvtk7-dev | libvtk6-dev, python3, python3-venv
# Recommends: git, valgrind, libpetsc-real3.12-dbg, libfltk1.1, hdf5-tools, cmake-curses-gui
# Suggests: libgoogle-perftools-dev, doxygen, graphviz, subversion, git-svn, gnuplot, paraview

# 12/10/2020
# CMake (cmake) 3.16.3-1ubuntu1
# GCC (g++) g++: 4:9.3.0-1ubuntu2
# PETSc (libpetsc-real3.12-dbg) 3.12.4+dfsg1-1
# Boost (libboost-serialization-dev, libboost-filesystem-dev, libboost-program-options-dev) 1.71.0.0ubuntu2
# parMETIS (libparmetis-dev) 4.0.3-5build1
# HDF5 (libhdf5-openmpi-dev, hdf5-tools) 1.10.4+repack-11ubuntu1
# XSD (xsdcxx) 4.0.0-8build1
# Xerces (libxerces-c-dev) 3.2.2+debian-1build3
# SUNDIALS CVODE (libsundials-dev) 3.1.2+dfsg-3ubuntu2
# VTK (libvtk7-dev) 7.1.1+dfsg2-2ubuntu1
# Python (python-dev, python-pip) 3.8.2-0ubuntu2

# Install dependencies with recommended, applicable suggested and other useful packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    chaste-dependencies \
    cmake \
    scons \
    libvtk7-dev \
    python3-dev \
    python3-venv \
    python3-pip \
    python3-setuptools \
    git \
    valgrind \
    "libpetsc-real*-dbg" \
    # libfltk1.1 \
    hdf5-tools \
    cmake-curses-gui \
    libgoogle-perftools-dev \
    doxygen \
    graphviz \
    gnuplot \
    sudo \
    nano \
    curl \
    wget \
    rsync \
    mencoder \
    mplayer && \
    rm -rf /var/lib/apt/lists/*

# Fix CMake warnings: https://github.com/autowarefoundation/autoware/issues/795
RUN update-alternatives --install /usr/bin/vtk vtk /usr/bin/vtk7 7
# RUN ln -s /usr/bin/vtk6 /usr/bin/vtk

# Install TextTest for regression testing (this requires pygtk)
RUN ln -s /usr/bin/pip3 /usr/bin/pip
RUN pip install --upgrade pip
RUN pip install texttest
ENV TEXTTEST_HOME /usr/local/bin/texttest

# Installed by CMake
# RUN pip install chaste-codegen

# Create user and working directory for Chaste files
ENV USER "chaste"
RUN useradd -ms /bin/bash chaste && echo "chaste:chaste" | chpasswd && adduser chaste sudo

# Allow CHASTE_DIR to be set at build time if desired
ARG CHASTE_DIR="/home/chaste"
ENV CHASTE_DIR=${CHASTE_DIR}
WORKDIR ${CHASTE_DIR}

# Add scripts
COPY --chown=chaste:chaste scripts "${CHASTE_DIR}/scripts"
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

ENV PYTHONPATH="${CHASTE_BUILD_DIR}/python:$PYTHONPATH"

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
