load("//tools:external_data.bzl", "SETTINGS")

def external_data_repository_files(repo, files):
    repo.symlink(Label("@bazel_external_data_pkg//:bazel_repo_proxy.py"), "_proxy")
    f = Label(SETTINGS["cli_sentinel"])
    repo.symlink(f, f.name)
    f = Label(SETTINGS["cli_user_config"])
    repo.symlink(f, f.name)
    bases = []
    for file in files:
        _, base = file.split(":")
        bases.append(base)
        repo.symlink(Label(file), base)
    res = repo.execute(["./_proxy"] + bases)
    if res.return_code != 0:
        fail(res.stdout + res.stderr)


def _repo_impl(repo):
    external_data_repository_files(
        repo,
        files = [
            "//data:basic.bin.sha512",
            "//data:glob_1.bin.sha512",
        ])
    repo.file(
        "BUILD.bazel",
        content="""
exports_files(
    srcs = glob(["*.bin"]),
)
""",
    )

_repo = repository_rule(
    implementation = _repo_impl,
    local = True,
)

def add_repo_example_repository(name = "repo_example"):
    _repo(name = "repo_example")
