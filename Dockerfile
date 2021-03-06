FROM cypress/base:12.16.1

ARG GIT_VERSION="2.23.0"
ARG GH_RUNNER_VERSION="2.169.1"
ARG TARGETPLATFORM

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# hadolint ignore=DL3003
RUN apt-get update && \
  apt-get install -y --no-install-recommends \
    curl \
    tar \
    apt-transport-https \
    ca-certificates \
    sudo \
    gnupg-agent \
    software-properties-common \
    build-essential \
    zlib1g-dev \
    gettext \
    liblttng-ust0 \
    libcurl4-openssl-dev \
    inetutils-ping \
    jq \
    nodejs \
    xvfb \
    uuid-runtime \
  && sudo apt remove cmdtest \
  && sudo apt install npm  -y --no-install-recommends \
  && sudo npm install -g yarn -y --no-install-recommends \
  && rm -rf /var/lib/apt/lists/* \
  && c_rehash \
  && cd /tmp \
  && curl -sL https://www.kernel.org/pub/software/scm/git/git-${GIT_VERSION}.tar.gz -o git.tgz \
  && tar zxf git.tgz \
  && cd git-${GIT_VERSION} \
  && ./configure --prefix=/usr \
  && make \
  && make install \
  && cd / \
  && rm -rf /tmp/git.tgz /tmp/git-${GIT_VERSION}

RUN curl -sL "https://github.com/docker/compose/releases/download/1.25.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \
  && chmod +x /usr/local/bin/docker-compose

WORKDIR /actions-runner
COPY install_actions.sh /actions-runner

RUN chmod +x /actions-runner/install_actions.sh \
  && /actions-runner/install_actions.sh ${GH_RUNNER_VERSION} ${TARGETPLATFORM} \
  && rm /actions-runner/install_actions.sh

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
