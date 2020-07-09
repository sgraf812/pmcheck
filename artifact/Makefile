all: run-docker

DOCKER_NAME=ryanglscott/icfp2020-lyg-artifact
DOCKER_TAG=0.7

DOCKER_RUN_ARGS=--rm ${DOCKER_NAME}:${DOCKER_TAG}

.PHONY: docker run-docker
docker:
	docker build -t ${DOCKER_NAME}:${DOCKER_TAG} .

run-docker: docker
	docker run -it ${DOCKER_RUN_ARGS}
