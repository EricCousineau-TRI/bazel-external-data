#!/usr/bin/env python

import os
import yaml

from bazel_external_data import core, util, hashes, config_helpers
from bazel_external_data.backends.girder import GirderHashsumBackend

assert not util.in_bazel_runfiles()

with open(os.path.expanduser("~/.config/bazel_external_data/config.yml")) as f:
    user_config = yaml.load(f)

user_config = config_helpers.merge_config(core.USER_CONFIG_DEFAULT, user_config)

project_root = "/tmp/bazel_external_data/root"
output = "/tmp/bazel_external_data/output"

user = core.User(user_config)

config = yaml.load("""
backend: girder_hashsum
url: https://drake-girder.csail.mit.edu
folder_path: /collection/test/files
""")

backend = GirderHashsumBackend(config, project_root, user)

relpath = "test.txt"
path = os.path.join(project_root, relpath)

hash = hashes.sha512.compute(path)
if not backend.check_file(hash, relpath):
    backend.upload_file(hash, relpath, path)
backend.download_file(hash, relpath, os.path.join(output, relpath))
