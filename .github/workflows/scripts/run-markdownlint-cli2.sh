#!/usr/bin/env bash
set -euoC pipefail

: "${GITHUB_STEP_SUMMARY:?GITHUB_STEP_SUMMARY must be set}"
: "${GITHUB_ENV:?GITHUB_ENV must be set}"

{
  echo '<details><summary>markdownlint-cli2 output</summary>'
  echo ''
  echo '```'
} >> "$GITHUB_STEP_SUMMARY"

set +e
pnpm dlx markdownlint-cli2 '**/*.md' >> "$GITHUB_STEP_SUMMARY" 2>&1
MARKDOWNLINT_EXIT=$?
set -e

{
  echo '```'
  echo '</details>'
} >> "$GITHUB_STEP_SUMMARY"

echo "MARKDOWNLINT_EXIT=$MARKDOWNLINT_EXIT" >> "$GITHUB_ENV"
