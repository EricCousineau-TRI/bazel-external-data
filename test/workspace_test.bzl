def workspace_test(workspace, workspace_deps = []):
    path = "workspaces/{}".format(workspace)
    data = [
        path,
        "//:root_data",
    ]
    args = [
        "'bazel test //...'",  # *sigh*
        "$(location {})".format(path),
    ]
    for dep in workspace_deps:
        extra_workspace = "workspaces/{}".format(dep)
        data.append(extra_workspace)
        args.append("$(location {})".format(extra_workspace))
    native.sh_test(
        name = workspace,
        srcs = ["copy_and_test.sh"],
        args = args,
        data = data,
    )

def workspace_test_bad(workspace):
    files = workspace + "__files"
    path = "workspaces/{}".format(workspace)

    # WARNING: If this finds `/bazel-*` symlinks, it will loop forever.
    # Even adding it to `exclude` will not prevent it...

    # TODO: Bazel even *ignores* its own files that causes it to screw up...
    # File a bug, and figure out how to write a rule that will check for these and fail-fast.
    bad_files = native.glob([path + "/bazel-*"])
    if bad_files:
        fail("Bazel does not handle its own symlinks well; please remove them from your source tree.")

    native.filegroup(
        name = files,
        srcs = native.glob([path + "/**/*"], [path + "/bazel-*"]),
    )

    native.sh_test(
        name = workspace,
        srcs = ["eval.sh"],
        args = [
            "cd $(location {}) && bazel test //...".format(path),
        ],
        data = [
            # Consume the directory so that we may copy it.
            path,
            files,
            "//:root_data",
        ],
        tags = ["meta"],
    )
