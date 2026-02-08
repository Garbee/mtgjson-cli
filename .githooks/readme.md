# Git Hooks

## Overview

Git hooks are scripts that run automatically at specific points in your Git workflow. They enable you to enforce quality standards, run tests, and automate repetitive tasks before commits, pushes, or other Git operations complete.

Think of them as checkpoints that ensure your changes meet project standards before they become part of the repository history.

## How Git Hooks Work

When you initialize a Git repository, Git creates a `.git/hooks` directory containing sample hook scripts. To use a hook:

1. Remove the `.sample` extension from a hook file
2. Make it executable (`chmod +x hookname`)
3. Add your automation logic

**This project uses a custom hooks directory** (`.githooks`) instead of `.git/hooks`. This allows hooks to be version-controlled and shared across the team.

### Setup

To use these hooks, configure Git to look in the `.githooks` directory:

```bash
git config core.hooksPath .githooks
```

This is typically handled automatically by the project's setup scripts.

## Available Hooks in This Project

### pre-commit

**Purpose**: Validates code quality and standards before accepting a commit.

**What it checks**:

- File and directory naming conventions (via ls-lint)
- Markdown formatting and style (via markdownlint)
- Shell script executability

**Why bash?**: This hook is intentionally written as a straightforward bash script to minimize external dependencies and maintain accessibility. While more sophisticated tools exist (like Husky, pre-commit framework, or custom parallel execution engines), a simple sequential script offers several advantages:

- **Lower barrier to entry**: Any developer familiar with basic bash can read, understand, and modify it
- **Fewer dependencies**: No additional package managers or frameworks required
- **Easier debugging**: Sequential execution makes it simple to identify which check failed
- **Sufficient for purpose**: The performance difference is negligible for typical commit sizes

Dynamic scripts that execute checks in parallel may be faster for large changesets, but they introduce complexity that makes them harder to maintain and troubleshoot. For most commits, the sequential approach completes in seconds.

**How it works**:

1. **Dependency check**: Verifies required commands (`ls-lint`, `pnpm`) are installed
2. **Targeted execution**: Uses `git diff --cached` to check only staged files, avoiding unnecessary work
3. **File type filtering**: Different checks run based on file extensions and Git status (added, modified, renamed, etc.)
4. **Automatic fixes**: Makes shell scripts executable if they aren't already

**Example output**:

```text
Running pre-commit checks
Running ls-lint
Running markdownlint
Ensuring shell script files are executable
✅ SUCCESS
Pre-commit checks passed
```

## Common Git Hooks

While this project currently uses only `pre-commit`, here are other hooks you might encounter:

| Hook | When it runs | Common uses |
|------|--------------|-------------|
| `pre-commit` | Before commit is created | Linting, formatting, style checks |
| `prepare-commit-msg` | After default message created, before editor opens | Auto-generate commit message templates |
| `commit-msg` | After commit message is entered | Validate message format (e.g., conventional commits) |
| `post-commit` | After commit is created | Notifications, CI triggers |
| `pre-push` | Before push to remote | Run tests, security scans |
| `post-merge` | After successful merge | Dependency updates, cleanup |

## Bypassing Hooks (Use Sparingly)

In rare cases, you may need to skip hooks:

```bash
git commit --no-verify
```

**Warning**: Only bypass hooks when you understand the implications. Hooks exist to maintain code quality and project standards.

## Troubleshooting

### Hook isn't running

1. Verify hooks path is configured: `git config core.hooksPath`
2. Check file is executable: `ls -la .githooks/pre-commit`
3. Ensure shebang is present: `head -n1 .githooks/pre-commit` should show `#!/usr/bin/env bash`

### Hook fails with "command not found"

Install the missing dependency listed in the error message. The pre-commit hook requires:

- `ls-lint` - for file naming conventions
- `pnpm` - for package management and running markdownlint

### Debugging hook behavior

Enable debug mode to see detailed execution:

```bash
DEBUG=1 git commit
```

This shows each command as it executes, helping identify where failures occur.

## Best Practices

1. **Keep hooks fast**: Slow hooks frustrate developers and encourage bypassing
2. **Provide clear errors**: When a hook fails, the message should explain what's wrong and how to fix it
3. **Test on staged files only**: Don't validate the entire codebase on every commit
4. **Make them optional for CI**: Run the same checks in CI so hooks can be bypassed in emergencies
5. **Document dependencies**: List required tools and installation instructions

## Resources

- [Git Hooks Documentation](https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks)
- [Conventional Commits](https://www.conventionalcommits.org/) - commit message format standard
- [ls-lint](https://ls-lint.org/) - file and directory name linter
- [markdownlint](https://github.com/DavidAnson/markdownlint) - markdown style checker
