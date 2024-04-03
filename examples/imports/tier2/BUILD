load("@rules_jsonnet//jsonnet:jsonnet.bzl", "jsonnet_library")

jsonnet_library(
    name = "c",
    srcs = ["c.libsonnet"],
    imports = ["../"],
    deps = ["//imports:d"],
    visibility = ["//imports/tier2/tier3:__pkg__"],
)
