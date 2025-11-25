# Quick Setup Guide

This guide helps you set up the repository for local development in under 5 minutes.

## Prerequisites

- Git
- Python 3.8+ (for pre-commit)
- pip

## Setup Steps

### Option 1: Quick Setup (Recommended)

```bash
make setup
```

This single command:
- Installs Python dependencies (pre-commit)
- Installs Node.js dependencies (semantic-release)
- Sets up git hooks

### Option 2: Manual Setup

```bash
# Install dependencies
make install

# Install git hooks
make install-hooks

# Test your setup
make lint
```

### Available Commands

Run `make help` to see all available commands:

```bash
make help
```

Common commands:
- `make lint` - Run all linters (read-only)
- `make lint-fix` - Run linters and auto-fix issues
- `make clean` - Clean up cache files
- `make update-hooks` - Update pre-commit hooks

## What Gets Checked?

- ✅ YAML syntax and formatting
- ✅ Bash script linting (shellcheck)
- ✅ Markdown formatting
- ✅ Trailing whitespace
- ✅ End-of-file fixes
- ✅ Merge conflicts

## Making Your First Commit

```bash
# Create a feature branch
git checkout -b feat/your-feature

# Make your changes
# ...

# Commit (hooks run automatically)
git commit -m "feat: add new feature"

# Push
git push origin feat/your-feature
```

## Commit Message Format

Use [Conventional Commits](https://www.conventionalcommits.org/):

```text
<type>: <description>

Types: feat, fix, docs, chore, refactor, test, ci, perf
```

Examples:

```bash
git commit -m "feat: add timeout configuration"
git commit -m "fix: correct status detection"
git commit -m "docs: update README examples"
```

## Skipping Hooks (Not Recommended)

If you absolutely need to skip pre-commit checks:

```bash
git commit --no-verify -m "your message"
```

## Troubleshooting

### Pre-commit is slow

First run is slower as it sets up environments. Subsequent runs are cached and fast.

### Hook failures

If a hook fails:

1. Read the error message
2. Fix the issue
3. Stage the changes: `git add .`
4. Commit again

### Manual hook updates

Update to latest hook versions:

```bash
pre-commit autoupdate
```

## Need Help?

- See [CONTRIBUTING.md](./CONTRIBUTING.md) for detailed guidelines
- Open an issue for questions
- Check existing issues for common problems

## Next Steps

- Read [CONTRIBUTING.md](./CONTRIBUTING.md)
- Explore existing actions in `actions/`
- Check out [GitHub Actions docs](https://docs.github.com/en/actions)
