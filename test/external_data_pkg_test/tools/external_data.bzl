# Pass through.
load("@bazel_external_data_pkg//:external_data.bzl",
    _external_data="external_data",
    _external_data_download="external_data_download",
    _external_data_group="external_data_group",
    "get_original_files",
    "extract_archive",
)

SETTINGS = dict(
    cli_sentinel = "//:.external_data.yml",
    cli_user_config = "//tools:external_data.user.yml",
)


def external_data(*args, **kwargs):
    _external_data(
        *args,
        settings = SETTINGS,
        **kwargs
    )


def external_data_group(*args, **kwargs):
    _external_data_group(
        *args,
        settings = SETTINGS,
        **kwargs
    )


def external_data_download(*args, **kwargs):
    return _external_data_download(
        *args,
        settings = SETTINGS,
        prefix = "@external_data_pkg_test",
        **kwargs
    )
