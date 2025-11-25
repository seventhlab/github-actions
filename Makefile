.PHONY: help setup install install-hooks lint lint-fix clean test

# Default target
help: ## Show this help message
	@echo "Usage: make [target]"
	@echo ""
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

setup: install install-hooks ## Complete setup (install dependencies and hooks)
	@echo "✅ Setup complete! You're ready to contribute."

install: ## Install all dependencies (pre-commit and npm packages)
	@echo "📦 Installing Python dependencies..."
	pip install pre-commit
	@echo "📦 Installing Node.js dependencies..."
	npm install
	@echo "✅ Dependencies installed"

install-hooks: ## Install pre-commit git hooks
	@echo "🪝 Installing pre-commit hooks..."
	pre-commit install
	@echo "✅ Git hooks installed"

lint: ## Run all linters (read-only, no fixes)
	@echo "🔍 Running pre-commit checks..."
	pre-commit run --all-files

lint-fix: ## Run linters and auto-fix issues where possible
	@echo "🔧 Running pre-commit with auto-fix..."
	pre-commit run --all-files
	@echo "✅ Linting complete"

update-hooks: ## Update pre-commit hooks to latest versions
	@echo "⬆️  Updating pre-commit hooks..."
	pre-commit autoupdate
	@echo "✅ Hooks updated"

clean: ## Clean up cache and temporary files
	@echo "🧹 Cleaning up..."
	rm -rf node_modules
	rm -rf ~/.cache/pre-commit
	find . -type f -name "*.pyc" -delete
	find . -type d -name "__pycache__" -delete
	@echo "✅ Clean complete"

test: lint ## Run tests (currently just linting)
	@echo "✅ All tests passed"

check: lint ## Alias for lint

format: lint-fix ## Alias for lint-fix

init: setup ## Alias for setup

.DEFAULT_GOAL := help
