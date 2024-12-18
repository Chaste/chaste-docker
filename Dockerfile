# syntax=docker/dockerfile:1

# docker build -t chaste .
# docker build --target base -t chaste/base .  # Alternative: build base image
# docker run -it --rm -v chaste_data:/home/chaste chaste

ARG BASE=oracular
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
    gnupg \
    nano \
    sudo \
    wget

# Add signing key to install GitHub CLI: https://github.com/cli/cli/blob/trunk/docs/install_linux.md
RUN wget -O /etc/apt/keyrings/github-cli.gpg https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/github-cli.gpg] https://cli.github.com/packages stable main" >> /etc/apt/sources.list.d/github-cli.list

# Declare BASE in this build stage (the value is inherited from the global stage): https://github.com/moby/moby/issues/34482
ARG BASE
# Install the Chaste repo list and key: https://chaste.github.io/docs/installguides/ubuntu-package/
RUN wget -O /usr/share/keyrings/chaste.asc https://chaste.github.io/chaste.asc \
    && echo "deb [signed-by=/usr/share/keyrings/chaste.asc] https://chaste.github.io/ubuntu ${BASE}/" >> /etc/apt/sources.list.d/chaste.list

# https://github.com/Chaste/dependency-modules/wiki
# https://github.com/Chaste/infrastructure-scripts/blob/main/debian-package/debian/control
# https://github.com/Chaste/ubuntu/tree/main/debs
# Package: chaste-dependencies
# Version: 2024.10.28
# Architecture: all
# Depends: cmake, g++, git, libopenmpi-dev, petsc-dev, libhdf5-openmpi-dev, xsdcxx, libboost-serialization-dev, libboost-filesystem-dev, libboost-program-options-dev, libparmetis-dev, libmetis-dev, libxerces-c-dev, libsundials-dev, libvtk9-dev (>= 9.3.0), python3, python3-venv
# Recommends: valgrind, libpetsc-real3.20-dbg|libpetsc-real3.19t64-dbg|libpetsc-real3.18-dbg|libpetsc-real3.15-dbg, hdf5-tools, cmake-curses-gui, doxygen, graphviz, gnuplot, paraview

# Install dependencies with applicable recommended and other useful packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    chaste-dependencies \
    clang \
    lldb \
    gdb \
    # python3-dev \
    gh \
    valgrind \
    "libpetsc-real*-dbg" \
    hdf5-tools \
    cmake-curses-gui \
    doxygen \
    graphviz && \
    rm -rf /var/lib/apt/lists/*

# Update system to use Python3 by default
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 1
    # update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1
# Fix CMake warnings: https://github.com/autowarefoundation/autoware/issues/795 TODO: Check if this is still necessary with VTK9
# RUN update-alternatives --install /usr/bin/vtk vtk /usr/bin/vtk9 1

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
    CHASTE_BUILD_DIR="${CHASTE_DIR}/build" \
    CHASTE_TEST_OUTPUT="${CHASTE_DIR}/output" \
    PATH="${CHASTE_DIR}/scripts:${PATH}"
    # TEXTTEST_HOME=/usr/local/bin/texttest
ENV CHASTE_PROJECTS_DIR="${CHASTE_SOURCE_DIR}/projects" \
    TEXTTEST_HOME="${CHASTE_BUILD_DIR}/texttest_venv" \
    PYTHONPATH="${CHASTE_BUILD_DIR}/python"

# Create user and working directory for Chaste files
# RUN useradd -ms /bin/bash ${USER} && echo "${USER}:${PASSWORD}" | chpasswd && adduser ${USER} sudo
RUN useradd -ms /bin/bash -d ${CHASTE_DIR} ${USER} -G users,sudo && \
    echo "${USER}:${PASSWORD}" | chpasswd

# Add scripts
COPY --chown=${USER}:${GROUP} scripts "${CHASTE_DIR}/scripts"

USER ${USER}
WORKDIR ${CHASTE_DIR}
# SHELL [ "/bin/bash", "-exo", "pipefail", "-c" ]

# Install TextTest for regression testing (requires pygtk)
# NOTE: chaste-codegen is installed by CMake
RUN python -m venv --upgrade-deps "${CHASTE_BUILD_DIR}/texttest_venv" && \
    # source "${CHASTE_BUILD_DIR}/texttest_venv/bin/activate" && \
    . "${CHASTE_BUILD_DIR}/texttest_venv/bin/activate" && \
    # PATH=".local:${PATH}" && \
    python -m pip install --no-cache-dir texttest

# Create Chaste src, build, output and projects folders
RUN mkdir -p "${CHASTE_SOURCE_DIR}" "${CHASTE_BUILD_DIR}" "${CHASTE_TEST_OUTPUT}" && \
    ln -s "${CHASTE_PROJECTS_DIR}" projects
# DEPRECATED: Transitionary symlinks for build and output directories
# RUN ln -s "${CHASTE_BUILD_DIR}" lib && \
#     ln -s "${CHASTE_TEST_OUTPUT}" testoutput

# Fix git permissions issue CVE-2022-24765
RUN git config --global --add safe.directory "${CHASTE_SOURCE_DIR}"

# Save Chaste version and dependencies information
RUN apt-cache show chaste-dependencies > "${CHASTE_TEST_OUTPUT}/chaste-dependencies.txt"

CMD ["bash"]

# ------------------------------------------------------------------------------
FROM base AS build

# Build Chaste: GIT_TAG can be a branch or release ('-' skips by default)
ARG GIT_TAG=-
ENV GIT_TAG=${GIT_TAG}
RUN build_chaste.sh ${GIT_TAG}

# Automatically mount the home directory in a volume to persist changes made there.
# NOTE: After declaring the volume, changes to the contents during build will not persist.
VOLUME "${CHASTE_DIR}"

# ------------------------------------------------------------------------------
FROM build AS test

# Optionally run a test suite before finalising the image.
# NOTE: These test outputs will not appear in the volume. 
ARG TEST_SUITE=-
ENV TEST_SUITE=${TEST_SUITE}
RUN test.sh ${TEST_SUITE}
