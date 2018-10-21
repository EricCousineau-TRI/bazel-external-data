load("//tools:external_data.bzl", "SETTINGS")

def _repo_impl(repo):
    repo.symlink(Label("@bazel_external_data_pkg//:bazel_repo_proxy.py"), "_proxy")
    repo.symlink(Label("//:.external_data.yml"), ".external_data.yml")
    repo.symlink(Label("//tools:external_data.user.yml"), "external_data.user.yml")
    repo.symlink(Label("//data:basic.bin.sha512"), "basic.bin.sha512")
    repo.execute(
        ["./_proxy", "basic.bin"],
        quiet=False,
    )
    repo.file(
        "BUILD.bazel",
        content="""
exports_files(
    srcs = ["basic.bin"],
)
""",
    )

_repo = repository_rule(
    implementation = _repo_impl,
    local = True,
)

def add_repo_example_repository(name = "repo_example"):
    _repo(name = "repo_example")
