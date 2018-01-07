#!/bin/bash
set -e -u

# Runs tests in different Bazel workspaces.

cd $(dirname $0)

bazel() {
    $(which bazel) --bazelrc=/dev/null "$@"
}

echo "[ Example Interface ]"
(
    cd pkgs/bazel_pkg_test
    bazel test //...
)

echo "[ Downstream Consumption ]"
(
    cd pkgs/bazel_pkg_downstream_test
    bazel test //...
)

echo "[ Mock Storage ]"
(
    cd pkgs/bazel_pkg_advanced_test
    bazel test //...
)

echo "[ Workflows ]"
(
    bazel test --test_output=streamed :workflows_test
)
