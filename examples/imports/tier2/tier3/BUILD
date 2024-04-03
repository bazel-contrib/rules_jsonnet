load("@rules_jsonnet//jsonnet:jsonnet.bzl", "jsonnet_library")

jsonnet_library(
    name = "b",
    srcs = ["b.libsonnet"],
    imports = ["../"],
    deps = ["//imports/tier2:c"],
    visibility = ["//imports:__pkg__"],
)
