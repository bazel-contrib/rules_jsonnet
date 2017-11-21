workspace(name = "io_bazel_rules_jsonnet")

local_repository(
    name = "examples",
    path = "examples",
)

local_repository(
    name = "docs",
    path = "docs",
)

# TODO: Move this to examples/WORKSPACE when recursive repositories are enabled.
load("//jsonnet:jsonnet.bzl", "jsonnet_repositories")

jsonnet_repositories()

# Used for documenting Jsonnet rules.
# TODO: Move this to docs/WORKSPACE when recursive repositories are enabled.
git_repository(
    name = "io_bazel_rules_sass",
    remote = "https://github.com/bazelbuild/rules_sass.git",
    tag = "0.0.3",
)

load("@io_bazel_rules_sass//sass:sass.bzl", "sass_repositories")

sass_repositories()

git_repository(
    name = "io_bazel_skydoc",
    remote = "https://github.com/bazelbuild/skydoc.git",
    tag = "0.1.3",
)

load("@io_bazel_skydoc//skylark:skylark.bzl", "skydoc_repositories")

skydoc_repositories()
