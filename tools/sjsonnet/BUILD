
# java_toolchain(
#     name = "java_toolchain",
#     encoding = "UTF-8",
#     source_version = "8",
#     target_version = "8",
#     misc = [
#         "-extra_checks:on",
#     ],
# )

java_binary(
    name = "sjsonnet_bin",
    runtime_deps = ["@sjsonnet//jar"],
    main_class = "sjsonnet.SjsonnetMain",
    visibility = ["//visibility:public"],
    create_executable = True,
)
