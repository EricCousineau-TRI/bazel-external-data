load(
    "//tools:external_data.bzl",
    "external_data_download",
    "external_data_extract",
    "external_data_repository",
)

def add_repo_example_repository(name = "repo_example"):
    external_data_repository(
        name = name,
        files = [
            "//data:basic.bin.sha512",
            "//data:glob_1.bin.sha512",
        ],
    )

def _impl(ctx):
    (name,) = external_data_download(ctx, ["//data:archive.tar.gz.sha512"])
    external_data_extract(
        ctx, name, strip_prefix="archive/", output_dir="test_data")
    ctx.file("BUILD.bazel", content="""
filegroup(
    name = "data",
    srcs = glob(["**/*.bin"]),
    visibility = ["//visibility:public"],
)
""")

_repo = repository_rule(implementation = _impl, local=True)

def add_repo_archive_repository(name = "repo_archive"):
    _repo(name = name)
