#!/usr/bin/env python2

"""
Provides a mechanism to provide a subset of `//:cli` functionality to leverage
external data in repository rules.
"""

import os
from os.path import dirname, islink
import sys

repo_dir = dirname(__file__)
assert islink(__file__), ("Must be run via Bazel genfiles", __file__)
bazel_dir = dirname(os.readlink(__file__))
# Inject original code into Python path.
env = dict(os.environ)
env["PYTHONPATH"] = bazel_dir + ":" + env.get("PYTHONPATH", "")

args = [sys.executable, "-m", "bazel_external_data.cli"] + sys.argv[1:]
os.execve(args[0], args, env)
