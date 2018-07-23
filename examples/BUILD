package(default_visibility = ["//visibility:public"])

# This directory contains unit and regression tests that also serve as examples
# for jsonnet rules.  The BUILD rules should not contain any jsonnet_to_json
# rules as this is redundant with jsonnet_to_json_test rules.

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

jsonnet_to_json_test(
    name = "wordcount_test",
    src = "wordcount.jsonnet",
    golden = "wordcount_golden.json",
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

jsonnet_to_json_test(
    name = "shell-workflows",
    src = "shell-workflows.jsonnet",
    golden = "shell-workflows_golden.json",
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

jsonnet_to_json_test(
    name = "files_test",
    size = "small",
    src = "files.jsonnet",
    ext_code_envs = ["MYJSONNET"],
    ext_code_file_vars = ["codefile"],
    ext_code_files = [":codefile.libsonnet"],
    ext_str_envs = ["MYTEST"],
    ext_str_file_vars = ["test"],
    ext_str_files = [":file.txt"],
    ext_strs = {
        "str": "sun",
        "mydefine": "$(mydefine)",
    },
    golden = "files.out",
)

jsonnet_to_json_test(
    name = "generated_src_test",
    src = ":generated",
    golden = ":generated",
)

genrule(
    name = "generated",
    testonly = 1,
    outs = ["generated.jsonnet"],
    cmd = "echo {} > $@",
)

jsonnet_to_json_test(
    name = "yaml_stream_test",
    src = "yaml_stream.jsonnet",
    golden = "yaml_stream_golden.yaml",
    yaml_stream = 1,
)
