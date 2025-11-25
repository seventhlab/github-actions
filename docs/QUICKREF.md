# Quick Reference

## Common Commands

### Setup
```bash
make setup              # Complete setup (recommended for first time)
make install            # Install dependencies only
make install-hooks      # Install git hooks only
```

### Development
```bash
make lint               # Check code quality
make lint-fix           # Check and auto-fix issues
make test               # Run tests
```

### Maintenance
```bash
make update-hooks       # Update pre-commit hooks
make clean              # Clean temporary files
make help               # Show all commands
```

## Commit Format

```bash
<type>: <description>

[optional body]

[optional footer]
```

### Types
- `feat:` - New feature (minor version bump)
- `fix:` - Bug fix (patch version bump)
- `docs:` - Documentation only
- `chore:` - Maintenance tasks
- `refactor:` - Code refactoring
- `test:` - Test updates
- `ci:` - CI/CD changes
- `perf:` - Performance improvements

### Breaking Changes
```bash
feat!: breaking change description
# or
feat: description

BREAKING CHANGE: explanation
```

## Branch Naming

```bash
feat/feature-name       # New features
fix/bug-description     # Bug fixes
docs/update-readme      # Documentation
chore/maintenance       # Maintenance tasks
refactor/improve-code   # Refactoring
```

## Typical Workflow

```bash
# 1. Setup repository
make setup

# 2. Create branch
git checkout -b feat/my-feature

# 3. Make changes
# ... edit files ...

# 4. Check your changes
make lint

# 5. Commit (hooks run automatically)
git commit -m "feat: add my feature"

# 6. Push
git push origin feat/my-feature

# 7. Create PR on GitHub
```

## Files Overview

| File | Purpose |
|------|---------|
| `Makefile` | Automation commands |
| `package.json` | Node.js dependencies |
| `.pre-commit-config.yaml` | Pre-commit hooks config |
| `.releaserc.json` | Semantic release config |
| `.github/workflows/` | CI/CD workflows |
| `.github/labels.yml` | Auto-labeling rules |

## Helpful Links

- [Conventional Commits](https://www.conventionalcommits.org/)
- [Semantic Versioning](https://semver.org/)
- [Pre-commit](https://pre-commit.com/)
- [GitHub Actions](https://docs.github.com/en/actions)
