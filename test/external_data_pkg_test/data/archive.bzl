def extract_archive(
        name,
        archive,
        manifest,
        strip_prefix = "",
        output_dir = ""):
    """Extracts an archive into a Bazel genfiles tree.

    @param archive
        Archive to be extracted.
    @param manifest
        Manifest dictionary. Due to constraints in Bazel, we must load this
        outside of this function
    """
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
    if len(outs) == 1:
        # See silly rule here for how `@D` changes based on number of outputs:
        # https://docs.bazel.build/versions/master/be/make-variables.html
        output_dir_full = "$(@D)"
    elif len(outs) == 0:
        fail(("archive: There are no outputs, and empty genrule's are " +
              "invalid.\n" +
              "  After `strip_prefix` filtering, there were no outputs, but " +
               "there were {} original files. Did you use the wrong prefix?")
              .format(len(manifest["files"])))
    else:
        output_dir_full = "$(@D)/" + output_dir
    tool = ":extract_archive"
    info = dict(
        archive_file = archive,
        tool = tool,
        output_dir_full = output_dir_full,
        # Double-load for simplicity.
        # Alternative: Re-write the data to a temp location.
        manifest_file = archive + ".manifest.bzl",
        strip_prefix = strip_prefix,
    )
    cmd = ("$(location {tool}) $(location {archive_file}) " +
           "--manifest $(location {manifest_file}) " +
           "--output_dir '{output_dir_full}' " +
           "--strip_prefix '{strip_prefix}'").format(**info)
    native.genrule(
        name = name,
        srcs = [archive, info["manifest_file"]],
        outs = outs,
        tools = [tool],
        cmd = cmd,
    )
