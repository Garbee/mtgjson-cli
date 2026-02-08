---
applyTo: "**"
---

# Conventional Commits

All commits in this repository must follow the
[Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/)
specification. This applies to every commit message, PR title, and
squash-merge title produced or reviewed by Copilot.

## Commit Message Format

Every commit message must use the following structure:

```text
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Type

The type must be one of the following lowercase keywords:

* **feat** — introduces a new feature (correlates with MINOR in
  Semantic Versioning)
* **fix** — patches a bug (correlates with PATCH in Semantic Versioning)
* **docs** — documentation-only changes
* **style** — changes that do not affect the meaning of the code (white
  space, formatting, missing semicolons, etc.)
* **refactor** — a code change that neither fixes a bug nor adds a
  feature
* **perf** — a code change that improves performance
* **test** — adding missing tests or correcting existing tests
* **build** — changes that affect the build system or external
  dependencies
* **ci** — changes to CI configuration files and scripts
* **chore** — other changes that do not modify source or test files

### Scope

An optional noun in parentheses immediately after the type, describing
the section of the codebase affected. For example: `feat(parser):`,
`fix(api):`, `docs(readme):`.

### Breaking Changes

A commit that introduces a breaking API change must either:

1. Append `!` after the type/scope, before the colon:
   `feat!: remove deprecated endpoint`
2. Include a `BREAKING CHANGE:` footer in the commit body.

Breaking changes correlate with MAJOR in Semantic Versioning.

### Description

The description is a short summary of the change:

* Use the imperative, present tense (e.g., "add", not "added" or
  "adds")
* Do not capitalize the first letter
* Do not end with a period

### Body

An optional longer description providing additional context. Separate
from the description with a blank line. Use the imperative, present
tense.

### Footer

Optional footers follow the
[git trailer](https://git-scm.com/docs/git-interpret-trailers) format.
Common footers include:

* `BREAKING CHANGE: <description>` — documents a breaking change
* `Refs: #<issue>` — references related issues
* `Reviewed-by: <name>` — credits reviewers

## Examples

Simple feature:

```text
feat: add card search by set code
```

Bug fix with scope:

```text
fix(parser): handle missing mana cost field
```

Breaking change with body and footer:

```text
feat(api)!: change response format for card endpoint

The card endpoint now returns a flat object instead of a nested
structure. All consumers must update their parsing logic.

BREAKING CHANGE: card endpoint response shape changed from nested to flat
```

Documentation change:

```text
docs: update installation instructions for v2
```

Chore with scope:

```text
chore(deps): upgrade Go to 1.25
```

## PR Titles

Pull request titles must also follow this format. When a PR is
squash-merged, the PR title becomes the merge commit message and must
be a valid conventional commit.

## Reviewing for Compliance

When reviewing a pull request, check the following:

1. **PR title** follows `<type>[optional scope]: <description>` format
2. **Type** is one of the allowed types listed above
3. **Description** uses imperative mood, starts lowercase, has no
   trailing period
4. **Breaking changes** are properly annotated with `!` or a
   `BREAKING CHANGE:` footer
5. **Scope**, if present, is a lowercase noun in parentheses
6. **Individual commit messages** in the PR follow the same format

Report any violations clearly, quoting the problematic title or message
and explaining which rule it breaks.
