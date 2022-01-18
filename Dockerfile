FROM ubuntu:20.04 as base

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
