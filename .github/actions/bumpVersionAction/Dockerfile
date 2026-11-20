# Container image that runs your code.
# Pin the Python minor so Dependabot proposes the next upgrade. The floating
# python:alpine tag moves on its own. bump-my-version supports 3.15;
# The package pin lives in requirements.txt so Dependabot can update it.
FROM python:3.15-alpine

WORKDIR /github/workspace

COPY requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt && apk add git

COPY bump-version.py /bump-version.py

# The git add safe.directory $(pwd) is needed because since CVE-2022-24765 git checks the owernership of the processed repos
CMD sh -c 'git config --global --add safe.directory $(pwd) && exec python /bump-version.py'