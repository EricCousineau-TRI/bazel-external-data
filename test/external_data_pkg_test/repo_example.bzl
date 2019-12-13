load(
    "//tools:external_data.bzl",
    "external_data_repository_download",
)

def _impl(repo_ctx):
    (archive,) = external_data_repository_download(
        repo_ctx,
        ["@external_data_pkg_test//data:archive.tar.gz.sha512"],
    )
    # Use the `extract` functionality from `download_and_extract`.
    # N.B. This will complain about not having a SHA256. Consider just using
    # `tar` or what not.
    repo_ctx.download_and_extract(
        "file://{}".format(repo_ctx.path(archive)),
        stripPrefix = "archive/",
        output="test_data/",
    )
    repo_ctx.file("BUILD.bazel", content="""
filegroup(
    name = "data",
    srcs = glob(["**/*.bin"]),
    visibility = ["//visibility:public"],
)
""")

_repo = repository_rule(implementation = _impl, local = True)

def add_repo_archive_repository(name = "repo_archive"):
    _repo(name = name)
