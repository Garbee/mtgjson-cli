#!/usr/bin/env bash

set -euoC pipefail

: "${LSLINT_EXIT:?LSLINT_EXIT must be set}"
: "${MARKDOWNLINT_EXIT:?MARKDOWNLINT_EXIT must be set}"
: "${GITHUB_REPOSITORY:?GITHUB_REPOSITORY must be set}"
: "${GITHUB_RUN_ID:?GITHUB_RUN_ID must be set}"

if [[ "$LSLINT_EXIT" -eq 0 && "$MARKDOWNLINT_EXIT" -eq 0 ]]; then
  echo "All linters passed successfully!"
  exit 0
fi

echo "One or more linters failed:"
[[ "$LSLINT_EXIT" -ne 0 ]] && echo "  - ls-lint exited with code $LSLINT_EXIT"
[[ "$MARKDOWNLINT_EXIT" -ne 0 ]] && echo "  - markdownlint-cli2 exited with code $MARKDOWNLINT_EXIT"
echo ""
echo "View detailed output in the run summary:"
echo "https://github.com/$GITHUB_REPOSITORY/actions/runs/$GITHUB_RUN_ID"
exit 1
