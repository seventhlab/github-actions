# GitHub Actions Collection

A curated collection of reusable GitHub Actions for common CI/CD workflows and automation tasks.

This repository also centralizes versioning for frequently used baseline actions (checkout, Node setup, and Go setup) so maintenance updates are done in one place and consumed consistently across workflows.

## 📦 Available Actions

### [Checkout](./actions/checkout/)

Internal wrapper around `actions/checkout` for a single, centrally managed checkout version.

**Quick Example:**
```yaml
- name: Checkout code
   uses: seventhlab/github-actions/actions/checkout@v1
```

### [Setup Node.js](./actions/setup-node/)

Sets up Node.js and pnpm with repository-standard defaults and optional GitHub Packages npm registry support.

**Inputs:**
- `node-version` (default: `24`)
- `pnpm-version` (default: `10`)
- `use-github-npm-registry` (default: `true`)

**Quick Example:**
```yaml
- name: Setup Node.js
   uses: seventhlab/github-actions/actions/setup-node@v1
   with:
      node-version: '24'
      pnpm-version: '10'
      use-github-npm-registry: 'true'
   env:
      NODE_AUTH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### [Setup Go](./actions/setup-go/)

Sets up Go with cache enabled using a centrally managed `actions/setup-go` version.

**Inputs:**
- `go-version` (default: `1.26.1`)

**Quick Example:**
```yaml
- name: Setup Go
   uses: seventhlab/github-actions/actions/setup-go@v1
   with:
      go-version: '1.26.1'
```

### [Wait for CI](./actions/wait-for-ci/)

Waits for all CI checks to complete on a given commit before proceeding. Ideal for merge queues, pull requests, and workflow synchronization.

**Key Features:**
- Monitors all CI checks on a specific commit
- Configurable timeout and polling intervals
- Supports job exclusion patterns using regex
- Fail-fast or wait-for-all modes
- Automatic self-exclusion

**Quick Example:**
```yaml
- name: Wait for CI
  uses: seventhlab/github-actions/actions/wait-for-ci@v1
  with:
    commitSha: ${{ github.event.pull_request.head.sha }}
    jobName: "Wait for CI"
    timeOutInMinutes: 60
  env:
    GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

## 🚀 Getting Started

### Using Actions in Your Workflows

Reference actions from this repository using the following format:

```yaml
uses: seventhlab/github-actions/actions/<action-name>@<version>
```

**Versioning:**
- Use specific tags for production: `@v1.0.0`
- Use major version tags for automatic updates: `@v1`
- Use `@main` for latest (not recommended for production)

### Contributing

We welcome contributions! Please see our [Contributing Guidelines](./CONTRIBUTING.md) for details on:

- Setting up your development environment
- Running tests and linting locally
- Commit message conventions
- Pull request process

**Quick Start:**
```bash
git clone https://github.com/seventhlab/github-actions.git
cd github-actions
make setup
```

See also:
- [Quick Reference](./docs/QUICKREF.md) - Command cheat sheet
- [Setup Guide](./docs/SETUP.md) - Detailed setup instructions
- [Labels Guide](./docs/LABELS.md) - GitHub labels configuration

## 🛠️ Development

### Prerequisites

- [pre-commit](https://pre-commit.com/) for running linters locally
- [GitHub CLI](https://cli.github.com/) for testing GitHub integrations

### Local Setup

1. Clone the repository:

   ```bash
   git clone https://github.com/seventhlab/github-actions.git
   cd github-actions
   ```

2. Run setup (installs all dependencies and hooks):

   ```bash
   make setup
   ```

3. Run linters manually:

   ```bash
   make lint
   ```

#### Available Make Targets

- `make help` - Show all available commands
- `make setup` - Complete setup (dependencies + hooks)
- `make install` - Install dependencies only
- `make install-hooks` - Install git hooks only
- `make lint` - Run all linters
- `make lint-fix` - Run linters and auto-fix issues
- `make clean` - Clean up cache and temporary files

### Code Quality

All code is automatically checked for:
- ✅ YAML syntax and formatting
- ✅ Bash script linting (shellcheck)
- ✅ Markdown formatting and style
- ✅ Trailing whitespace and end-of-file fixes

## 📝 Commit Conventions

This repository uses [Conventional Commits](https://www.conventionalcommits.org/) for automated semantic versioning:

- `feat:` - New features (triggers minor version bump)
- `fix:` - Bug fixes (triggers patch version bump)
- `docs:` - Documentation changes
- `chore:` - Maintenance tasks
- `ci:` - CI/CD changes
- `refactor:` - Code refactoring
- `test:` - Test updates

**Breaking changes:** Add `!` after the type or include `BREAKING CHANGE:` in the commit body to trigger a major version bump.

Example:
```bash
git commit -m "feat: add support for custom polling intervals"
git commit -m "fix: correct status detection for cancelled jobs"
git commit -m "feat!: change input parameter names"
```

## 🔖 Releases

Releases are automatically created when changes are merged to `main`:

1. Commits are analyzed using conventional commit format
2. Version is automatically bumped based on commit types
3. Release notes are generated from commit messages
4. Git tags are created automatically

**Note:** If you encounter permission issues with releases, see the [Release Setup Guide](./docs/RELEASE.md) for configuration instructions.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Support

- **Issues:** [GitHub Issues](https://github.com/seventhlab/github-actions/issues)
- **Discussions:** [GitHub Discussions](https://github.com/seventhlab/github-actions/discussions)
- **Security:** See [Security Policy](./docs/SECURITY.md) for reporting vulnerabilities

## 🌟 Acknowledgments

Built with ❤️ by the SeventhLab team.
