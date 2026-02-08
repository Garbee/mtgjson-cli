#!/usr/bin/env bash

# This script executes after attachment to the container.
# It may run multiple times, thus everything must be idempotent.

set -euo pipefail

thisScriptPath="$(realpath "${BASH_SOURCE[0]}")"
thisScriptDir="$(dirname "$thisScriptPath")"
devcontainerRootDir="$(dirname "$thisScriptDir")"

INCLUDE_PATH="${devcontainerRootDir}/.devcontainer/gitconfig"

# Setup needed includes to redirect some operations to vscode instead
# of host programs.
if ! git config --global --get-all include.path 2>/dev/null | grep -Fxq "$INCLUDE_PATH"; then
  git config --global --add include.path "$INCLUDE_PATH"
fi

# If delta is not already configured from the host, set it up as the pager
# and for interactive diffs and merges.
if ! git config --global --get core.pager >/dev/null; then
  git config --global core.pager "delta"
  git config --global delta.navigate true
  git config --global delta.dark true
fi

if ! git config --global --get interactive.diffFilter >/dev/null; then
  git config --global interactive.diffFilter "delta --color-only"
fi

# Setup pnpm completion
if [ -f "$HOME/.bashrc" ] && ! grep -Eq 'pnpm[[:space:]]+completions[[:space:]]+bash' "$HOME/.bashrc"; then
  cat >> "$HOME/.bashrc" <<'EOF'
# --- pnpm completions ---
eval "$(pnpm completion bash)"
# -----------------------
EOF
elif [ ! -f "$HOME/.bashrc" ]; then
  cat > "$HOME/.bashrc" <<'EOF'
# --- pnpm completions ---
eval "$(pnpm completion bash)"
# -----------------------
EOF
fi

if [ -f "$HOME/.bashrc" ] && ! grep -Eq 'starship[[:space:]]+init[[:space:]]+bash' "$HOME/.bashrc"; then
  cat >> "$HOME/.bashrc" <<'EOF'

# --- Starship prompt ---
eval "$(starship init bash)"
# -----------------------

EOF
elif [ ! -f "$HOME/.bashrc" ]; then
  cat > "$HOME/.bashrc" <<'EOF'
# --- Starship prompt ---
eval "$(starship init bash)"
# -----------------------
EOF
fi
