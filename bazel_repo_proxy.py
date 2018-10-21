#!/usr/bin/env python2

import os
from os.path import abspath, dirname, isdir, join
from shutil import rmtree
from subprocess import call
import sys

repo_dir = dirname(__file__)
bazel_dir = dirname(os.readlink(__file__))

tgt = join(repo_dir, "tmp")
if isdir(tgt):
    rmtree(tgt)
os.mkdir(tgt)
for f in os.listdir(bazel_dir):
    if f.startswith(".") or f.startswith("bazel-"):
        continue
    os.symlink(join(bazel_dir, f), join(tgt, f))

file = abspath(sys.argv[1])
args = [
    "bazel", "run", "//:cli", "--",
    "--project_root_guess=" + abspath(".external_data.yml"),
    "--user_config=" + abspath("external_data.user.yml"),
    "download", "--symlink", file,
    ]
print(args)
call(args, cwd="tmp")
