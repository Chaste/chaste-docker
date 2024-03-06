# syntax=docker/dockerfile:1

# docker build -t chaste .
# docker build --target base -t chaste/base .  # Alternative: build base image
# docker run -it --rm -v chaste_data:/home/chaste chaste

ARG BASE=jammy
FROM ubuntu:${BASE} AS base
LABEL maintainer="Ben Evans <ben.d.evans@gmail.com>" \
    author.orcid="https://orcid.org/0000-0002-1734-6070" \
    image.publication="https://doi.org/10.21105/joss.01848" \
    org.opencontainers.image.authors="Benjamin D. Evans" \
    org.opencontainers.image.url="https://github.com/Chaste/chaste-docker" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.title="Chaste Docker Image" \
    org.opencontainers.image.description="Chaste: Cancer, Heart and Soft Tissue Environment" \
    org.opencontainers.image.documentation="https://chaste.github.io/docs/installguides/docker/"

USER root

# ARG DEBIAN_FRONTEND=noninteractive
# Install system dependencies
ENV TZ="Europe/London"
RUN apt-get update && DEBIAN_FRONTEND="noninteractive" apt-get -y install tzdata
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    apt-utils \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    nano \
    rsync \
    sudo \
    wget

# Add signing key to install GitHub CLI
# https://github.com/cli/cli/blob/trunk/docs/install_linux.md
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null

# Declare BASE in this build stage (the value is inherited from the global stage)
# https://github.com/moby/moby/issues/34482
ARG BASE
# Install the Chaste repo list and key
# https://chaste.github.io/docs/installguides/ubuntu-package/
RUN sudo wget -O /usr/share/keyrings/chaste.asc https://chaste.github.io/chaste.asc \
    && echo "deb [signed-by=/usr/share/keyrings/chaste.asc] https://chaste.github.io/ubuntu ${BASE}/" >> /etc/apt/sources.list.d/chaste.list

# https://github.com/Chaste/dependency-modules/wiki
# Package: chaste-dependencies
# Version: 2022.04.11
# Architecture: all
# Depends: cmake | scons, g++, libopenmpi-dev, petsc-dev, libhdf5-openmpi-dev, xsdcxx, libboost-serialization-dev, libboost-filesystem-dev, libboost-program-options-dev, libparmetis-dev, libmetis-dev, libxerces-c-dev, libsundials-dev, libvtk7-dev | libvtk6-dev, python3, python3-venv
# Recommends: git, valgrind, libpetsc-real3.15-dbg | libpetsc-real3.14-dbg | libpetsc-real3.12-dbg, libfltk1.1, hdf5-tools, cmake-curses-gui
# Suggests: libgoogle-perftools-dev, doxygen, graphviz, subversion, git-svn, gnuplot, paraview
# DEPRECATED: scons will be removed in the next release

# Install dependencies with recommended, applicable suggested and other useful packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    chaste-dependencies \
    cmake \
    # libvtk7-dev \  # Dependency of chaste-dependencies (check 7 not 6 is installed)
    python3-dev \
    # python3-venv \  # Dependency of chaste-dependencies
    python3-pip \
    # python3-setuptools \  # Dependency of python3-pip
    gh \
    git \
    valgrind \
    "libpetsc-real*-dbg" \
    hdf5-tools \
    cmake-curses-gui \
    doxygen \
    graphviz && \
    rm -rf /var/lib/apt/lists/*

# Fix CMake warnings: https://github.com/autowarefoundation/autoware/issues/795 TODO: Check if this is still necessary with VTK9
RUN update-alternatives --install /usr/bin/vtk vtk /usr/bin/vtk7 7
# Update system to use Python3 by default
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 1
RUN update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1

# Set environment variables with args to allow for changes at build time
ARG USER="chaste"
ARG CHASTE_DIR="/home/${USER}"
ARG CMAKE_BUILD_TYPE="Debug"
ARG Chaste_ERROR_ON_WARNING="ON"
ARG Chaste_UPDATE_PROVENANCE="OFF"
# RUN source /home/chaste/scripts/set_env_vars.sh
ENV USER=${USER} \
    GROUP=${USER} \
    PASSWORD=${USER} \
    CHASTE_DIR=${CHASTE_DIR} \
    CMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} \
    Chaste_ERROR_ON_WARNING=${Chaste_ERROR_ON_WARNING} \
    Chaste_UPDATE_PROVENANCE=${Chaste_UPDATE_PROVENANCE} \
    CHASTE_SOURCE_DIR="${CHASTE_DIR}/src" \
    CHASTE_PROJECTS_DIR="${CHASTE_SOURCE_DIR}/projects" \
    CHASTE_BUILD_DIR="${CHASTE_DIR}/build" \
    CHASTE_TEST_OUTPUT="${CHASTE_DIR}/output" \
    PATH="${CHASTE_DIR}/scripts:${PATH}" \
    PYTHONPATH="${CHASTE_BUILD_DIR}/python:$PYTHONPATH" \
    TEXTTEST_HOME=/usr/local/bin/texttest

# Create user and working directory for Chaste files
# RUN useradd -ms /bin/bash ${USER} && echo "${USER}:${PASSWORD}" | chpasswd && adduser ${USER} sudo
RUN useradd -ms /bin/bash -d ${CHASTE_DIR} ${USER} -G users,sudo && \
    echo "${USER}:${PASSWORD}" | chpasswd

# Add scripts
COPY --chown=${USER}:${GROUP} scripts "${CHASTE_DIR}/scripts"

USER ${USER}
WORKDIR ${CHASTE_DIR}

# Install TextTest for regression testing (requires pygtk)
# NOTE: chaste-codegen is installed by CMake
RUN python -m pip install --upgrade pip && \
    python -m pip install texttest

# Create Chaste build, projects and output folders
RUN mkdir -p "${CHASTE_SOURCE_DIR}" "${CHASTE_BUILD_DIR}" "${CHASTE_TEST_OUTPUT}"
RUN ln -s "${CHASTE_PROJECTS_DIR}" projects
# DEPRECATED: Transitionary symlink for build directory
RUN ln -s "${CHASTE_BUILD_DIR}" lib
# DEPRECATED: Transitionary symlink for testoutput directory
RUN ln -s "${CHASTE_TEST_OUTPUT}" testoutput

# Fix git permissions issue CVE-2022-24765
RUN git config --global --add safe.directory "${CHASTE_SOURCE_DIR}"

# Save Chaste version and dependencies information
RUN apt-cache show chaste-dependencies > chaste-dependencies.txt
RUN ctest --verbose -R TestChasteBuildInfo$

CMD ["bash"]

# ------------------------------------------------------------------------------

FROM base

# Build Chaste: GIT_TAG can be a branch or release ('-' skips by default)
ARG GIT_TAG=-
ENV GIT_TAG=${GIT_TAG}
RUN build_chaste.sh ${GIT_TAG}

# Automatically mount the home directory in a volume to persist changes made there.
# NOTE: After declaring the volume, changes to the contents during build will not persist.
VOLUME "${CHASTE_DIR}"

# Optionally run a test suite before finalising the image.
# NOTE: These test outputs will not appear in the volume. 
ARG TEST_SUITE=-
ENV TEST_SUITE=${TEST_SUITE}
RUN test.sh ${TEST_SUITE}
