import argparse
import tarfile

parser = argparse.ArgumentParser()
parser.add_argument("archive", type=str)
parser.add_argument("--manifest", type=str)
parser.add_argument("--output_dir", type=str)

args = parser.parse_args()

import os
print(os.getcwd())

with open(args.manifest) as f:
    manifest_text = f.read()
manifest_locals = {}
exec(manifest_text, globals(), manifest_locals)
manifest = manifest_locals["manifest"]

# First require the manifest exactly match the files present in the archive.
f = tarfile.open(args.archive, 'r')
# - We only allow regular files; not going to deal with symlinks or devices for
# now.
members = [member for member in f.getmembers() if member.isfile()]
tar_files = sorted((member.name for member in members))
manifest_files = sorted(manifest["files"])
# Demand exact matching.
if tar_files != manifest_files:
    tar_not_manifest = set(tar_files) - set(manifest_files)
    manifest_not_tar = set(manifest_files) - set(tar_files)
    print("Files in tar, not manifest:")
    print("  " + "\n  ".join(tar_not_manifest))
    print("Files in manifest, not tar:")
    print("  " + "\n  ".join(manifest_not_tar))
    raise RuntimeError(
        "Mismatch in manifest and tarfile; please regenerate tarfile manifest.")

# Extract all files.
f.extractall(path=args.output_dir, members=members)
