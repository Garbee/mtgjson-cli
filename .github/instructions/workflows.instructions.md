---
applyTo: ".github/workflows/*.yml"
---

# GitHub Actions Workflow Instructions

These instructions govern how GitHub Actions workflows are authored and
maintained. All workflows follow Trunk Based Development and must be
designed for idempotent, waste-free execution.

## Trunk Based Development

The `main` branch is the single source of truth. Every workflow must
reflect this:

* **Push triggers** should by default target only `main`. Configure
  additional branches only when there is a specific, documented reason
  in the workflow file (for example, validating workflow changes via
  `paths` filters), rather than for long-lived feature branches.
* **Pull request triggers** should by default target `main` as the base
  branch. If you need PR workflows for other base branches, document the
  rationale in the workflow file.
* Short-lived branches merge into `main` through pull requests. Do not
  design workflows that depend on branch hierarchies or cascading merges.
* Exclude automated branch prefixes from push triggers using
  `branches-ignore` when the workflow should not run for those pushes
  (e.g., `copilot/**`, `dependabot/**`).

## Reducing Waste

Every workflow run costs compute time. Minimize unnecessary runs:

### Concurrency

Every workflow must define a concurrency group that cancels redundant
in-progress runs for the same branch or pull request:

```yaml
concurrency:
  group: ${{ github.workflow }}-${{ github.head_ref || github.ref_name }}
  cancel-in-progress: true
```

For workflows where push-to-main runs must complete (e.g., deployments),
gate cancellation on the event type:

```yaml
cancel-in-progress: ${{ github.event_name != 'push' }}
```

### Path Filters and Required Checks

When a new workflow is needed, first determine whether it will be part of
a required status check for pull requests:

* **Required checks** must not use `paths` filters. Add the check as a
  new job in the existing `basic-lint.yml` workflow (or a similar
  event-driven workflow) so it runs on every relevant push and pull
  request. This prevents pull requests from being unmergeable due to a
  missing required status.
* **Non-required workflows** should use `paths` filters on both `push`
  and `pull_request` triggers so they only run when relevant files
  change. For example, a workflow that builds Docker images should not
  re-run when only documentation changes.

### Timeouts

Set `timeout-minutes` on jobs that interact with external services or
perform builds. This prevents hung jobs from consuming runner minutes
indefinitely.

### Minimal Permissions

Set the top-level `permissions` to the most restrictive value possible,
then grant only the specific permissions each job requires:

```yaml
permissions:
  contents: read

jobs:
  example:
    permissions:
      contents: read
      packages: write
```

If no permissions are needed at the workflow level, use:

```yaml
permissions: {}
```

## Idempotency

Running the same workflow on the same commit must produce the same
result. All external references must be pinned to immutable identifiers:

### Action Versions

Pin every `uses` reference to the full commit SHA of the release. Add a
trailing comment with the human-readable version tag:

```yaml
- uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2
```

Never reference actions by mutable tag alone (e.g., `@v4`, `@main`).

### Container Images

Pin container images to their `sha256` digest. Add a trailing comment
with the human-readable tag for maintainability:

```yaml
container:
  image: ghcr.io/owner/image@sha256:abc123... # tag-name
```

### Checkout Configuration

Always set `persist-credentials: false` on `actions/checkout` to prevent
the token from leaking into subsequent steps:

```yaml
- uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2
  with:
    persist-credentials: false
```

### Shell Scripts

Use `set -euoC pipefail` at the top of every Bash script invoked by a
workflow. This ensures scripts fail fast on errors and do not silently
swallow failures.

## Naming and Structure

* Use `kebab-case` for workflow file names.
* Give every workflow a human-readable `name` field at the top level.
* Give every job a human-readable `name` field.
* Give every step a descriptive `name` field.

## Runner Selection

Prefer pinning to a specific runner image version (e.g., `ubuntu-24.04`)
rather than using floating aliases (e.g., `ubuntu-latest`). This avoids
unexpected behavior when the alias rolls to a new image.

## Dev Container Execution

Every workflow job must run inside the project's dev container image so
that all tooling is available and consistent with local development. Set
the `container` key on each job to the pinned dev container image:

```yaml
jobs:
  example:
    runs-on: ubuntu-24.04
    container:
      image: ghcr.io/garbee/mtgjson-cli-devcontainer@sha256:<digest> # <tag>
```

Follow the [Container Images](#container-images) pinning rules: always
reference the image by its `sha256` digest and include a trailing
comment with the human-readable tag.

### Exceptions

A small number of workflows cannot run inside the dev container. When
a job must run directly on the runner, add a comment in the workflow
file explaining why the container is not used. Known exceptions:

* **Copilot Setup Steps** (`copilot-setup-steps.yml`) — the Copilot
  agent bootstrap process requires running directly on the runner host
  rather than inside a container.
* **CodeQL Advanced** (`codeql.yml`) — CodeQL analysis requires native
  runner access for optimal performance and compatibility with the
  CodeQL tooling.
* **PR Cache Cleanup** (`pr-cache-cleanup.yml`) — this job only needs
  the `gh` CLI (pre-installed on GitHub-hosted runners) and has no
  project tooling dependencies, so the dev container is unnecessary.
