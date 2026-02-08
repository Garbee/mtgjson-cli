#!/usr/bin/env bash
set -euoC pipefail

: "${GITHUB_SUMMARY:?GITHUB_SUMMARY must be set}"
: "${GITHUB_ENV:?GITHUB_ENV must be set}"

{
  echo '<details><summary>ls-lint output</summary>'
  echo ''
  echo '```'
} >> "$GITHUB_SUMMARY"

set +e
ls-lint >> "$GITHUB_SUMMARY" 2>&1
LSLINT_EXIT=$?
set -e

{
  echo '```'
  echo '</details>'
} >> "$GITHUB_SUMMARY"

echo "LSLINT_EXIT=$LSLINT_EXIT" >> "$GITHUB_ENV"
