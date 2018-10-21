#!/usr/bin/env python2

import os
from os.path import dirname, isdir, join
from shutil import rmtree
from subprocess import call

repo_dir = dirname(__file__)
bazel_dir = dirname(os.readlink(__file__))
print(repo_dir)
print(bazel_dir)

tgt = join(repo_dir, "tmp")
if isdir(tgt):
    rmtree(tgt)
os.mkdir(tgt)
for f in os.listdir(bazel_dir):
    if f.startswith(".") or f.startswith("bazel-"):
        continue
    print(f)
    os.symlink(join(bazel_dir, f), join(tgt, f))

call(["bazel", "run", "//:cli", "--", "--help"], cwd="tmp")

with open("test.txt", "w") as f:
    f.write("Hello world\n")
