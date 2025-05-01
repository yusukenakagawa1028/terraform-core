FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive

# Install base packages
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
    dos2unix \
    ca-certificates \
    && apt-get clean

# Install Terraform
RUN curl -fsSL https://releases.hashicorp.com/terraform/1.5.7/terraform_1.5.7_linux_amd64.zip -o terraform.zip \
    && unzip terraform.zip \
    && mv terraform /usr/local/bin/terraform \
    && rm terraform.zip

# Create user and prepare actions-runner
RUN useradd -m runner
WORKDIR /home/runner
ENV RUNNER_VERSION=2.314.1
RUN curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && tar xzf actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && rm actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

# Copy entrypoint script and fix format
COPY entrypoint.sh /home/runner/entrypoint.sh
RUN dos2unix /home/runner/entrypoint.sh && chmod +x /home/runner/entrypoint.sh && chown runner:runner /home/runner/entrypoint.sh

# Switch to runner user and use bash to avoid format issues
USER runner
ENTRYPOINT ["bash", "/home/runner/entrypoint.sh"]
