#!/usr/bin/env python

"""
Provides a simple test script for uploading and download a file.
"""

import os
import yaml

from bazel_external_data import core, util, hashes, config_helpers
from bazel_external_data.backends.girder import GirderHashsumBackend

import argparse

assert not util.in_bazel_runfiles()

parser = argparse.ArgumentParser()
parser.add_argument("config_file", type=str)
args = parser.parse_args()

with open(args.config_file) as f:
    config = yaml.load(f)

url = config["url"]
api_key = config["api_key"]
folder_path = "/collection/test/files"

project_root = "/tmp/bazel_external_data/root"
output = "/tmp/bazel_external_data/output"

user_config = core.USER_CONFIG_DEFAULT
user_config.update(yaml.load("""
girder:
  url:
    "{url}":
        api_key: {api_key}
""".format(url=url, api_key=api_key)))
user = core.User(user_config)

config = yaml.load("""
backend: girder_hashsum
url: {url}
folder_path: {folder_path}
""".format(url=url, folder_path=folder_path))

backend = GirderHashsumBackend(config, project_root, user)

relpath = "test.txt"
path = os.path.join(project_root, relpath)

if not os.path.exists(project_root):
    os.makedirs(project_root)
if not os.path.exists(output):
    os.makedirs(output)
with open(path, 'w') as f: f.write("Test file")

hash = hashes.sha512.compute(path)
if not backend.check_file(hash, relpath):
    backend.upload_file(hash, relpath, path)
backend.download_file(hash, relpath, os.path.join(output, relpath))
