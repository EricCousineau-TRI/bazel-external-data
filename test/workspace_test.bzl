def workspace_test(
        name,
        workspace = None,
        cmd="'bazel test //...'",  # *sigh*... Needs quotes.
        data = []):
    if not workspace:
        workspace = name
    datum = "workspaces/{}".format(workspace)
    data_out = [datum]
    args = [
        cmd,
        "$(location {})".format(datum),
    ]
    for datum in data:
        data_out.append(datum)
        args.append("$(locations {})".format(datum))
    native.sh_test(
        name = name,
        srcs = ["workspace_test.sh"],
        args = args,
        data = data_out,
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
