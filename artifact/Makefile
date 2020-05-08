all: run-docker

DOCKER_NAME=lyg-artifact
DOCKER_TAG=0.1

DOCKER_MOUNTS= \
  --volume ${PWD}/Readme.md:/root/Readme.md

DOCKER_RUN_ARGS=--rm ${DOCKER_MOUNTS} ${DOCKER_NAME}:${DOCKER_TAG}

docker:
	docker build -t ${DOCKER_NAME}:${DOCKER_TAG} .

run-docker: docker
	docker run -it ${DOCKER_RUN_ARGS}
