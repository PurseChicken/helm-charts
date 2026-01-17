import os
import subprocess
import sys
from enum import Enum

# Keywords for version bumping (following Conventional Commits)
MAJOR_KEYWORDS = ["breaking:", "major:", "breaking change:"]
MINOR_KEYWORDS = ["feat:", "feature:", "minor:"]
PATCH_KEYWORDS = [
    "fix:", "patch:", "bump:",
    "chore:", "docs:", "style:", "refactor:",
    "perf:", "test:", "build:", "ci:"
]
# Skip keywords to prevent version bumping
SKIP_KEYWORDS = ["[skip-bump]", "[no-bump]", "[skip ci]", "[ci skip]"]


class UpgradeType(Enum):
    NONE = 'none'
    PATCH = 'patch'
    MINOR = 'minor'
    MAJOR = 'major'


def write_github_output(key, value):
    """Write output to GitHub Actions output file"""
    github_output = os.getenv('GITHUB_OUTPUT')
    if github_output:
        with open(github_output, 'a') as f:
            f.write(f"{key}={value}\n")
    else:
        # Fallback for local testing
        print(f"::set-output name={key}::{value}")


def handle_subprocess_error(subprocess_result, error_message):
    if subprocess_result.returncode != 0:
        print(error_message)
        print(f"Return code {subprocess_result.returncode}")
        print("STDERR:")
        print(str(subprocess_result.stderr, "UTF-8"))
        print("STDOUT:")
        print(str(subprocess_result.stdout, "UTF-8"))
        sys.exit(1)


def check_unreleased_section(chart_name):
    """Check if CHANGELOG has Unreleased section for version bumping"""
    changelog_path = f"./charts/{chart_name}/CHANGELOG.md"
    try:
        with open(changelog_path, 'r') as f:
            content = f.read()
            if "## [Unreleased]" not in content:
                print(f"⚠️  WARNING: CHANGELOG.md doesn't have '## [Unreleased]' section")
                print("   bump2version may fail to update CHANGELOG properly")
                return False
    except FileNotFoundError:
        print(f"⚠️  WARNING: CHANGELOG.md not found at {changelog_path}")
        return False
    return True


def detect_upgrade_type(commit_message):
    """Detect upgrade type from commit message"""
    commit_lower = commit_message.lower()
    
    # Check for skip keywords first
    if any(skip in commit_lower for skip in SKIP_KEYWORDS):
        print(f"🚫 Skip keyword detected in commit message")
        return UpgradeType.NONE
    
    # Check for breaking change with exclamation mark (e.g., feat!:, fix!:)
    if "!:" in commit_message:
        print(f"💥 Breaking change detected (exclamation mark syntax)")
        return UpgradeType.MAJOR
    
    # Check for major keywords
    if any(keyword in commit_lower for keyword in MAJOR_KEYWORDS):
        print(f"💥 Major version bump detected")
        return UpgradeType.MAJOR
    
    # Check for minor keywords
    if any(keyword in commit_lower for keyword in MINOR_KEYWORDS):
        print(f"✨ Minor version bump detected")
        return UpgradeType.MINOR
    
    # Check for patch keywords
    if any(keyword in commit_lower for keyword in PATCH_KEYWORDS):
        print(f"🔧 Patch version bump detected")
        return UpgradeType.PATCH
    
    return UpgradeType.NONE


if __name__ == "__main__":
    chart_name = os.getenv("CHART_NAME")
    print(f"📦 Checking version bump for chart: {chart_name}")
    print("=" * 60)

    # Get commit messages
    get_commits_process = subprocess.run(
        f"git log --pretty=format:%s 'HEAD' .",
        cwd=f"./charts/{chart_name}",
        shell=True,
        capture_output=True)

    commit_messages = str(get_commits_process.stdout, "UTF-8").strip().split("\n")
    
    if not commit_messages or commit_messages[0] == '':
        print("⚠️  No commit messages found")
        write_github_output('changes', 'false')
        sys.exit(0)
    
    last_commit_message = commit_messages[0]
    print(f"📝 Last commit message: {last_commit_message}")
    print("=" * 60)

    # Detect upgrade type
    upgrade_type = detect_upgrade_type(last_commit_message)

    if upgrade_type == UpgradeType.NONE:
        print("ℹ️  No version bump needed")
        print("   Tip: Use keywords like 'feat:', 'fix:', 'breaking:' to trigger version bumps")
        write_github_output('changes', 'false')
        sys.exit(0)

    # Check for Unreleased section in CHANGELOG
    check_unreleased_section(chart_name)

    print(f"🚀 Executing {upgrade_type.value} version bump...")

    # Execute bump2version
    bumpver_process = subprocess.run(
        f"bump2version {upgrade_type.value}",
        shell=True,
        cwd=f"./charts/{chart_name}",
        capture_output=True
    )
    handle_subprocess_error(bumpver_process, "❌ Could not execute version bump")

    print("✅ Version bump completed successfully")
    write_github_output('changes', 'true')