# Contributing to PurseChicken Helm Charts

Thank you for your interest in contributing to PurseChicken Helm Charts! This document provides guidelines and instructions for contributing.

## How to Contribute

### Reporting Issues

Before creating an issue, please:
- Check if the issue already exists
- Use a clear and descriptive title
- Provide as much context as possible
- Include relevant error messages or logs

### Suggesting Enhancements

We welcome suggestions for new features or improvements:
- Open an issue with the `enhancement` label
- Describe the use case and expected behavior
- Explain why this enhancement would be useful

### Submitting Pull Requests

1. **Fork the repository** and create a branch from `master`
2. **Make your changes** following the coding standards below
3. **Test your changes** using `helm template` and `helm lint`
4. **Update documentation** as needed (README, CHANGELOG, etc.)
5. **Commit your changes** using [Conventional Commits](https://www.conventionalcommits.org/)
6. **Push to your fork** and open a Pull Request

## Development Guidelines

### Chart Structure

- Follow Helm [best practices](https://helm.sh/docs/chart_best_practices/)
- Use semantic versioning for chart versions
- Include comprehensive `values.yaml` with comments
- Document all configurable options in README

### Code Standards

- Use consistent YAML formatting (2 spaces, no tabs)
- Follow existing naming conventions
- Add comments for complex template logic
- Keep templates readable and maintainable

### Testing

Before submitting a PR, ensure:

```bash
# Lint the chart
helm lint charts/<chart-name>

# Template the chart with default values
helm template test-release charts/<chart-name>

# Template with example values (if available)
helm template test-release charts/<chart-name> -f charts/<chart-name>/examples/*.yaml
```

### Documentation

- Update the chart's README.md for new features
- Add entries to CHANGELOG.md in the `[Unreleased]` section
- Include examples for complex configurations
- Document breaking changes clearly

### Commit Messages

Use [Conventional Commits](https://www.conventionalcommits.org/) format:

- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `chore:` - Maintenance tasks
- `refactor:` - Code refactoring
- `test:` - Test additions/changes
- `breaking:` or `feat!:` - Breaking changes (major version bump)

Examples:
```
feat: add support for Cloud SQL read replicas
fix: correct firewall rule port configuration
docs: update README with new configuration options
breaking: change default deletion policy to abandon
```

## Version Bumping

Version bumps are handled automatically by the CI/CD pipeline based on commit messages:
- `breaking:` or `feat!:` → Major version (X.0.0)
- `feat:` → Minor version (0.X.0)
- `fix:` or other → Patch version (0.0.X)

## Review Process

1. All PRs require at least one approval
2. CI checks must pass
3. Maintainers will review code, documentation, and testing
4. Address any feedback before merging

## Questions?

- Open an issue for questions or discussions
- Check existing documentation in chart READMEs
- Review example configurations in chart examples directories

Thank you for contributing! 🎉
