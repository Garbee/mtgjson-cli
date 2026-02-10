# syntax=docker/dockerfile:1

##
## Stage 1: Setup Dependency Images
##
FROM golang:1.25-bookworm AS go-src
FROM node:24-bookworm-slim AS node-src
FROM ghcr.io/zizmorcore/zizmor:1.22.0 AS zizmor-src
FROM ghcr.io/jqlang/jq:1.8.1 AS jq-src
FROM hadolint/hadolint:v2.14.0-debian AS hadolint-src
FROM rhysd/actionlint:1.7.10 AS actionlint-src
FROM mvdan/shfmt:v3.12.0 AS shfmt-src
FROM mikefarah/yq:4.52.2 AS yq-src
FROM hairyhenderson/gomplate:v4.3.3 AS gomplate-src
FROM ghcr.io/wagoodman/dive:v0.13.1 AS dive-src
FROM lslintorg/ls-lint:1.11.2 AS lslint-src
FROM ghcr.io/orhun/git-cliff/git-cliff:2.12.0 AS git-cliff-src

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
    PNPM_HOME=/opt/pnpm \
    PNPM_STORE_PATH=/pnpm-store \
    PATH="/home/ubuntu/.local/bin:/usr/local/lib/node_modules/bin:/opt/pnpm:/usr/local/go/bin:/usr/local/bin:/usr/bin:${PATH}"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN <<EOF
set -euxo pipefail
GLOBAL_NODE_MODULES="/usr/local/lib/node_modules"
groupadd -r docker
usermod -aG staff ubuntu
usermod -aG docker ubuntu
usermod -aG docker root
chown -R root:staff /usr/local/bin
mkdir -p "${GLOBAL_NODE_MODULES}"
mkdir -p /etc/apt/keyrings
chmod 755 /etc/apt/keyrings
mkdir -p /etc/apt/sources.list.d
chmod 755 /etc/apt/sources.list.d
mkdir -p "${PNPM_HOME}" "${PNPM_STORE_PATH}"
chmod -R 0775 "${PNPM_HOME}" "${GLOBAL_NODE_MODULES}" /usr/local/bin
chmod -R 0777 "${PNPM_STORE_PATH}"
chown -R ubuntu:staff "${PNPM_HOME}" "${PNPM_STORE_PATH}" "${GLOBAL_NODE_MODULES}"
chmod -R g+sw "${PNPM_HOME}" "${PNPM_STORE_PATH}" "${GLOBAL_NODE_MODULES}"
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
COPY --link --from=lslint-src  /ls-lint /usr/local/bin/
COPY --link --from=git-cliff-src  /usr/local/bin/git-cliff /usr/local/bin/git-cliff

# Copy Go toolchain (GOROOT)
COPY --link --from=go-src \
  --chown=0:50 \
  --exclude=**/CONTRIBUTING.md \
  --exclude=**/README.md \
  --exclude=**/SECURITY.md \
  --exclude=test/ \
  --exclude=test/* \
  /usr/local/go/ /usr/local/go/

# Symlink-dependent toolchains (cannot use --link)
COPY --from=node-src \
  --chown=0:50 \
  --exclude=*CHANGELOG.md \
  --exclude=*README.md \
  --exclude=bin/docker-entrypoint.sh \
  /usr/local/ /usr/local/
COPY --from=node-src \
  --chown=0:50 \
  /opt /opt

# This is for dev, we don't want to pin and cause more updates to the file.
# hadolint ignore=DL3008
RUN --mount=type=cache,target=/var/cache/apt,id=apt-archives,sharing=shared \
    --mount=type=cache,target=/var/lib/apt/lists,id=apt-lists,sharing=locked \
    <<EOF
set -euxo pipefail

apt-get update
# In order to get apt-add-repository we need to install software-properties-common
# Then we install all the main packages at once.
apt-get install -y --no-install-recommends software-properties-common curl apt-utils
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
lsb-release unzip gnupg gnupg2 git gh git-delta openssh-client \
sudo gosu \
skopeo \
docker-ce-cli docker-buildx-plugin docker-compose-plugin \
neovim ripgrep fd-find

# Setup sudo access with proper validation
install -m 0440 -o root -g root /dev/null /etc/sudoers.d/ubuntu
cat > /etc/sudoers.d/ubuntu <<EOSUDOERS
# Allow ubuntu user to run any command without password
ubuntu ALL=(ALL:ALL) NOPASSWD:ALL
EOSUDOERS
# Validate the sudoers file before continuing
visudo -c -f /etc/sudoers.d/ubuntu

ARCH=$(dpkg --print-architecture)

if [ "$ARCH" != "amd64" ] && [ "$ARCH" != "arm64" ]; then
  echo "Unsupported architecture: $ARCH"
  exit 1
fi

if [ "$ARCH" = "amd64" ]; then
  MITMPROXY_ARCH="x86_64"
elif [ "$ARCH" = "arm64" ]; then
  MITMPROXY_ARCH="aarch64"
fi
# Download and extract mitmproxy
curl -fsSL "https://downloads.mitmproxy.org/12.2.1/mitmproxy-12.2.1-linux-${MITMPROXY_ARCH}.tar.gz" | tar xz -C /usr/local/bin/

# Install pnpm globally
curl -fsSL https://get.pnpm.io/install.sh | \
  env PNPM_HOME="${PNPM_HOME}" \
      SHELL=/bin/bash \
  bash -

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
##### PNPM configuration beyond this point
## Only install packages after they have been released for at least 7 days.
minimumReleaseAge=10080
## Allowed packages to run postinstall scripts. Each set here
## should be under a group that is a comment of the package that introduced it.
#### For: @google/gemini-cli
only-built-dependencies[]=node-pty
only-built-dependencies[]=protobufjs
only-built-dependencies[]=keytar
only-built-dependencies[]=tree-sitter-bash
EONPMRC

# Install GitHub copilot
curl -fsSL https://gh.io/copilot-install | bash

gosu ubuntu pnpm add -g \
  @dougis/markdown-lint-mcp@1.0.4 \
  markdownlint@0.40.0 \
  markdownlint-cli2@0.20.0 \
  cspell-cli@9.6.0

go install golang.org/x/tools/gopls@v0.21.0

rm -rf /tmp/*

EOF

WORKDIR /workspace
