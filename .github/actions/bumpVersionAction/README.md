# Helm chart version bumper

Automatically bumps Helm chart versions using Python's bump2version based on conventional commit keywords in the last commit message.

## How It Works

1. **Detects version bump type** from commit message keywords (feat, fix, breaking, etc.)
2. **Runs bump2version** to update Chart.yaml and .bumpversion.cfg
3. **Updates CHANGELOG.md** automatically (converts `## [Unreleased]` to versioned section)
4. **Commits all changes** in a single atomic commit

## Inputs

### chart

**Required** - The name of the chart inside the `charts` directory.

## Configuration

Each chart must have a `.bumpversion.cfg` file in its root directory:

```ini
[bumpversion]
current_version = 1.0.0
commit = false
tag = false
message = Bump mychart version: {current_version} → {new_version}

[bumpversion:file:Chart.yaml]
```

**Important Notes:**
- Set `commit = false` (the script handles commits to include CHANGELOG updates)
- Do NOT add `[bumpversion:file:CHANGELOG.md]` section (the script handles CHANGELOG updates to avoid bump2version corruption issues)

## CHANGELOG Structure

Your CHANGELOG.md must follow [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) format with an `## [Unreleased]` section:

```markdown
# Chart Changelog

## [Unreleased]

### Added
- New feature description

### Fixed
- Bug fix description

## [v1.0.0] - 2024-01-01
...
```

## Commit Keywords

### Major Version Bump (X.0.0)
```
breaking:, major:, breaking change:, feat!:, fix!:
```

### Minor Version Bump (0.X.0)
```
feat:, feature:, minor:
```

### Patch Version Bump (0.0.X)
```
fix:, patch:, bump:, chore:, docs:, style:, 
refactor:, perf:, test:, build:, ci:
```

### Skip Version Bump
```
[skip-bump], [no-bump], [skip ci], [ci skip]
```

## Example Usage

```yaml
- name: Bump mychart
  uses: ./.github/actions/bumpVersionAction
  with:
    chart: mychart
```

## Example Workflow

```yaml
jobs:
  bump-versions:
    runs-on: ubuntu-latest
    steps:
    - name: Checkout
      uses: actions/checkout@v6
      with:
        fetch-depth: 0

    - name: Configure Git
      run: |
        git config user.name "$GITHUB_ACTOR"
        git config user.email "$GITHUB_ACTOR@users.noreply.github.com"

    - name: Bump my-chart
      uses: ./.github/actions/bumpVersionAction
      with:
        chart: my-chart
```

## Example Commit Messages

```bash
# Minor bump (1.0.0 → 1.1.0)
git commit -m "feat: add new VPN gateway support"

# Patch bump (1.0.0 → 1.0.1)
git commit -m "fix: correct DNS record handling"

# Major bump (1.0.0 → 2.0.0)
git commit -m "breaking: remove deprecated API fields"
git commit -m "feat!: redesign configuration structure"

# Skip version bump
git commit -m "docs: update README [skip-bump]"
```

## Features

- ✅ **Conventional Commits** - Supports standard and custom keywords
- ✅ **Breaking Change Syntax** - Recognizes `!:` syntax (e.g., `feat!:`)
- ✅ **Skip Keywords** - Prevent bumps with `[skip-bump]` or `[no-bump]`
- ✅ **Automatic CHANGELOG** - Updates CHANGELOG.md from Unreleased section
- ✅ **Atomic Commits** - Single commit with Chart.yaml, CHANGELOG.md, and .bumpversion.cfg
- ✅ **GitHub Actions Integration** - Properly sets outputs for workflow conditionals