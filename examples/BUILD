package(default_visibility = ["//visibility:public"])

# This directory contains unit and regression tests that also serve as examples
# for jsonnet rules.  The BUILD rules should not contain any jsonnet_to_json
# rules as this is redundant with jsonnet_to_json_test rules.

load("@rules_jsonnet//jsonnet:jsonnet.bzl", "jsonnet_library", "jsonnet_to_json_test")

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
    regex = 1,
)

jsonnet_to_json_test(
    name = "invalid_failed_test",
    src = "invalid.jsonnet",
    error = 1,
)

jsonnet_to_json_test(
    name = "extvar_env_test",
    size = "small",
    src = "extvar_env.jsonnet",
    ext_code_envs = ["MYJSONNET"],
    ext_str_envs = ["MYTEST"],
    golden = "extvar_env_golden.json",
)

jsonnet_to_json_test(
    name = "extvar_str_test",
    size = "small",
    src = "extvar_str.jsonnet",
    ext_strs = {
        "str": "sun",
        "mydefine": "$(mydefine)",
    },
    golden = "extvar_str_golden.json",
)

jsonnet_to_json_test(
    name = "tlavar_env_test",
    size = "small",
    src = "tlavar_env.jsonnet",
    golden = "extvar_env_golden.json",
    tla_code_envs = ["MYJSONNET"],
    tla_str_envs = ["MYTEST"],
)

jsonnet_to_json_test(
    name = "tlavar_str_test",
    size = "small",
    src = "tlavar_str.jsonnet",
    golden = "extvar_str_golden.json",
    tla_strs = {
        "str": "sun",
        "mydefine": "$(mydefine)",
    },
)

jsonnet_to_json_test(
    name = "extvar_files_generated_test",
    size = "small",
    src = "extvar_files_generated.jsonnet",
    ext_code_file_vars = ["codefile"],
    ext_code_files = [":generated.jsonnet"],
    ext_str_file_vars = ["test"],
    ext_str_files = [":generated.jsonnet"],
    golden = "extvar_files_generated_golden.json",
)

jsonnet_to_json_test(
    name = "extvar_files_test",
    size = "small",
    src = "extvar_files.jsonnet",
    ext_code_file_vars = ["codefile"],
    ext_code_files = [":codefile.libsonnet"],
    ext_str_file_vars = ["test"],
    ext_str_files = [":file.txt"],
    golden = "extvar_files_golden.json",
)

jsonnet_to_json_test(
    name = "tla_code_files_test",
    size = "small",
    src = "tla_code_files.jsonnet",
    golden = "tla_code_files_golden.json",
    tla_code_files = {
        "tla_code_file_input.json": "tla_file",
    },
)

jsonnet_to_json_test(
    name = "tla_str_files_test",
    size = "small",
    src = "tla_code_files.jsonnet",
    golden = "tla_str_files_golden.json",
    tla_str_files = {
        "file.txt": "tla_file",
    },
)

filegroup(
    name = "test_str_files",
    srcs = ["file.txt"],
)

filegroup(
    name = "test_code_files",
    srcs = [
        "codefile.libsonnet",
        "codefile2.libsonnet",
    ],
)

jsonnet_to_json_test(
    name = "extvar_files_test_filegroup",
    size = "small",
    src = "extvar_filegroup.jsonnet",
    ext_code_file_vars = [
        "codefile",
        "codefile2",
    ],
    ext_code_files = [":test_code_files"],
    ext_str_file_vars = ["1-test"],
    ext_str_files = [":test_str_files"],
    golden = "extvar_filegroup_golden.json",
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
    name = "extvar_stamp_test",
    size = "small",
    src = "extvar_stamp.jsonnet",
    ext_code = {
        "complex": "{COMPLEX_JSON}",
        "my_json": "{test: 'something'}",
    },
    ext_strs = {
        "non_stamp": "non_stamp",
        "mydefine": "$(mydefine)",
        "k8s": "{STABLE_K8S_CLUSTER}",
    },
    golden = "extvar_stamp_golden.json",
    stamp_keys = [
        "k8s",
        "complex",
    ],
)

jsonnet_to_json_test(
    name = "tlavar_stamp_test",
    size = "small",
    src = "tlavar_stamp.jsonnet",
    golden = "extvar_stamp_golden.json",
    stamp_keys = [
        "k8s",
        "complex",
    ],
    tla_code = {
        "complex": "{COMPLEX_JSON}",
        "my_json": "{test: 'something'}",
    },
    tla_strs = {
        "non_stamp": "non_stamp",
        "mydefine": "$(mydefine)",
        "k8s": "{STABLE_K8S_CLUSTER}",
    },
)

jsonnet_to_json_test(
    name = "yaml_stream_test",
    src = "yaml_stream.jsonnet",
    golden = "yaml_stream_golden.yaml",
    yaml_stream = 1,
)

jsonnet_to_json_test(
    name = "imports_test",
    src = "imports.jsonnet",
    golden = "imports_golden.json",
    imports = ["imports"],
    deps = ["//imports:a"],
)

jsonnet_to_json_test(
    name = "strings_test",
    src = "strings.jsonnet",
    canonicalize_golden = False,
    extra_args = ["--string"],
    golden = "strings_golden.txt",
)

jsonnet_to_json_test(
    name = "output_file_contents_smoke_test",
    src = "wordcount.jsonnet",
    golden = "wordcount_golden.json",
    output_file_contents = False,
    deps = [":workflow"],
)

jsonnet_to_json_test(
    name = "other_module_test",
    src = "other_module.jsonnet",
    canonicalize_golden = False,
    extra_args = ["--string"],
    golden = "other_module_golden.txt",
    deps = [
        "@other_module//:hello",
        "@other_module//:world",
    ],
)
