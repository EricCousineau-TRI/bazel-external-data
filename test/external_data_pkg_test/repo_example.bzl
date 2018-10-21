def _repo_impl(repo):
    f = Label("@bazel_external_data_pkg//:bazel_repo_proxy.py")
    repo.symlink(f, "_cli.py")
    repo.execute(["./_cli.py"], quiet=False)
    repo.file(
        "BUILD.bazel",
        content="""
exports_files(
    srcs = ["test.txt"],
)
""",
    )

_repo = repository_rule(
    implementation = _repo_impl,
)

def add_repo_example_repository(name = "repo_example"):
    _repo(name = "repo_example")
