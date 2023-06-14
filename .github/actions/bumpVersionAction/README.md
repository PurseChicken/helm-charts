# Helm chart version bumper

Bumps the version of a helm chart with pythons bump2version. Based on the last commit messages inside the helm chart directory.

## Inputs

### chart

The name of the chart inside the `charts` directory.

## Example usage

The chart to update has to have a `.bumpversion.cfg` in the top level directory. A Sample looks like this.

```
[bumpversion]
current_version = 16.0.6
commit = true
tag = false
message = Bump mychart chart version: {current_version} → {new_version}

[bumpversion:file:Chart.yaml]
```

The workflow include looks like this.
```yaml
    - name: Bump mychart
      uses: ./.github/actions/bumpVersionAction
      with:
        chart: mychart
```

In order for a version to be bumped, one of the following keywords must be used in the commit message:

```
MAJOR_KEYWORDS = ["breaking", "major"]
MINOR_KEYWORDS = ["feat", "feature", "minor"]
PATCH_KEYWORDS = ["fix", "bump", "patch"]
```