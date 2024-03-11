help:
	@cat Makefile
	@echo
	@echo "Usage: make [TARGET] [VARIABLE=value]"
	@echo "Perform a dry run with:"
	@echo "  make [TARGET] -n"

BASE ?= jammy
GIT_TAG ?= 2024.1
# GIT_TAG?=$(git describe --abbrev=0)
TEST_SUITE ?= -
CHASTE_IMAGE ?= chaste/release
CHASTE_DIR ?= "/home/chaste"
CHASTE_DATA_VOLUME ?= chaste_data
FRESH ?=
EXTRA_BUILD_FLAGS ?=

# Optional mounts
# PROJECTS ?= "${HOME}/projects"
# TEST_OUTPUT ?= "${HOME}/output"

# https://github.com/pytorch/pytorch/blob/main/docker.Makefile
MULTI_ARCH_BUILD ?= true
ifeq ("$(MULTI_ARCH_BUILD)", "true")
PUSH = true
PLATFORM ?= "linux/amd64,linux/arm64/v8"
BUILD = buildx build --push --platform $(PLATFORM) -o type=image
else
BUILD = build
endif

PUSH ?= false
ifeq ("$(PUSH)", "true")
base develop main release: login
endif

all: base release

.PHONY: base develop main release
# base develop main release: build
base develop main release:
	docker $(BUILD) \
		$(TARGET) \
		$(EXTRA_BUILD_FLAGS) \
		$(BUILD_ARGS) \
		$(DOCKER_TAGS) \
		-f $(DOCKER_FILE) .

TARGET?=
base: TARGET = --target base
develop main: TARGET = --target build

ifdef FRESH
EXTRA_BUILD_FLAGS += --no-cache
endif

BUILD_ARGS = --build-arg BASE=$(BASE) \
		--build-arg CHASTE_DIR=$(CHASTE_DIR)

develop main release: BUILD_ARGS += --build-arg GIT_TAG=$(GIT_TAG) \
		--build-arg CMAKE_BUILD_TYPE=$(CMAKE_BUILD_TYPE) \
		--build-arg Chaste_ERROR_ON_WARNING=$(Chaste_ERROR_ON_WARNING) \
		--build-arg Chaste_UPDATE_PROVENANCE=$(Chaste_UPDATE_PROVENANCE) \
		--build-arg TEST_SUITE=$(TEST_SUITE)

develop main: CMAKE_BUILD_TYPE="Debug"
develop main: Chaste_ERROR_ON_WARNING="ON"
develop main: Chaste_UPDATE_PROVENANCE="OFF"
develop main: GIT_TAG=$@

release: CMAKE_BUILD_TYPE="Release"
release: Chaste_ERROR_ON_WARNING="OFF"
release: Chaste_UPDATE_PROVENANCE="ON"
release: TEST_SUITE="Continuous"

base develop main release: CHASTE_IMAGE = chaste/$@
base develop main release: DOCKER_TAGS = -t $(CHASTE_IMAGE)
base develop main: DOCKER_TAGS += -t $(CHASTE_IMAGE):$(BASE)
release: DOCKER_TAGS += -t $(CHASTE_IMAGE):$(GIT_TAG) \
		-t $(CHASTE_IMAGE):$(BASE)-$(GIT_TAG)
# Do not push so that a release build can be tested first
# release: build test push

DOCKER_FILE ?= Dockerfile


# NOTE: To build for multiple architectures, it may first be necessary to run this:
.PHONY: setup
BUILDX_ENV ?= multiarch
setup:
	docker run --privileged --rm tonistiigi/binfmt --install all
	docker buildx create --name $(BUILDX_ENV) --driver docker-container --bootstrap --use

.PHONY: login
login:
	docker login

.PHONY: clean
clean:
	docker system prune

.PHONY: stats
stats:
	docker stats

.PHONY: pull
pull:
	docker pull $(CHASTE_IMAGE):$(GIT_TAG)

.PHONY: push
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

# NOTE: When a container is started which creates a new volume, the contents of the mount point are copied to the volume
.PHONY: run
run:
	docker run -it --init --rm $(MOUNTS) $(CHASTE_IMAGE)

.PHONY: test
test: BUILD_ARGS += --build-arg TEST_SUITE=$(TEST_SUITE)
test:
	docker run -it --init --rm --env CMAKE_BUILD_TYPE=Debug \
				$(CHASTE_IMAGE) test.sh $(TEST_SUITE) c


.PHONY: build-info
# build-info: TEST_SUITE=TestChasteBuildInfo
# build-info: test
build-info:
	docker run -it --init --rm --env CMAKE_BUILD_TYPE=Debug \
				$(CHASTE_IMAGE) get_chaste_info.sh

.PHONY: info
info:
	@echo "Mounts: $(MOUNTS)"
	docker -v
# lsb_release -a

.PHONY: verbose
verbose: info
	docker system info
