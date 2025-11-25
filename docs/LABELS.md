# GitHub Labels Setup

This repository uses automatic PR labeling based on file paths and branch names.

## How It Works

The `.github/labels.yml` file configures the `actions/labeler` action to automatically apply labels to pull requests based on:

- **File paths changed** - Labels are applied based on which files were modified
- **Branch names** - Labels are applied based on branch naming conventions
- **PR content** - Labels are applied based on PR title or body content

## Required Labels

You need to create these labels in your GitHub repository. You can do this:

### Option 1: Manually in GitHub UI

1. Go to your repository on GitHub
2. Click on "Issues" tab
3. Click on "Labels"
4. Create the following labels:

| Label | Color | Description |
|-------|-------|-------------|
| `feature` | `#a2eeef` | New feature or enhancement |
| `bug` | `#d73a4a` | Something isn't working |
| `documentation` | `#0075ca` | Documentation changes |
| `maintenance` | `#fbca04` | Repository maintenance |
| `refactor` | `#5319e7` | Code refactoring |
| `testing` | `#0e8a16` | Test updates |
| `ci/cd` | `#d4c5f9` | CI/CD changes |
| `performance` | `#ff6b6b` | Performance improvements |
| `dependencies` | `#0366d6` | Dependency updates |
| `breaking-change` | `#b60205` | Breaking changes |

### Option 2: Using GitHub CLI

```bash
# Feature
gh label create "feature" --color "a2eeef" --description "New feature or enhancement"

# Bug
gh label create "bug" --color "d73a4a" --description "Something isn't working"

# Documentation
gh label create "documentation" --color "0075ca" --description "Documentation changes"

# Maintenance
gh label create "maintenance" --color "fbca04" --description "Repository maintenance"

# Refactor
gh label create "refactor" --color "5319e7" --description "Code refactoring"

# Testing
gh label create "testing" --color "0e8a16" --description "Test updates"

# CI/CD
gh label create "ci/cd" --color "d4c5f9" --description "CI/CD changes"

# Performance
gh label create "performance" --color "ff6b6b" --description "Performance improvements"

# Dependencies
gh label create "dependencies" --color "0366d6" --description "Dependency updates"

# Breaking Change
gh label create "breaking-change" --color "b60205" --description "Breaking changes"
```

### Option 3: Using a Script

Create this script and run it:

```bash
#!/bin/bash

LABELS=(
  "feature:a2eeef:New feature or enhancement"
  "bug:d73a4a:Something isn't working"
  "documentation:0075ca:Documentation changes"
  "maintenance:fbca04:Repository maintenance"
  "refactor:5319e7:Code refactoring"
  "testing:0e8a16:Test updates"
  "ci/cd:d4c5f9:CI/CD changes"
  "performance:ff6b6b:Performance improvements"
  "dependencies:0366d6:Dependency updates"
  "breaking-change:b60205:Breaking changes"
)

for label in "${LABELS[@]}"; do
  IFS=':' read -r name color description <<< "$label"
  gh label create "$name" --color "$color" --description "$description" || true
done
```

## Labeling Rules

### By File Paths

- **feature**: Changes to `actions/**/*`
- **bug**: Changes in `**/fix/**/*` directories
- **documentation**: Changes to `*.md` files or `docs/**/*`
- **ci/cd**: Changes to `.github/workflows/**/*`
- **maintenance**: Changes to config files (`.gitignore`, `.pre-commit-config.yaml`, etc.)
- **dependencies**: Changes to `package.json`, `package-lock.json`, requirements files
- **testing**: Changes to test files

### By Branch Names

- **bug**: Branches starting with `fix/`, `bugfix/`, or `hotfix/`
- **documentation**: Branches starting with `docs/`
- **ci/cd**: Branches starting with `ci/`
- **maintenance**: Branches starting with `chore/`
- **testing**: Branches starting with `test/`
- **performance**: Branches starting with `perf/`
- **refactor**: Branches starting with `refactor/`
- **breaking-change**: Branches ending with `!`

### By PR Content

- **breaking-change**: PR body contains "BREAKING CHANGE" or "BREAKING-CHANGE"

## Testing

To test if labeling works:

1. Create labels in your repository
2. Create a test branch: `git checkout -b feat/test-labeling`
3. Make a change to a file in `actions/`
4. Push and create a PR
5. The `feature` label should be automatically applied

## Customization

To customize labeling rules, edit `.github/labels.yml` and adjust the patterns to match your needs.

See the [actions/labeler documentation](https://github.com/actions/labeler) for more options.
