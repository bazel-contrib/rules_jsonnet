package(default_visibility = ["//visibility:public"])

exports_files(["jsonnet.bzl"])

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

config_setting(
    name = "port_scala",
    define_values = {
        "jsonnet_port": "scala",
    },
)

alias(
    name = "jsonnet_tool",
    actual = select({
        "//jsonnet:port_cpp": "@jsonnet//cmd:jsonnet",
        "//jsonnet:port_scala": "//tools/sjsonnet:sjsonnet_bin",
        "//conditions:default": "@jsonnet_go//cmd/jsonnet",
    }),
)
