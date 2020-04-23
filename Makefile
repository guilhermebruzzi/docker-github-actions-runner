IMAGE_NAME = guilhermebruzzi/github-runner
DOCKER_NAME = github-runner

docker-build:
	docker build -t $(IMAGE_NAME) --memory="1g" .

docker-remove:
	docker stop $(DOCKER_NAME) || true && docker rm $(DOCKER_NAME) || true

docker-run: docker-build docker-remove
	docker run --name $(DOCKER_NAME) \
	-e REPO_URL="https://github.com/vtex/checkout-instore/" \
	-e RUNNER_NAME="INSTORE-VTEX-DOCKER-SELF-HOSTED-RUNNER" \
	-e ACCESS_TOKEN="${GITHUB_ACTIONS_TOKEN}" \
	-e RUNNER_WORKDIR="/tmp/INSTORE-VTEX-DOCKER-SELF-HOSTED-RUNNER" \
	-e RUNNER_LABELS="instore" \
	-v /var/run/docker.sock:/var/run/docker.sock \
	-v /tmp/INSTORE-VTEX-DOCKER-SELF-HOSTED-RUNNER:/tmp/INSTORE-VTEX-DOCKER-SELF-HOSTED-RUNNER \
	$(IMAGE_NAME):latest

docker-run-it: docker-build docker-remove
	docker run  -it --entrypoint /bin/bash --name $(DOCKER_NAME) \
	-e REPO_URL="https://github.com/vtex/checkout-instore/" \
	-e RUNNER_NAME="INSTORE-VTEX-DOCKER-SELF-HOSTED-RUNNER" \
	-e ACCESS_TOKEN="${GITHUB_ACTIONS_TOKEN}" \
	-e RUNNER_WORKDIR="/tmp/INSTORE-VTEX-DOCKER-SELF-HOSTED-RUNNER" \
	-e RUNNER_LABELS="instore" \
	-v /var/run/docker.sock:/var/run/docker.sock \
	-v /tmp/INSTORE-VTEX-DOCKER-SELF-HOSTED-RUNNER:/tmp/INSTORE-VTEX-DOCKER-SELF-HOSTED-RUNNER \
	$(IMAGE_NAME):latest

setup:
	yarn

deploy: setup
	./node_modules/.bin/releasy --stable
