help:
	@cat Makefile

CHASTE_IMAGE?=chaste/release
BASE?=eoan
GIT_TAG?=release_2019.1
# GIT_TAG?=$(git describe --abbrev=0)
TAG?=2019.1
CHASTE_DIR?="/home/chaste"
DOCKER_FILE?=Dockerfile
CHASTE_DATA_VOLUME?=chaste_data
# PROJECTS?="${HOME}/projects"
# TEST_OUTPUT?="${HOME}/testoutput"
TEST_SUITE?="Continuous"
# SRC?=$(shell dirname `pwd`)

all: base build

.PHONY: all build base release fresh latest master develop clean stats pull push run test info verbose

build:
	docker build -t $(CHASTE_IMAGE):$(TAG) \
				 -t $(CHASTE_IMAGE):$(BASE)-$(TAG) \
				 --build-arg BASE=$(BASE) \
				 --build-arg CHASTE_DIR=$(CHASTE_DIR) \
				 --build-arg TAG=$(GIT_TAG) \
				 -f $(DOCKER_FILE) .

base:
	docker build --build-arg BASE=$(BASE) --target base -t chaste/base:$(BASE) .
	docker push chaste/base:$(BASE)

fresh:
	docker build --no-cache -t $(CHASTE_IMAGE):$(TAG) \
				 --build-arg BASE=$(BASE) \
				 --build-arg CHASTE_DIR=$(CHASTE_DIR) \
				 --build-arg TAG=$(GIT_TAG) \
				 -f $(DOCKER_FILE) .

latest:
	docker build --no-cache -t $(CHASTE_IMAGE):$(TAG) \
				 --build-arg BASE=$(BASE) \
				 --build-arg CHASTE_DIR=$(CHASTE_DIR) \
				 --build-arg TAG=master \
				 -f $(DOCKER_FILE) .

develop: CHASTE_IMAGE=chaste/develop
master develop:
	docker build -t $(CHASTE_IMAGE):$@ \
				 --build-arg BASE=$(BASE) \
				 --build-arg CHASTE_DIR=$(CHASTE_DIR) \
				 --build-arg TAG=$@ \
				 -f $(DOCKER_FILE) .

clean:
	docker system prune

stats:
	docker stats

pull:
	docker pull $(CHASTE_IMAGE):$(TAG)

push:
	docker push $(CHASTE_IMAGE):$(TAG)
	docker push $(CHASTE_IMAGE):$(BASE)-$(TAG)

MOUNTS = -v $(CHASTE_DATA_VOLUME):$(CHASTE_DIR)
ifdef PROJECTS
MOUNTS += -v $(PROJECTS):$(CHASTE_DIR)/projects
endif
ifdef TEST_OUTPUT
MOUNTS += -v $(TEST_OUTPUT):$(CHASTE_DIR)/testoutput
endif

run: build
	docker run -it --init --rm $(MOUNTS) $(CHASTE_IMAGE):$(TAG)

test: build
	docker run -it --init --rm --env CMAKE_BUILD_TYPE=Debug \
				$(CHASTE_IMAGE):$(TAG) test.sh $(TEST_SUITE)

release: CHASTE_IMAGE=chaste/release
release: build test push

info:
	@echo "Mounts: $(MOUNTS)"
	lsb_release -a
	docker -v

verbose: info
	docker system info
