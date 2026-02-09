#!/usr/bin/env bash
set -euoC pipefail

: "${GH_TOKEN:?GH_TOKEN must be set}"
: "${REPO:?REPO must be set}"
: "${PR_NUMBER:?PR_NUMBER must be set}"

BRANCH="refs/pull/${PR_NUMBER}/merge"
echo "Deleting GitHub Actions caches for ref: ${BRANCH}"

gh api \
  -H "Accept: application/vnd.github+json" \
  "/repos/${REPO}/actions/caches?ref=${BRANCH}" \
  --paginate \
  --jq '.actions_caches[].id' | \
while IFS= read -r cache_id; do
  echo "Deleting cache ID: ${cache_id}"
  gh api \
    --method DELETE \
    -H "Accept: application/vnd.github+json" \
    "/repos/${REPO}/actions/caches/${cache_id}" || \
    echo "Warning: failed to delete cache ${cache_id}"
done

echo "Cache cleanup complete."
