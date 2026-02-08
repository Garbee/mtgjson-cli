#!/usr/bin/env bash
set -euoC pipefail

: "${GITHUB_STEP_SUMMARY:?GITHUB_STEP_SUMMARY must be set}"
: "${GITHUB_ENV:?GITHUB_ENV must be set}"

{
  echo '<details><summary>ls-lint output</summary>'
  echo ''
  echo '```'
} >> "$GITHUB_STEP_SUMMARY"

set +e
ls-lint >> "$GITHUB_STEP_SUMMARY" 2>&1
LSLINT_EXIT=$?
set -e

{
  echo '```'
  echo '</details>'
} >> "$GITHUB_STEP_SUMMARY"

echo "LSLINT_EXIT=$LSLINT_EXIT" >> "$GITHUB_ENV"
