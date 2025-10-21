ARG REPOSITORY="docker.io"
FROM ${REPOSITORY}/library/debian:bookworm-20250224-slim
#upgrade to trixie when software-properties-common are available for trixie

LABEL MAINTAINER=deb4sh@github
LABEL org.opencontainers.image.source=https://github.com/deB4SH/KubernetesAzureAgent

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
    software-properties-common \
    gettext-base \
    unzip \
    wget

#Install Kubernetes
RUN   curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" --output-dir /usr/local/bin \
    && chmod +x /usr/local/bin/kubectl


#Install KubeSeal
RUN curl -L https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.19.4/kubeseal-0.19.4-linux-amd64.tar.gz -o kubeseal-0.19.4-linux-amd64.tar.gz \
    && tar xfv kubeseal-0.19.4-linux-amd64.tar.gz -C /usr/local/bin

#Install Helm & Helm-Diff & Helmfile
ENV HELM_PLUGINS="/home/worker/.local/helm-plugin"
RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 \
    && chmod 700 get_helm.sh \
    && sh -c ./get_helm.sh \
    && helm plugin install https://github.com/databus23/helm-diff \
    && chown -R worker:worker /home/worker/.local/helm-plugin \
    && curl -L https://github.com/helmfile/helmfile/releases/download/v0.166.0/helmfile_0.166.0_linux_amd64.tar.gz -o  helmfile_0.166.0_linux_amd64.tar.gz \
    && tar xfv helmfile_0.166.0_linux_amd64.tar.gz -C /usr/local/bin

#Install argocd cli
RUN curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64 && \
    install -m 555 argocd-linux-amd64 /usr/local/bin/argocd && \
    rm argocd-linux-amd64

#Install Kustomize
RUN curl -L https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv5.0.0/kustomize_v5.0.0_linux_amd64.tar.gz -o kustomize_v5.0.0_linux_amd64.tar.gz && \
    tar xfv kustomize_v5.0.0_linux_amd64.tar.gz -C /usr/local/bin

#Install java and maven
RUN apt install openjdk-17-jdk maven -y

#install dependencies for dotNetcore & Install DotNet
RUN wget https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb -O packages-microsoft-prod.deb \
    && dpkg -i packages-microsoft-prod.deb \
    && rm packages-microsoft-prod.deb \
    && apt-get update \
    && apt install -y libssl3 libkrb5-3 zlib1g debsums icu-devtools libicu-dev icu-doc libicu72 \
    && apt-get install -y dotnet-sdk-8.0

#Install AzureCli
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

WORKDIR /azp

COPY /src/docker/azure-scripts/start.sh .
COPY /src/docker/scripts/entrypoint.sh .
RUN chmod +x start.sh entrypoint.sh

#clean up leftovers
RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* \
    && rm -rf /var/tmp/*

USER worker
ENTRYPOINT [ "./entrypoint.sh", "-f", "/azp/init" ]
#FOR DEBUG PURPOSES
#ENTRYPOINT ["tail", "-f", "/dev/null"]