FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive
#basic install
RUN apt-get update && apt-get install -y \
    curl \
    jq \
    git \
    unzip \
    sudo \
    gnupg \
    software-properties-common \
    awscli \
    bash \
    ca-certificates \
    && apt-get clean

RUN curl -fsSL https://releases.hashicorp.com/terraform/1.5.7/terraform_1.5.7_linux_amd64.zip -o terraform.zip \
    && unzip terraform.zip \
    && mv terraform /usr/local/bin/terraform \
    && rm terraform.zip

RUN useradd -m runner
WORKDIR /home/runner
USER runner
ENV RUNNER_VERSION=2.314.1
RUN curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && tar xzf actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && rm actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

COPY --chown=runner:runner entrypoint.sh /home/runner/entrypoint.sh
RUN chmod +x /home/runner/entrypoint.sh
ENTRYPOINT ["/home/runner/entrypoint.sh"]
