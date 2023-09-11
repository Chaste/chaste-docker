help:
	@cat Makefile

CHASTE_IMAGE?=chaste/release
BASE?=jammy
GIT_TAG?=2021.1
# GIT_TAG?="${TAG}"
# GIT_TAG?=$(git describe --abbrev=0)
CHASTE_DIR?="/home/chaste"
DOCKER_FILE?=Dockerfile
CHASTE_DATA_VOLUME?=chaste_data
CMAKE_BUILD_TYPE?="Release"
Chaste_ERROR_ON_WARNING?="OFF"
Chaste_UPDATE_PROVENANCE?="OFF"
# PROJECTS?="${HOME}/projects"
# TEST_OUTPUT?="${HOME}/testoutput"
TEST_SUITE?=-
# SRC?=$(shell dirname `pwd`)
EXTRA_BUILD_FLAGS?=

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

all: base release

.PHONY: all build base release fresh latest login main develop clean setup stats pull push run test info verbose

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
BUILDX_ENV?=multiarch
setup:
	docker run --privileged --rm tonistiigi/binfmt --install all
	docker buildx create --name $(BUILDX_ENV) --driver docker-container --bootstrap --use

login:
	docker login

TARGET?=
# Do not declare volume for base so that subsequent layers may modify the contents of /home/chaste
# NOTE: When a container is started which creates a new volume, the contents of the mount point is copied to the volume
# NOTE: To build for multiple architectures, it may first be necessary to run:
# docker buildx create --use
ifeq ("$(PUSH)","true")
base stub: login
endif
base stub: TARGET = --target base
base stub:
	docker $(BUILD) \
		$(TARGET) \
		-t chaste/$@:$(BASE) \
		$(EXTRA_BUILD_FLAGS) \
		--build-arg BASE=$(BASE) \
		--build-arg CHASTE_DIR=$(CHASTE_DIR) \
		-f $(DOCKER_FILE) .
# docker push chaste/$@:$(BASE)

ifeq ("$(PUSH)","true")
build: login
endif
build:
	docker $(BUILD) \
		-t $(CHASTE_IMAGE) \
		-t $(CHASTE_IMAGE):$(GIT_TAG) \
		-t $(CHASTE_IMAGE):$(BASE)-$(GIT_TAG) \
		$(EXTRA_BUILD_FLAGS) \
		--build-arg BASE=$(BASE) \
		--build-arg CHASTE_DIR=$(CHASTE_DIR) \
		--build-arg GIT_TAG=$(GIT_TAG) \
		--build-arg CMAKE_BUILD_TYPE=$(CMAKE_BUILD_TYPE) \
		--build-arg Chaste_ERROR_ON_WARNING=$(Chaste_ERROR_ON_WARNING) \
		--build-arg Chaste_UPDATE_PROVENANCE=$(Chaste_UPDATE_PROVENANCE) \
		--build-arg TEST_SUITE=$(TEST_SUITE) \
		-f $(DOCKER_FILE) .
# Do not push so that a release build can be tested first
# docker build -t $(CHASTE_IMAGE):$(GIT_TAG) \

fresh latest: EXTRA_BUILD_FLAGS += --no-cache
latest: GIT_TAG=main
fresh latest: build

ifeq ("$(PUSH)","true")
main develop: login
endif
main develop: CMAKE_BUILD_TYPE="Debug"
main develop: Chaste_ERROR_ON_WARNING="ON"
main develop: Chaste_UPDATE_PROVENANCE="OFF"
# main develop: TEST_SUITE?="Continuous"
main develop:
	docker $(BUILD) \
		-t chaste/$@ \
		$(EXTRA_BUILD_FLAGS) \
		--build-arg BASE=$(BASE) \
		--build-arg CHASTE_DIR=$(CHASTE_DIR) \
		--build-arg GIT_TAG=$@ \
		--build-arg CMAKE_BUILD_TYPE=$(CMAKE_BUILD_TYPE) \
		--build-arg Chaste_ERROR_ON_WARNING=$(Chaste_ERROR_ON_WARNING) \
		--build-arg Chaste_UPDATE_PROVENANCE=$(Chaste_UPDATE_PROVENANCE) \
		--build-arg TEST_SUITE=$(TEST_SUITE) \
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
MOUNTS += -v $(TEST_OUTPUT):$(CHASTE_DIR)/testoutput
endif

run: build
	docker run -it --init --rm $(MOUNTS) $(CHASTE_IMAGE):$(GIT_TAG)

test: build
	docker run -it --init --rm --env CMAKE_BUILD_TYPE=Debug \
				$(CHASTE_IMAGE):$(GIT_TAG) test.sh $(TEST_SUITE)

ifeq ("$(PUSH)","true")
release: login
endif
release: CHASTE_IMAGE=chaste/release
release: TEST_SUITE?="Continuous"
release: build
# release: build test push

build-info: TEST_SUITE=TestChasteBuildInfo
build-info: test

info:
	@echo "Mounts: $(MOUNTS)"
	lsb_release -a
	docker -v

verbose: info
	docker system info
