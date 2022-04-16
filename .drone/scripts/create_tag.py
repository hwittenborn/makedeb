#!/usr/bin/env python3
import json
import logging
import subprocess

from os import environ
from github import Github
from github.GithubException import GithubException
from markdown import markdown
from bs4 import BeautifulSoup

def get_changelog_text(pkgver):
    changelog_text = "<h2>Release Notes:</h2>"
    version_found = False

    with open("CHANGELOG.md", "r") as file:
        html = markdown(file.read())

    soup = BeautifulSoup(html, "html.parser")

    for child in soup.children:
        if str(child) == "\n":
            continue

        if child.name == "h2" and version_found is False and pkgver in child.text:
            version_found = True
            continue
        elif child.name == "h2" and version_found is True:
            break
        elif version_found is True:
            changelog_text += str(child)

    return changelog_text

# Set up our environment.
logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")

github_api_key = environ["github_api_key"]
drone_branch = environ["DRONE_COMMIT_BRANCH"]
drone_repo = "makedeb/makedeb"
commit_sha = (
    subprocess.run(["git", "log", "-n", "1", "--format=%H"], stdout=subprocess.PIPE)
    .stdout.decode()
    .strip("\n")
)

with open(".data.json", "r") as file:
    data = json.loads(file.read())

pkgver = data["current_pkgver"]
pkgrel = data["current_pkgrel_" + drone_branch]

client = Github(github_api_key)

tag = f"v{pkgver}-{pkgrel}"
name = f"v{pkgver}"

repo = client.get_repo(drone_repo)

# We publish GitHub releases on pushes to the 'stable' branch. Otherwise, we just publish tags.
# Exceptions are raised when release tags already exists. In such scenarios, we simply publishing a new tag/release.
if drone_branch == "stable":
    message = get_changelog_text(pkgver)

    try:
        repo.create_git_release(tag, name, message)
    except GithubException as exc:
        if exc.data["errors"][0]["code"] == "already_exists": logging.warning(f"Skipping release creation, as release tag '{tag}' already exists.")
        else: raise exc

else:
    try:
        repo.create_git_tag(tag, "test", commit_sha, "commit")
        repo.create_git_ref(f"refs/tags/{tag}", commit_sha)

    except GithubException as exc:
        if exc.data["message"] != "Reference already exists": raise exc
        else: logging.warning(f"Skipping tag creation, as tag '{tag}' already exists.")
