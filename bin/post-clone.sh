#!/usr/bin/env bash
# This script is intended for use after cloning the repository.
# It sets up useful config for development, such as git hooks.

# Check if git config is already set, if not set it.
if ! git config --local core.hooksPath &> /dev/null; then
    git config --local core.hooksPath .githooks
fi
