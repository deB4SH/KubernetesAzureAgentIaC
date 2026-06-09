ARG REPOSITORY="docker.io"
FROM ${REPOSITORY}/library/debian:trixie-20260518-slim
#upgrade to trixie when software-properties-common are available for trixie

LABEL MAINTAINER=deb4sh@github
LABEL org.opencontainers.image.source=https://github.com/deB4SH/KubernetesAzureAgentIaC

# Can be 'linux-x64', 'linux-arm64', 'linux-arm', 'rhel.6-x64'.
ENV TARGETARCH=linux-x64
ENV DEBIAN_FRONTEND=noninteractive

# add user
RUN mkdir /azp \
    && useradd -ms /bin/bash worker \
    && mkdir -p /home/worker/.local/bin \
    && chown -R worker:worker /azp \
    && chown -R worker:worker /home/worker/.local
ENV PATH="$PATH:/home/worker/.local/bin"

#Install general dependencies
RUN apt-get update && apt-get upgrade -y \
    && apt-get install -y -qq --no-install-recommends \
    apt-transport-https \
    apt-utils \
    ca-certificates \
    curl \
    git \
    iputils-ping \
    jq \
    lsb-release \
    gnupg \
    gettext-base \
    unzip \
    wget

#Install Kubernetes
RUN   curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" --output-dir /usr/local/bin \
    && chmod +x /usr/local/bin/kubectl

#Install Terraform
RUN wget https://releases.hashicorp.com/terraform/1.15.5/terraform_1.15.5_linux_amd64.zip \
    && unzip terraform_1.15.5_linux_amd64.zip -d terraform_1.15.5_linux_amd64  \
    && mv terraform_1.15.5_linux_amd64/terraform /usr/local/bin/terraform \
    && chmod +x /usr/local/bin/terraform


#Install OpenTofu
RUN install -m 0755 -d /etc/apt/keyrings \
    && curl -fsSL https://get.opentofu.org/opentofu.gpg | tee /etc/apt/keyrings/opentofu.gpg >/dev/null \
    && curl -fsSL https://packages.opentofu.org/opentofu/tofu/gpgkey | gpg --no-tty --batch --dearmor -o /etc/apt/keyrings/opentofu-repo.gpg >/dev/null \
    && chmod a+r /etc/apt/keyrings/opentofu.gpg /etc/apt/keyrings/opentofu-repo.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/opentofu.gpg,/etc/apt/keyrings/opentofu-repo.gpg] https://packages.opentofu.org/opentofu/tofu/any/ any main" >> /etc/apt/sources.list.d/opentofu.list \
    && chmod a+r /etc/apt/sources.list.d/opentofu.list \
    && apt-get update \
    && apt-get install -y tofu

WORKDIR /azp

COPY /src/docker/azure-scripts/start.sh .
COPY /src/docker/scripts/entrypoint.sh .
RUN chmod +x start.sh entrypoint.sh

#clean up leftovers
RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* \
    && rm -rf /var/tmp/*

#check runtimes
RUN tofu -version \
    && terraform -version

USER worker
ENTRYPOINT [ "./entrypoint.sh", "-f", "/azp/init" ]
#FOR DEBUG PURPOSES
#ENTRYPOINT ["tail", "-f", "/dev/null"]
