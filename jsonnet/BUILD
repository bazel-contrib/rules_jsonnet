load(":toolchain.bzl", "jsonnet_toolchain")
load("@bazel_skylib//:bzl_library.bzl", "bzl_library")

exports_files(["docs.bzl", "jsonnet.bzl", "toolchain.bzl"])

bzl_library(
    name = "bzl_srcs",
    srcs = ["@bazel_tools//tools:bzl_srcs"],
)

bzl_library(
    name = "docs",
    srcs = [
        "docs.bzl",
        "jsonnet.bzl",
        "toolchain.bzl",
    ],
    visibility = ["//visibility:public"],
    deps = [
        ":bzl_srcs",
        "@bazel_skylib//lib:paths",
        "@bazel_skylib//lib:shell",
    ],
)

py_binary(
    name = "stamper",
    srcs = ["stamper.py"],
    main = "stamper.py",
    visibility = ["//visibility:public"],
)

toolchain_type(name = "toolchain_type")

jsonnet_toolchain(
    name = "rust_jsonnet",
    compiler = "@crates//:jrsonnet__jrsonnet",
    create_directory_flags = ["-c"],
    manifest_file_support = False,
)

jsonnet_toolchain(
    name = "go_jsonnet",
    compiler = "@jsonnet_go//cmd/jsonnet",
    create_directory_flags = ["-c"],
    manifest_file_support = True,
)

jsonnet_toolchain(
    name = "cpp_jsonnet",
    compiler = "@jsonnet//cmd:jsonnet",
    create_directory_flags = [],
    manifest_file_support = True,
)

toolchain(
    name = "rust_jsonnet_toolchain",
    toolchain = ":rust_jsonnet",
    toolchain_type = ":toolchain_type",
    visibility = ["//visibility:public"],
)

toolchain(
    name = "go_jsonnet_toolchain",
    toolchain = ":go_jsonnet",
    toolchain_type = ":toolchain_type",
    visibility = ["//visibility:public"],
)

toolchain(
    name = "cpp_jsonnet_toolchain",
    toolchain = ":cpp_jsonnet",
    toolchain_type = ":toolchain_type",
    visibility = ["//visibility:public"],
)
