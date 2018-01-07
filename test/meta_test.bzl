def meta_test(workspace, workspace_deps = []):
    pkg = "pkgs/{}".format(workspace)
    data = [
        pkg,
        "//:pkg_data",
    ]
    args = [
        "'bazel test //...'",  # *sigh*
        "$(location {})".format(pkg),
    ]
    for dep in workspace_deps:
        extra_pkg = "pkgs/{}".format(dep)
        data.append(extra_pkg)
        args.append("$(location {})".format(extra_pkg))
    native.sh_test(
        name = workspace,
        srcs = ["copy_and_test.sh"],
        args = args,
        data = data,
    )

def meta_test_bad(workspace):
    files = workspace + "__files"
    pkg = "pkgs/{}".format(workspace)

    # WARNING: If this finds `/bazel-*` symlinks, it will loop forever.
    # Even adding it to `exclude` will not prevent it...

    # TODO: Bazel even *ignores* its own files that causes it to screw up...
    # File a bug, and figure out how to write a rule that will check for these and fail-fast.
    bad_files = native.glob([pkg + "/bazel-*"])
    if bad_files:
        fail("Bazel does not handle its own symlinks well; please remove them from your source tree.")

    native.filegroup(
        name = files,
        srcs = native.glob([pkg + "/**/*"], [pkg + "/bazel-*"]),
    )

    native.sh_test(
        name = workspace,
        srcs = ["eval.sh"],
        args = [
            "cd $(location {}) && bazel test //...".format(pkg),
        ],
        data = [
            # Consume the directory so that we may copy it.
            pkg,
            files,
            "//:pkg_data",
        ],
        tags = ["meta"],
    )
