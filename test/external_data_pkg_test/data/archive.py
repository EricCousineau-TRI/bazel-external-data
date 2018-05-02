import argparse
import tarfile

parser = argparse.ArgumentParser()
parser.add_argument("archive", type=str)
parser.add_argument("--manifest", type=str)
parser.add_argument("--output_dir", type=str)

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
manifest_files = sorted(manifest["file"])
# Demand exact matching.
assert tar_files == manifest_files, (
    "Mismatch in manifest and tarfile; please regenerate tarfile manifest.")

# Extract all files.
f.extractall(path=args.output_dir, members=members)
