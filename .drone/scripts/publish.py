#!/usr/bin/env python3
import re
import requests
import json

from os import environ as env
from requests.auth import HTTPBasicAuth

commit_branch = env["DRONE_COMMIT_BRANCH"]
proget_server = env["proget_server"]
proget_api_key = env["proget_api_key"]

with open(".data.json") as file:
    data = file.read()
    json = json.loads(data)
    pkgver = json["current_pkgver"]
    pkgrel = json["current_pkgrel"]

if commit_branch == "stable":
    package_name = "makedeb"
else:
    package_name = f"makedeb-{commit_branch}"

filename = f"{package_name}_{pkgver}-{pkgrel}_all.deb"

with open(f"./PKGBUILD/{filename}") as file:
    data = file.read()

print("INFO: Uploading package...")
response = post(f"https://{proget_server}/debian/packages/upload/makedeb/main/{filename}", data=data, auth=HTTPBasicAuth("api", proget_api_key))

if response.status_code != 200:
    print(f"ERROR: There was an error uploading the package {response.reason}.")
    exit(1)

print("INFO: Succesfully uploaded package.")
exit(0)
