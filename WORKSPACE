workspace(name = "io_bazel_rules_jsonnet")

load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")

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

load("@google_jsonnet_go//bazel:repositories.bzl", "jsonnet_go_repositories")

jsonnet_go_repositories()

load("@google_jsonnet_go//bazel:deps.bzl", "jsonnet_go_dependencies")

jsonnet_go_dependencies(go_sdk_version = "1.17.8")

# Used for documenting Jsonnet rules.
# TODO: Move this to docs/WORKSPACE when recursive repositories are enabled.
git_repository(
    name = "io_bazel_rules_sass",
    remote = "https://github.com/bazelbuild/rules_sass.git",
    commit = "a28d5ec04b32daef96299b22bb2fbd961c3febe6", # release 1.15.3
    shallow_since = "1546636230 +0000"
)

load("@io_bazel_rules_sass//:package.bzl", "rules_sass_dependencies")

rules_sass_dependencies()

load("@io_bazel_rules_sass//:defs.bzl", "sass_repositories")

sass_repositories()

git_repository(
    name = "io_bazel_skydoc",
    remote = "https://github.com/bazelbuild/skydoc.git",
    commit = "4ea7b8257d11ac33eef7e9daadbedbfe375d9236", # release 0.2.0
    shallow_since = "1543532884 -0500",
)

load("@io_bazel_skydoc//skylark:skylark.bzl", "skydoc_repositories")

skydoc_repositories()
