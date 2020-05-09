all: run-docker

DOCKER_NAME=lyg-artifact
DOCKER_TAG=0.1

DOCKER_MOUNTS= \
  --volume ${PWD}/Readme.md:/root/Readme.md                     \
  --volume ${PWD}/examples/:/root/examples/                     \
  --volume ${PWD}/ocaml/:/root/ocaml/                           \
  --volume ${PWD}/perf-tests/bench.sh:/root/perf-tests/bench.sh \
  --volume ${PWD}/perf-tests/bench-all.sh:/root/perf-tests/bench-all.sh

DOCKER_RUN_ARGS=--rm ${DOCKER_MOUNTS} ${DOCKER_NAME}:${DOCKER_TAG}

.PHONY: docker run-docker
docker:
	docker build -t ${DOCKER_NAME}:${DOCKER_TAG} .

run-docker: docker
	docker run -it ${DOCKER_RUN_ARGS}
