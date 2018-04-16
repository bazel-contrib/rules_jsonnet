package(default_visibility = ["//visibility:public"])

load(
    "@io_bazel_rules_jsonnet//jsonnet:jsonnet.bzl",
    "jsonnet_library",
    "jsonnet_to_json",
    "jsonnet_to_json_test",
)

jsonnet_library(
    name = "workflow",
    srcs = ["workflow.libsonnet"],
)

jsonnet_to_json(
    name = "wordcount",
    src = "wordcount.jsonnet",
    outs = ["wordcount.json"],
    deps = [":workflow"],
)

jsonnet_to_json_test(
    name = "wordcount_test",
    src = "wordcount.jsonnet",
    golden = "wordcount_golden.json",
    deps = [":workflow"],
)

jsonnet_to_json(
    name = "intersection",
    src = "intersection.jsonnet",
    outs = ["intersection.json"],
    deps = [":workflow"],
)

jsonnet_to_json_test(
    name = "intersection_test",
    src = "intersection.jsonnet",
    golden = "intersection_golden.json",
    deps = [":workflow"],
)

jsonnet_library(
    name = "shell-workflows-lib",
    srcs = [
        "intersection.jsonnet",
        "wordcount.jsonnet",
    ],
    deps = [":workflow"],
)

jsonnet_to_json(
    name = "shell-workflows",
    src = "shell-workflows.jsonnet",
    outs = [
        "intersection-workflow.json",
        "wordcount-workflow.json",
    ],
    deps = [":shell-workflows-lib"],
)

jsonnet_to_json_test(
    name = "invalid_test",
    src = "invalid.jsonnet",
    error = 1,
    golden = "invalid.out",
)

jsonnet_to_json_test(
    name = "invalid_failed_test",
    src = "invalid.jsonnet",
    error = 1,
)

jsonnet_to_json(
    name = "files",
    src = "files.jsonnet",
    outs = ["files.json"],
    ext_str_envs = ["MYTEST"],
    ext_code_envs = ["MYJSONNET"],
    ext_str_files = [":file.txt"],
    ext_str_file_vars = ["test"],
    ext_code_files = [":codefile.libsonnet"],
    ext_code_file_vars = ["codefile"],
)

jsonnet_to_json_test(
    name = "files_test",
    size = "small",
    src = "files.jsonnet",
    ext_str_envs = ["MYTEST"],
    ext_code_envs = ["MYJSONNET"],
    ext_str_files = [":file.txt"],
    ext_str_file_vars = ["test"],
    ext_code_files = [":codefile.libsonnet"],
    ext_code_file_vars = ["codefile"],
    golden = "files.out",
)

jsonnet_to_json_test(
    name = "generated_src_test",
    src = ":generated",
    golden = ":generated"
)

genrule(
    name = "generated",
    outs = ["generated.jsonnet"],
    testonly = 1,
    cmd = "echo {} > $@"
)
