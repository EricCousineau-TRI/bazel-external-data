load("//tools:external_data.bzl", "external_data_download")

def _repo_impl(repo):
    names = external_data_download(
        repo,
        files = [
            "//data:basic.bin.sha512",
            "//data:glob_1.bin.sha512",
        ])
    repo.file(
        "BUILD.bazel",
        content="""
exports_files(
    srcs = {},
)
""".format(repr(names)),
    )

_repo = repository_rule(
    implementation = _repo_impl,
    local = True,
)

def add_repo_example_repository(name = "repo_example"):
    _repo(name = "repo_example")
