# syntax=docker/dockerfile:1.7

##
## Stage 1: Setup Dependency Images
##
FROM golang:1.25-bookworm as go-src
FROM node:24-bookworm-slim AS node-src
FROM ghcr.io/zizmorcore/zizmor:1.21.0 AS zizmor-src
FROM ghcr.io/jqlang/jq:1.8.1 AS jq-src
FROM hadolint/hadolint:v2.14.0-debian AS hadolint-src
FROM rhysd/actionlint:1.7.8 AS actionlint-src
FROM mvdan/shfmt:v3.12.0 AS shfmt-src
FROM mikefarah/yq:4.50.1 AS yq-src
FROM hairyhenderson/gomplate:v4.3.3 AS gomplate-src
FROM ghcr.io/wagoodman/dive:v0.13.1 as dive-src

##
## Stage 2: runtime (Ubuntu latest LTS)
##
FROM ubuntu:noble-20260113

LABEL org.opencontainers.image.title="Development container for mtgjson cli" \
    org.opencontainers.image.description="Development environment with Node.js, golang, and various other tools" \
    org.opencontainers.image.url="https://github.com/garbee/mtgjson-cli" \
    org.opencontainers.image.source="https://github.com/garbee/mtgjson-cli" \
    org.opencontainers.image.documentation="https://github.com/garbee/mtgjson-cli" \
    org.opencontainers.image.vendor="Jonathan Garbee" \
    org.opencontainers.image.licenses="CC-PDM-1.0" \
    org.opencontainers.image.authors="Jonathan Garbee"

# Tighten defaults a bit
ENV DEBIAN_FRONTEND=noninteractive \
    NODE_ENV=development \
    GOROOT=/usr/local/go \
    GOPATH=/opt/go \
    GOCACHE=/var/cache/go-build \
    GOMODCACHE=/var/cache/go/pkg/mod \
    NPM_CONFIG_PREFIX=/usr/local \
    PATH="/home/ubuntu/.local/bin:/usr/local/lib/node_modules/bin:/usr/local/go/bin:/usr/local/bin:/usr/bin:${PATH}"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN <<EOF
set -euxo pipefail
groupadd -r node
groupadd -r docker
usermod -aG node ubuntu
usermod -aG staff ubuntu
usermod -aG docker ubuntu
usermod -aG docker root
mkdir -p /usr/local/lib/node_modules
chown -R root:node /usr/local/lib/node_modules /usr/local/bin
chmod -R 775 /usr/local/lib/node_modules /usr/local/bin
mkdir -p /etc/apt/keyrings
chmod 755 /etc/apt/keyrings
mkdir -p /etc/apt/sources.list.d
chmod 755 /etc/apt/sources.list.d
EOF

# Bring in toolchains/artifacts (optimized with --link)
COPY --link --from=hadolint-src   /bin/hadolint /usr/local/bin/
COPY --link --from=jq-src          /jq     /usr/local/bin/jq
COPY --link --from=yq-src          /usr/bin/yq     /usr/local/bin/yq
COPY --link --from=zizmor-src      /usr/bin/zizmor /usr/local/bin/zizmor
COPY --link --from=shfmt-src       /bin/              /usr/local/bin/
COPY --link --from=gomplate-src    /gomplate         /usr/local/bin/gomplate
COPY --link --from=dive-src        /usr/local/bin/dive     /usr/local/bin/dive
## Actionlint also has shellcheck in its bin
COPY --link --from=actionlint-src  /usr/local/bin/ /usr/local/bin/

# Copy Go toolchain (GOROOT)
COPY --link --from=go-src /usr/local/go/ /usr/local/go/

# Symlink-dependent toolchains (cannot use --link)
COPY --from=node-src /usr/local/ /usr/local/
COPY --from=node-src /opt /opt

RUN --mount=type=cache,target=/var/cache/apt,id=apt-archives,sharing=shared \
    --mount=type=cache,target=/var/lib/apt/lists,id=apt-lists,sharing=locked \
    <<EOF
set -euxo pipefail

apt-get update
# In order to get apt-add-repository we need to install software-properties-common
# Then we install all the main packages at once.
apt-get install -y --no-install-recommends software-properties-common curl
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null
chmod 0044 /etc/apt/keyrings/githubcli-archive-keyring.gpg
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | tee /etc/apt/keyrings/docker.asc > /dev/null
chmod 0044 /etc/apt/keyrings/docker.asc
add-apt-repository ppa:git-core/ppa -y
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install -y --no-install-recommends \
ca-certificates libstdc++6 \
wget bat fzf eza bash-completion \
lsb-release unzip gnupg gnupg2 git gh \
sudo gosu \
skopeo \
docker-ce-cli docker-buildx-plugin docker-compose-plugin

rm -rf /var/lib/apt/lists/*

# Setup sudo access
echo "ubuntu ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ubuntu
chmod 0440 /etc/sudoers.d/ubuntu

# Global npm configuration
## This sets config for both root and regular users.
## Use the heredoc syntax so we also get comments in the image for reference in-use.
cat > /usr/local/etc/npmrc <<EONPMRC
# We don't care to hear about npm updates. It will happen with the image
update-notifier=false
## Disable funding messages and automatic audits
fund=false
audit=false
## Prefer the offline modules when possible to speed up installs
## Particularly useful in CI environments with caching enabled
prefer-offline=true
## Help network or registry issues by massaging the network config
## It is balanced to slowly back off up to the 120ms max on the
## final attempt.
## It should go like this: 3.75s, 7.5s, 15s, 30s, 60s, 120s.
## We politely back-off and delay instead of rushing retries
## so the registry isn't hammered to cause an outage.
fetch-retries=6
fetch-retry-factor=2
fetch-retry-mintimeout=3750
fetch-retry-maxtimeout=120000
## Setup logging to be more efficient for containers
## Keep the default log level, but discard logs going to a fail.
loglevel=notice
logs-dir=/dev/null
## We want to get away from auto-running scripts entirely.
## Until then, at least don't hide them so we are aware of them.
foreground-scripts=true
EONPMRC

npm install -g --omit=dev @dougis/markdown-lint-mcp@1.0.4 markdownlint@0.40.0
npm cache clean --force

go install golang.org/x/tools/gopls@v0.21.0

rm -rf /tmp/*

EOF

WORKDIR /workspace
