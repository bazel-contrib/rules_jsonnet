"""\
# Jsonnet Rules

These are build rules for working with [Jsonnet][jsonnet] files with Bazel.

[jsonnet]: https://jsonnet.org/

## Setup

To use the Jsonnet rules as part of your Bazel project, please follow the
instructions on [the releases page](https://github.com/bazelbuild/rules_jsonnet/releases).
"""

load("//jsonnet:toolchain.bzl", _jsonnet_toolchain = "jsonnet_toolchain")
load(
    "//jsonnet:jsonnet.bzl",
    _jsonnet_library = "jsonnet_library",
    _jsonnet_to_json = "jsonnet_to_json",
    _jsonnet_to_json_test = "jsonnet_to_json_test",
)

jsonnet_toolchain = _jsonnet_toolchain
jsonnet_library = _jsonnet_library
jsonnet_to_json = _jsonnet_to_json
jsonnet_to_json_test = _jsonnet_to_json_test
