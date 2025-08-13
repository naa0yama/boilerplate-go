# syntax=docker/dockerfile:1
#- -------------------------------------------------------------------------------------------------
#- Global
#-
ARG DEBIAN_FRONTEND=noninteractive \
	TZ

FROM golangci/golangci-lint:v2.3.1 AS golangci-lint

#- -------------------------------------------------------------------------------------------------
#- Base
#-
FROM golang:1.24-bookworm as base
ARG DEBIAN_FRONTEND \
	TZ

SHELL [ "/bin/bash", "-c" ]

# set Timezone
RUN set -euxo pipefail && \
	ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Create user
RUN set -euxo pipefail && \
	groupadd --gid 60001 user && \
	useradd -s /bin/bash --uid 60001 --gid 60001 -m user && \
	echo user:password | chpasswd && \
	passwd -d user


#- -------------------------------------------------------------------------------------------------
#- Development
#-
FROM base as dev
ARG DEBIAN_FRONTEND

RUN set -euxo pipefail && \
	apt-get -y update && \
	apt-get -y upgrade && \
	apt-get -y install --no-install-recommends \
	bash \
	ca-certificates \
	curl \
	git \
	gpg-agent \
	jq \
	nano \
	openssh-client \
	patchelf \
	software-properties-common \
	sudo \
	wget \
	&& \
	\
	# Cleanup \
	apt-get -y autoremove && \
	apt-get -y clean && \
	rm -rf /var/lib/apt/lists/*

# Add sudo user
RUN set -euxo pipefail && \
	echo -e "user\tALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/user

# Add Biome latest install
RUN set -euxo pipefail && \
	curl -fSL -o /usr/local/bin/biome "$(curl -sfSL https://api.github.com/repos/biomejs/biome/releases/latest | \
	jq -r '.assets[] | select(.name | endswith("linux-x64")) | .browser_download_url')" && \
	chmod +x /usr/local/bin/biome && \
	type -p biome

# Go tools
# https://github.com/golang/vscode-go/wiki/tools
COPY --from=golangci-lint /usr/bin/golangci-lint /usr/local/bin/golangci-lint

RUN set -euxo pipefail && \
	go install golang.org/x/tools/gopls@latest && \
	go install github.com/cweill/gotests/gotests@v1.6.0 && \
	go install github.com/josharian/impl@v1.4.0 && \
	go install github.com/haya14busa/goplay/cmd/goplay@v1.0.0 && \
	go install github.com/go-delve/delve/cmd/dlv@latest && \
	go install honnef.co/go/tools/cmd/staticcheck@latest

# User level settings
USER user

# vim: set filetype=dockerfile:
