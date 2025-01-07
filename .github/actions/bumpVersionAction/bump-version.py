import os
import subprocess
import sys
from enum import Enum

MAJOR_KEYWORDS = ["breaking", "major"]
MINOR_KEYWORDS = ["feat", "feature", "minor"]
PATCH_KEYWORDS = ["fix", "bump", "patch"]


class UpgradeType(Enum):
    NONE = 'none'
    PATCH = 'patch'
    MINOR = 'minor'
    MAJOR = 'major'


upgrade_type = UpgradeType.NONE


def handle_subprocess_error(subprocess_result, error_message):
    if subprocess_result.returncode != 0:
        print(error_message)
        print(f"Return code {subprocess_result.returncode}")
        print("STDERR:")
        print(str(subprocess_result.stderr, "UTF-8"))
        print("STDOUT:")
        print(str(subprocess_result.stdout, "UTF-8"))
        exit(1)


if __name__ == "__main__":
    chart_name = os.getenv("CHART_NAME")
    print(f"Bumping chart version for: {chart_name}")

    get_commits_process = subprocess.run(
        f"git log --pretty=format:%s 'HEAD' .",
        cwd=f"./charts/{chart_name}",
        shell=True,
        capture_output=True)

    print("inspected the following commit messages:")
    commit_messages = str(get_commits_process.stdout, "UTF-8").strip().split("\n")
    print(commit_messages)

    last_commit_message = str([commit_messages[0]])
    print("last commit message:")
    print(last_commit_message)

    if any(x.lower() in last_commit_message.lower() for x in MAJOR_KEYWORDS):
        upgrade_type = UpgradeType.MAJOR
    elif any(x.lower() in last_commit_message.lower() for x in MINOR_KEYWORDS):
        upgrade_type = UpgradeType.MINOR
    elif any(x.lower() in last_commit_message.lower() for x in PATCH_KEYWORDS):
        upgrade_type = UpgradeType.PATCH

    if upgrade_type == UpgradeType.NONE:
        print("No need for a version bump detected")
        print("changes=false >> $GITHUB_OUTPUT")
        exit(0)

    print(f"Doing upgrade of type {upgrade_type.value} now")

    bumpver_process = subprocess.run(f"bump2version {upgrade_type.value}",
                                     shell=True,
                                     cwd=f"./charts/{chart_name}",
                                     capture_output=True)
    handle_subprocess_error(bumpver_process, "Could not execute version bump")

    print("changes=true >> $GITHUB_OUTPUT")