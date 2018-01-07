#!/bin/bash
set -e -u

# Prevent from running outside of Bazel.
if [[ ! $(basename $(dirname ${PWD})) =~ .*\.runfiles ]]; then
    echo "Must be run from within Bazel"
    exit 1
fi

cmd=$(eval echo ${1})
echo ${cmd}
pkg_reldir=${2}
shift && shift
extra_dirs="$@"

export COPY_AND_TEST=1
export TMP_BASE=/tmp/bazel_external_data
mkdir -p ${TMP_BASE}
export TMP_DIR=$(mktemp -d -p ${TMP_BASE})

mock_dir=${TMP_DIR}/mock_workspace

rm -rf ${mock_dir}

# Copy what's needed for a modifiable `bazel_pkg_advanced_test` directory.
srcs="src tools BUILD.bazel WORKSPACE ${pkg_reldir} ${extra_dirs}"
mkdir -p ${mock_dir}
readlink_py() { python -c 'import os, sys; print(os.path.realpath(sys.argv[1]))' ${1}; }
for src in ${srcs}; do
    subdir=$(dirname ${src})
    mkdir -p ${mock_dir}/${subdir}
    cp -r $(readlink_py ${src}) ${mock_dir}/${subdir}
done

cd ${mock_dir}/${pkg_reldir}
eval ${cmd}
