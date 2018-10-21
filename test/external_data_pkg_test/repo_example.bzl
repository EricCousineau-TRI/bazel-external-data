load("//tools:external_data.bzl", "SETTINGS", "get_original_files")

def external_data_download(repo, files, setup=True):
    """
    Provides a mechanism to download external data files.
    """
    # Add setup files.
    proxy = Label("@bazel_external_data_pkg//:bazel_repo_proxy.py")
    repo.symlink(proxy, proxy.name)
    args = ["./" + proxy.name]
    config = Label(SETTINGS["cli_sentinel"])
    repo.symlink(config, config.name)
    args += ["--project_root_guess=" + config.name]
    if SETTINGS["cli_user_config"]:
        user_config = Label(SETTINGS["cli_user_config"])
        repo.symlink(user_config, user_config.name)
        args += ["--user_config=" + user_config.name]
    # Add data files.
    names = []
    for file in files:
        label = Label(file)
        names.append(label.name)
        repo.symlink(label, label.name)
    # Download.
    args += ["download", "--symlink"] + names
    res = repo.execute(args)
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
