#!/usr/bin/env bash
set -euoC pipefail

: "${GITHUB_SUMMARY:?GITHUB_SUMMARY must be set}"
: "${GITHUB_ENV:?GITHUB_ENV must be set}"

{
  echo '<details><summary>markdownlint-cli2 output</summary>'
  echo ''
  echo '```'
} >> "$GITHUB_SUMMARY"

set +e
pnpm dlx markdownlint-cli2 '**/*.md' >> "$GITHUB_SUMMARY" 2>&1
MARKDOWNLINT_EXIT=$?
set -e

{
  echo '```'
  echo '</details>'
} >> "$GITHUB_SUMMARY"

echo "MARKDOWNLINT_EXIT=$MARKDOWNLINT_EXIT" >> "$GITHUB_ENV"
