FROM ubuntu:20.04 as base

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y && apt-get install -y \
    curl \
    unzip \
    gnupg \
    grep \
    git \
    python3 \
    python3-pip

# Terraform
ARG TERRAFORM_VERSION=1.1.3
ARG TERRAFORM_LINTER=0.33.0
RUN curl -#L -o terraform_${TERRAFORM_VERSION}_linux_amd64.zip https://releases.hashicorp.com/terraform/$TERRAFORM_VERSION/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    curl -#L -o terraform_SHA256SUMS https://releases.hashicorp.com/terraform/$TERRAFORM_VERSION/terraform_${TERRAFORM_VERSION}_SHA256SUMS && \
    curl -#L -o terraform_SHA256SUMS.sig https://releases.hashicorp.com/terraform/$TERRAFORM_VERSION/terraform_${TERRAFORM_VERSION}_SHA256SUMS.sig && \
    curl https://keybase.io/hashicorp/key.asc  | gpg --import && \
    gpg --verify terraform_SHA256SUMS.sig terraform_SHA256SUMS && \
    cat terraform_SHA256SUMS | grep linux_amd64 > terraform_SHA256SUMS_single && \
    sha256sum -c terraform_SHA256SUMS_single && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    install -t /usr/local/bin terraform && \
    rm terraform terraform_${TERRAFORM_VERSION}_linux_amd64.zip terraform_SHA256SUMS.sig terraform_SHA256SUMS terraform_SHA256SUMS_single  && \
    # terraform lint
    curl -#L -o tflint.zip https://github.com/terraform-linters/tflint/releases/download/v${TERRAFORM_LINTER}/tflint_linux_amd64.zip && \
    unzip tflint.zip && rm tflint.zip && \
    install -t /usr/local/bin tflint && rm tflint

# INSTALL INCVOKE
RUN pip3 install tomlkit invoke==1.6.0

# Azure Cli
ARG AZURECLI_VERSION=2.30.0
RUN pip3 install azure-cli==$AZURECLI_VERSION --no-cache-dir

ENV DEBIAN_FRONTEND=dialog


#################### dev-environment ####################
##### User: dev
##########################################################
FROM base AS dev
ENV DEBIAN_FRONTEND=noninteractive
ARG USERNAME=dev
ARG USER_UID=1000
ARG USER_GID=$USER_UID
#
#Install specific devtools
RUN apt-get update && apt-get install --no-install-recommends -y \
    vim \
    ssh \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* 
#
# Install Pylint
RUN pip3 install --no-cache-dir pylint==2.6.0
#
# Create a non-root user to use if preferred - see https://aka.ms/vscode-remote/containers/non-root-user.
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME
#
# Clean up
RUN apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*
#Switch back to dialog
ENV DEBIAN_FRONTEND=dialog