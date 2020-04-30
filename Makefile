IMAGE_NAME = guilhermebruzzi/github-runner
DOCKER_NAME = github-runner


docker-login:
	@docker login docker.pkg.github.com -u USERNAME --password "${GITHUB_ACTIONS_TOKEN}"

setup: docker-login
	yarn

docker-build: setup
	docker build -t $(IMAGE_NAME) .

docker-remove:
	docker stop $(DOCKER_NAME) || true && docker rm $(DOCKER_NAME) || true

docker-run: docker-build docker-remove
	docker run --name $(DOCKER_NAME) --memory="1g" \
	-e REPO_URL="https://github.com/vtex/checkout-instore/" \
	-e RUNNER_NAME="RUNNER" \
	-e ACCESS_TOKEN="${GITHUB_ACTIONS_TOKEN}" \
	-e RUNNER_WORKDIR="/tmp/RUNNER" \
	-e RUNNER_LABELS="instore" \
	-v /var/run/docker.sock:/var/run/docker.sock \
	-v /tmp/RUNNER:/tmp/RUNNER \
	$(IMAGE_NAME):latest

docker-run-it: docker-build docker-remove
	docker run  -it --entrypoint /bin/bash --name $(DOCKER_NAME) \
	-e REPO_URL="https://github.com/vtex/checkout-instore/" \
	-e RUNNER_NAME="RUNNER" \
	-e ACCESS_TOKEN="${GITHUB_ACTIONS_TOKEN}" \
	-e RUNNER_WORKDIR="/tmp/RUNNER" \
	-e RUNNER_LABELS="instore" \
	-v /var/run/docker.sock:/var/run/docker.sock \
	-v /tmp/RUNNER:/tmp/RUNNER \
	$(IMAGE_NAME):latest

deploy: setup
	./node_modules/.bin/releasy --stable
