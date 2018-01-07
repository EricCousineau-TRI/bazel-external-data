def meta_test(workspace):
    files = workspace + "__files"
    pkg_path = "pkgs/{}".format(workspace)

    # WARNING: If this finds `/bazel-*` symlinks, it will loop forever.
    # Even adding it to `exclude` will not prevent it...

    # TODO: Bazel even *ignores* its own files that causes it to screw up...
    # File a bug, and figure out how to write a rule that will check for these and fail-fast.
    bad_files = native.glob([pkg_path + "/bazel-*"])
    if bad_files:
        fail("Bazel does not handle its own symlinks well; please remove them from your source tree.")

    native.filegroup(
        name = files,
        srcs = native.glob([pkg_path + "/**/*"], [pkg_path + "/bazel-*"]),
    )

    native.sh_test(
        name = workspace,
        srcs = ["eval.sh"],
        args = [
            "cd $(location {}) && bazel test //...".format(pkg_path),
        ],
        data = [
            # Consume the directory so that we may copy it.
            pkg_path,
            files,
            "//:pkg_data",
        ],
        tags = ["meta"],
    )
