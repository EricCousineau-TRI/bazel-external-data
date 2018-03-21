#!/usr/bin/env python

"""
Squash a set of new files from a `head` remote to get the minimal set of new of
files for `base`. These files are staged into `merge`.
"""

# TODO(eric.cousineau): Upstream this into `bazel_external_data` if it can ever
# be generalized to be Girder-agnostic.

import os
import subprocess
import sys
import yaml

from bazel_external_data.core import load_project


def add_arguments(parser):
    parser.add_argument(
        "base", type=str, help="Base remote (e.g. `master`)")
    parser.add_argument(
        "head", type=str, help="Head remote (e.g. `devel`)")
    parser.add_argument(
        "merge", type=str,
        help="Merge remote (e.g. `merge`) to contain the files from `head` " +
             "which are new to `base`")
    parser.add_argument(
        "--files", type=str, nargs='*', default=None,
        help="Files to check. By default, checks all files.")
    parser.add_argument(
        "--stage_dir", type=str, default="/tmp/bazel_external_data/merge",
        help="Staging directory for temporarily downloading files")

def run(args, project):
    # Ensure that all remotes are disjoint.
    assert args.base != args.head and args.head != args.merge, (
        "Must supply unique remotes")

    # Remotes.
    base = project._get_remote(args.base)
    head = project._get_remote(args.head)
    merge = project._get_remote(args.merge)

    # List files.
    # TOOD(eric.cousineau): Move this to the project.
    if args.files is None:
        output = subprocess.check_output(
            "find '{root}' -name '*.sha512'".format(root=project.root_path),
            shell=True)
        files = output.strip().split("\n")
    else:
        files = [os.path.abspath(file) for file in args.files]

    for file_abspath in files:
        print(file_abspath)
        info = project.get_file_info(file_abspath, needs_hash=True)
        if args.verbose:
            yaml.dump(
                info.debug_config(), sys.stdout, default_flow_style=False)
        # If the file already exists in `base`, no need to do anything.
        if base.check_file(info.hash, info.project_relpath):
            print("- Skip: {}".format(info.project_relpath))
            continue
        # File not already uploaded: download from `head` to `stage_dir`, then
        # upload to `merge`.
        file_stage_abspath = os.path.join(args.stage_dir, info.project_relpath)
        file_stage_dir = os.path.dirname(file_stage_abspath)
        if not os.path.exists(file_stage_dir):
            os.makedirs(file_stage_dir)
        head.download_file(
            info.hash, info.project_relpath, file_stage_abspath, symlink=True)
        # Upload file to `merge`.
        hash_merge = merge.upload_file(
            info.hash.hash_type, info.project_relpath, file_stage_abspath)
        assert info.hash == hash_merge  # Sanity check
        print("Uploaded: {}".format(info.project_relpath))
