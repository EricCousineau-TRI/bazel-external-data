#!/usr/bin/env python2

"""
Provides a mechanism to provide a subset of `//:cli` functionality to leverage
external data in repository rules.
"""

import os
from os.path import abspath, dirname, isdir, join
from shutil import rmtree
from subprocess import call
import sys

repo_dir = dirname(__file__)
bazel_dir = dirname(os.readlink(__file__))

# Create temporary bazel workspace to emulate `bazel_external_data_pkg`.
work_dir = join(repo_dir, "bazel_external_data_pkg")
if isdir(work_dir):
    rmtree(work_dir)
os.mkdir(work_dir)
for f in os.listdir(bazel_dir):
    if f.startswith(".") or f.startswith("bazel-"):
        continue
    os.symlink(join(bazel_dir, f), join(work_dir, f))

files = [abspath(f) for f in sys.argv[1:]]
args = [
    "bazel", "run", "//:cli", "--",
    "--project_root_guess=" + abspath(".external_data.yml"),
    "--user_config=" + abspath("external_data.user.yml"),
    "download", "--symlink"] + files
call(args, cwd=work_dir)
rmtree(work_dir)
