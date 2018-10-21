load("//tools:external_data.bzl", "external_data_repository")


def add_repo_example_repository(name = "repo_example"):
    external_data_repository(
        name = "repo_example",
        files = [
            "//data:basic.bin.sha512",
            "//data:glob_1.bin.sha512",
        ],
    )
