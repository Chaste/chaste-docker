help:
	@cat Makefile

CHASTE_IMAGE?=chaste/chaste-docker
BASE?=eoan
GIT_TAG?=release_2019.1
TAG?=2019.1
CHASTE_DIR?="/home/chaste"
DOCKER_FILE?=Dockerfile
CHASTE_DATA_VOLUME?=chaste_data
PROJECTS?="${HOME}/projects"
TEST_OUTPUT?="${HOME}/testoutput"
TEST_SUITE?="Continuous"
# SRC?=$(shell dirname `pwd`)

all: dependencies build

.PHONY: all build base fresh latest clean stats clone run bash mount test

build:
	docker build -t $(CHASTE_IMAGE):$(TAG) \
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

clean:
	docker system prune

stats:
	docker stats

pull:
	docker pull $(CHASTE_IMAGE):$(TAG)

run: build
	docker run -it --init --rm -v $(CHASTE_DATA_VOLUME):$(CHASTE_DIR) \
							   $(CHASTE_IMAGE):$(TAG) bash

bash: build
	docker run -it --init --rm -v $(CHASTE_DATA_VOLUME):$(CHASTE_DIR) \
							   $(CHASTE_IMAGE):$(TAG) bash

mount: build
	docker run -it --init --rm -v $(CHASTE_DATA_VOLUME):$(CHASTE_DIR) \
							   -v $(PROJECTS):$(CHASTE_DIR)/projects \
							   -v $(TEST_OUTPUT):/$(CHASTE_DIR)/testoutput \
							   $(CHASTE_IMAGE):$(TAG) bash

test: build
	docker run -it --init --rm -v $(CHASTE_DATA_VOLUME):$(CHASTE_DIR) \
							   --env CMAKE_BUILD_TYPE=Debug \
							   $(CHASTE_IMAGE):$(TAG) test.sh $(TEST_SUITE)
