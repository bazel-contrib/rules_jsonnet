load("@rules_jsonnet//jsonnet:jsonnet.bzl", "jsonnet_library")

jsonnet_library(
    name = "a",
    srcs = ["a.libsonnet"],
    imports = ["tier2/tier3"],
    visibility = ["//:__pkg__"],
    deps = ["//imports/tier2/tier3:b"],
)

jsonnet_library(
    name = "d",
    srcs = ["d.libsonnet"],
    visibility = ["//imports/tier2:__pkg__"],
)
