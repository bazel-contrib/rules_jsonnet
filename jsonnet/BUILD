load("@bazel_skylib//:bzl_library.bzl", "bzl_library")

exports_files(["jsonnet.bzl"])

bzl_library(
    name = "bzl_srcs",
    srcs = ["@bazel_tools//tools:bzl_srcs"],
)

bzl_library(
    name = "jsonnet",
    srcs = ["jsonnet.bzl"],
    deps = [":bzl_srcs"],
    visibility = ["//visibility:public"],
)

py_binary(
    name = "stamper",
    srcs = ["stamper.py"],
    main = "stamper.py",
    visibility = ["//visibility:public"],
)

config_setting(
    name = "port_cpp",
    define_values = {
        "jsonnet_port": "cpp",
    },
)

config_setting(
    name = "port_go",
    define_values = {
        "jsonnet_port": "go",
    },
)

alias(
    name = "jsonnet_tool",
    actual = select({
        "//jsonnet:port_cpp": "@jsonnet//cmd:jsonnet",
        "//conditions:default": "@google_jsonnet_go//cmd/jsonnet",
    }),
    visibility = ["//visibility:public"],
)
