# Contributing to GitHub Actions Collection

Thank you for considering contributing to this project! This guide will help you get started.

## 🚀 Quick Start

### 1. Fork and Clone

```bash
git clone https://github.com/<your-username>/github-actions.git
cd github-actions
```

### 2. Install Development Tools

```bash
# Quick setup - installs everything
make setup

# Or install components separately
make install        # Install dependencies
make install-hooks  # Install git hooks

# (Optional) Run linters manually
make lint
```

**Available Commands:**

- `make help` - Show all available commands
- `make setup` - Complete setup
- `make lint` - Run linters (read-only)
- `make lint-fix` - Run linters with auto-fix
- `make clean` - Clean up temporary files

## 📝 Development Workflow

### Branch Naming

Create a feature branch from `main`:

```bash
git checkout -b feat/your-feature-name
git checkout -b fix/your-bug-fix
git checkout -b docs/your-documentation-update
```

### Making Changes

1. **Write your code** - Follow existing patterns and conventions
2. **Test locally** - Ensure your action works as expected
3. **Run linters** - Pre-commit hooks will run automatically on commit, or run manually:

   ```bash
   make lint
   # or with auto-fix
   make lint-fix
   ```

### Commit Messages

This project uses [Conventional Commits](https://www.conventionalcommits.org/) for automated versioning and changelog generation.

**Format:**
```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

**Types:**
- `feat:` - New feature (triggers minor version bump)
- `fix:` - Bug fix (triggers patch version bump)
- `docs:` - Documentation only changes
- `chore:` - Maintenance tasks, no production code change
- `refactor:` - Code refactoring, no feature change
- `test:` - Adding or updating tests
- `ci:` - CI/CD configuration changes
- `perf:` - Performance improvements
- `build:` - Build system or external dependencies

**Breaking Changes:**
Add `!` after the type or include `BREAKING CHANGE:` in the footer to trigger a major version bump.

**Examples:**
```bash
feat: add timeout configuration for CI wait action
fix: correct status detection for cancelled jobs
docs: update README with usage examples
chore: update pre-commit hooks
feat!: change input parameter names (breaking change)
```

```bash
feat: add custom polling interval support

Allow users to configure how often the action polls for CI status.
This provides more flexibility for different use cases.

BREAKING CHANGE: default polling interval changed from 30s to 10s
```

### Submit Pull Request

1. **Push your changes:**
   ```bash
   git push origin feat/your-feature-name
   ```

2. **Create Pull Request** on GitHub with:
   - Clear title using conventional commit format
   - Description of changes
   - Link to related issues (if any)
   - Screenshots/examples (if applicable)

3. **Address feedback** - Respond to review comments and update your PR

## 🧪 Testing

### Testing GitHub Actions Locally

You can use [act](https://github.com/nektos/act) to test workflows locally:

```bash
# Install act (macOS)
brew install act

# Run a specific workflow
act -W .github/workflows/lint.yml

# Run all workflows for pull_request event
act pull_request
```

### Manual Testing

For actions like `wait-for-ci`, test in a real repository:

1. Create a test repository or use a fork
2. Add a workflow that uses your modified action
3. Create a PR and observe behavior
4. Check logs for expected output

## 📋 Code Quality Standards

### YAML Files

- Use 2-space indentation
- Keep lines under 120 characters
- Include descriptive comments for complex configurations
- Validate with `yamllint`

### Bash Scripts

- Use `#!/usr/bin/env bash` shebang
- Enable strict mode: `set -o errexit -o nounset -o pipefail`
- Use 2-space indentation
- Add comments for complex logic
- Validate with `shellcheck`
- Follow [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)

### Markdown Files

- Use 120 character line width for readability
- Include code blocks with language identifiers
- Validate with `markdownlint`
- Keep headers hierarchical

### Action Metadata (action.yml)

- Provide clear descriptions for all inputs/outputs
- Specify required inputs explicitly
- Include sensible defaults
- Document all environment variables needed

## 🏗️ Adding a New Action

1. **Create action directory:**
   ```bash
   mkdir -p actions/your-action-name
   ```

2. **Add required files:**
   ```
   actions/your-action-name/
   ├── action.yml          # Action metadata and interface
   ├── README.md           # Action documentation
   └── scripts/            # Scripts (if needed)
       └── your-script.sh
   ```

3. **Define action.yml:**
   ```yaml
   ---
   name: Your Action Name
   description: Clear description of what your action does
   inputs:
     inputName:
       description: Description of this input
       required: true
       default: 'default-value'
   runs:
     using: composite
     steps:
       - name: Run action logic
         shell: bash
         run: echo "Your logic here"
   ```

4. **Write comprehensive README** with:
   - Description
   - Inputs documentation
   - Usage examples
   - Requirements
   - Behavior details

5. **Update root README** to list your new action

## 🔍 Review Process

### What We Look For

- ✅ Follows conventional commit format
- ✅ Passes all pre-commit checks
- ✅ Includes tests/examples
- ✅ Documentation is clear and complete
- ✅ No breaking changes (unless explicitly noted)
- ✅ Code is well-commented

### Review Timeline

- Initial review: 1-3 business days
- We'll provide feedback or approve
- Once approved, maintainers will merge

## 🚢 Release Process

Releases are fully automated:

1. **Merge to main** - PR is merged to `main` branch
2. **Semantic Release runs** - Analyzes commits since last release
3. **Version bump** - Determines new version based on commit types
4. **Create release** - Generates changelog and creates GitHub release
5. **Update tags** - Creates version tags (e.g., `v1.0.0`, `v1`, `v1.0`)

## 📚 Resources

- [Conventional Commits](https://www.conventionalcommits.org/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Pre-commit Documentation](https://pre-commit.com/)
- [Semantic Versioning](https://semver.org/)

## 💬 Getting Help

- **Questions:** Open a [Discussion](https://github.com/seventhlab/github-actions/discussions)
- **Bugs:** Open an [Issue](https://github.com/seventhlab/github-actions/issues)
- **Security:** See [SECURITY.md](./docs/SECURITY.md) for reporting vulnerabilities

## 🙏 Thank You

Your contributions help make this project better for everyone. We appreciate your time and effort!
