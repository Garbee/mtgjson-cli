#!/usr/bin/env bash

set -euo pipefail

# Install starship for the interactive terminal with sudo
echo "Installing starship prompt..."
curl -sS https://starship.rs/install.sh | sudo sh -s -- --bin-dir /usr/local/bin -y > /dev/null

# Install Gemini CLI
echo "Installing Gemini CLI..."
pnpm install -g @google/gemini-cli

# Install Claude Code
echo "Installing Claude Code..."
curl -fsSL https://claude.ai/install.sh | bash > /dev/null
