#!/usr/bin/env python2

"""
Provides a mechanism to provide a subset of `//:cli` functionality to leverage
external data in repository rules.
"""

import os
from os.path import abspath, dirname, isdir, islink, join
from shutil import rmtree
from subprocess import call
import sys

repo_dir = dirname(__file__)
assert islink(__file__), ("Must be run via Bazel genfiles", __file__)
bazel_dir = dirname(os.readlink(__file__))

env = dict(os.environ)
env["PYTHONPATH"] = bazel_dir + ":" + env.get("PYTHONPATH", "")
files = [abspath(f) for f in sys.argv[1:]]
args = [
    sys.executable, "-m", "bazel_external_data.cli",
    "--project_root_guess=" + abspath(".external_data.yml"),
    "--user_config=" + abspath("external_data.user.yml"),
    "download", "--symlink"] + files
print(args)
call(args, env=env)
