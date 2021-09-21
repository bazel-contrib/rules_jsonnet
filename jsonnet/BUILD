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

alias(
    name = "jsonnet_tool",
    actual = select({
        "//jsonnet:port_cpp": "@jsonnet//cmd:jsonnet",
        "//conditions:default": "@google_jsonnet_go//cmd/jsonnet",
    }),
)
