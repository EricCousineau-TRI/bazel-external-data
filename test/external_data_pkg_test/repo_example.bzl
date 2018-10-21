load("//tools:external_data.bzl", "SETTINGS", "get_original_files")

def external_data_download(repo, files, setup=True):
    if setup:
        setup_files = [
            "@bazel_external_data_pkg//:bazel_repo_proxy.py",
            SETTINGS["cli_sentinel"],
            SETTINGS["cli_user_config"],
        ]
        for file in setup_files:
            label = Label(file)
            repo.symlink(label, label.name)
    names = []
    for file in files:
        label = Label(file)
        names.append(label.name)
        repo.symlink(label, label.name)
    res = repo.execute(["./bazel_repo_proxy.py"] + names)
    if res.return_code != 0:
        fail("External data failure: {}\n{}".format(res.stdout, res.stderr))
    return get_original_files(names)


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
