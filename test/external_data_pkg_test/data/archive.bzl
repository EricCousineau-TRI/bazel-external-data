
def external_data_archive_extract(
        name,
        archive,
        manifest):
    tool = ":archive"
    # https://groups.google.com/forum/#!topic/bazel-discuss/B5WFlG3co4I
    outs = manifest["files"]
    info = dict(
        archive = archive,
        tool = tool,
        output_dir = "$(@D)",
        # Double-load for simplicity.
        # Alternative: Re-write the data to a temp location.
        manifest = archive + ".bzl",
    )
    cmd = ("$(location {tool}) $(location {archive}) " +
           "--manifest $(location {manifest}) --output_dir {output_dir}").format(**info)

    native.genrule(
        name = name,
        srcs = [archive, info["manifest"]],
        outs = outs,
        tools = [tool],
        cmd = cmd,
    )
