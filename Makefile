help:
	@echo "Usage: make [TARGET] [VARIABLE=value]"
	@echo "Perform a dry run with:"
	@echo "  make [TARGET] -n"
	@cat Makefile

CHASTE_IMAGE?=chaste/release
BASE?=jammy
GIT_TAG?=2024.1
# GIT_TAG?=$(git describe --abbrev=0)
CHASTE_DIR?="/home/chaste"
CHASTE_DATA_VOLUME?=chaste_data

# Optional mounts
# PROJECTS?="${HOME}/projects"
# TEST_OUTPUT?="${HOME}/output"

# SRC?=$(shell dirname `pwd`)
TARGET?=
EXTRA_BUILD_FLAGS?=
TEST_SUITE?=-

# https://github.com/pytorch/pytorch/blob/main/docker.Makefile
PUSH?=false
MULTI_ARCH_BUILD?=true
PLATFORM?="linux/amd64,linux/arm64/v8"
ifeq ("$(MULTI_ARCH_BUILD)","true")
PUSH = true
BUILD = buildx build --push --platform $(PLATFORM) -o type=image
else
BUILD = build
endif

.PHONY: all build base release fresh login main develop clean setup stats pull push run test info verbose

all: base release

# NOTE: To build for multiple architectures, it may first be necessary to run:
# make setup
BUILDX_ENV ?= multiarch
setup:
	docker run --privileged --rm tonistiigi/binfmt --install all
	docker buildx create --name $(BUILDX_ENV) --driver docker-container --bootstrap --use

login:
	docker login

# Do not declare volume for base so that subsequent layers may modify the contents of /home/chaste
# NOTE: When a container is started which creates a new volume, the contents of the mount point is copied to the volume
base: TARGET = --target base
base: DOCKER_TAGS = -t chaste/$@:$(BASE)

fresh: EXTRA_BUILD_FLAGS += --no-cache
fresh: develop

develop main: CMAKE_BUILD_TYPE="Debug"
develop main: Chaste_ERROR_ON_WARNING="ON"
develop main: Chaste_UPDATE_PROVENANCE="OFF"
develop main: GIT_TAG=$@
develop main: DOCKER_TAGS = -t chaste/$@

# Do not push so that a release build can be tested first
release: CHASTE_IMAGE=chaste/release
release: CMAKE_BUILD_TYPE="Release"
release: Chaste_ERROR_ON_WARNING="OFF"
release: Chaste_UPDATE_PROVENANCE="ON"
release: TEST_SUITE?="Continuous"
# release: build test push

develop main release: BUILD_ARGS += --build-arg GIT_TAG=$(GIT_TAG) \
		--build-arg CMAKE_BUILD_TYPE=$(CMAKE_BUILD_TYPE) \
		--build-arg Chaste_ERROR_ON_WARNING=$(Chaste_ERROR_ON_WARNING) \
		--build-arg Chaste_UPDATE_PROVENANCE=$(Chaste_UPDATE_PROVENANCE) \
		--build-arg TEST_SUITE=$(TEST_SUITE)

base fresh develop main release: build

BUILD_ARGS = --build-arg BASE=$(BASE) \
		--build-arg CHASTE_DIR=$(CHASTE_DIR)
DOCKER_TAGS ?= -t $(CHASTE_IMAGE) \
		-t $(CHASTE_IMAGE):$(GIT_TAG) \
		-t $(CHASTE_IMAGE):$(BASE)-$(GIT_TAG)
DOCKER_FILE ?= Dockerfile

ifeq ("$(PUSH)","true")
build: login
endif
build:
	docker $(BUILD) \
		$(TARGET) \
		$(EXTRA_BUILD_FLAGS) \
		$(BUILD_ARGS) \
		$(DOCKER_TAGS) \
		-f $(DOCKER_FILE) .

clean:
	docker system prune

stats:
	docker stats

pull:
	docker pull $(CHASTE_IMAGE):$(GIT_TAG)

push:
	docker push $(CHASTE_IMAGE):$(GIT_TAG)
	docker push $(CHASTE_IMAGE):$(BASE)-$(GIT_TAG)

MOUNTS = -v $(CHASTE_DATA_VOLUME):$(CHASTE_DIR)
ifdef PROJECTS
MOUNTS += -v $(PROJECTS):$(CHASTE_DIR)/projects
endif
ifdef TEST_OUTPUT
MOUNTS += -v $(TEST_OUTPUT):$(CHASTE_DIR)/output
endif

run: build
	docker run -it --init --rm $(MOUNTS) $(CHASTE_IMAGE):$(GIT_TAG)

test: BUILD_ARGS += --build-arg TEST_SUITE=$(TEST_SUITE)
test: build
	docker run -it --init --rm --env CMAKE_BUILD_TYPE=Debug \
				$(CHASTE_IMAGE):$(GIT_TAG) test.sh $(TEST_SUITE) c

build-info: TEST_SUITE=TestChasteBuildInfo
build-info: test

info:
	@echo "Mounts: $(MOUNTS)"
	lsb_release -a
	docker -v

verbose: info
	docker system info

# BUILD_ARGS := --build-arg BASE=$(BASE)
# IMAGE_NAMES := -t $(CHASTE_IMAGE):$(GIT_TAG)
# base release: TARGET = $@
# release: BUILD_ARGS += --build-arg CHASTE_DIR=$(CHASTE_DIR) --build-arg GIT_TAG=$(GIT_TAG)
# release: IMAGE_NAMES += -t $(CHASTE_IMAGE):$(BASE)-$(GIT_TAG)
# base: BUILD_ARGS += --target $@
# base: CHASTE_IMAGE = chaste/base
# base: IMAGE_NAMES = $(CHASTE_IMAGE):$(BASE)
# base release: build
# 	for NAME in $(IMAGE_NAMES) ; do \
# 		push $$(NAME) ; \
# 	done
# build:
# 	docker build $(BUILD_ARGS) $(IMAGE_NAMES) -f $(DOCKER_FILE) .
# 	# docker push $(IMAGE_NAMES)
