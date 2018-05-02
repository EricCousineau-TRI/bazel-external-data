def external_data_archive_extract(
        name,
        archive,
        manifest,
        strip_prefix = "",
        output_dir = ""):
    tool = ":archive"
    if output_dir.endswith("/"):
        fail("`output_dir` must not end with `/`")
    if strip_prefix and not strip_prefix.endswith("/"):
        fail("`strip_prefix` must end with `/` if non-empty")
    # https://groups.google.com/forum/#!topic/bazel-discuss/B5WFlG3co4I
    outs = []
    for file in manifest["files"]:
        if file.startswith(strip_prefix):
            out = file[len(strip_prefix):]
            if output_dir:
                out = output_dir + "/" + out
            outs.append(out)
            print(out)
    info = dict(
        archive = archive,
        tool = tool,
        output_dir = "$(@D)/" + output_dir,
        # Double-load for simplicity.
        # Alternative: Re-write the data to a temp location.
        manifest = archive + ".bzl",
        strip_prefix = strip_prefix,
    )
    print(info["output_dir"])
    cmd = ("$(location {tool}) $(location {archive}) " +
           "--manifest $(location {manifest}) --output_dir '{output_dir}' " +
           "--strip_prefix '{strip_prefix}'").format(**info)
    print(cmd)
    native.genrule(
        name = name,
        srcs = [archive, info["manifest"]],
        outs = outs,
        tools = [tool],
        cmd = cmd,
    )
