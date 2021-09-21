# Copyright 2015 The Bazel Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

"""Jsonnet Rules

These are build rules for working with [Jsonnet][jsonnet] files with Bazel.

[jsonnet]: http://google.github.io/jsonnet/doc/

## Setup

To use the Jsonnet rules, add the following to your `WORKSPACE` file to add the
external repositories for Jsonnet:

```python
http_archive(
    name = "io_bazel_rules_jsonnet",
    urls = [
        "http://mirror.bazel.build/github.com/bazelbuild/rules_jsonnet/archive/0.0.2.tar.gz",
        "https://github.com/bazelbuild/rules_jsonnet/archive/0.0.2.tar.gz",
    ],
    sha256 = "5f788c7719a02ed2483641365f194e9e5340fbe54963d6d6caa09f91454d38b8",
    strip_prefix = "rules_jsonnet-0.0.2",
)
load("@io_bazel_rules_jsonnet//jsonnet:jsonnet.bzl", "jsonnet_repositories")

jsonnet_repositories()
```
"""

_JSONNET_FILETYPE = [
    ".jsonnet",
    ".libsonnet",
    ".json",
]

def _add_prefix_to_imports(label, imports):
    imports_prefix = ""
    if label.workspace_root:
        imports_prefix += label.workspace_root + "/"
    if label.package:
        imports_prefix += label.package + "/"
    return [imports_prefix + im for im in imports]

def _setup_deps(deps):
    """Collects source files and import flags of transitive dependencies.

    Args:
      deps: List of deps labels from ctx.attr.deps.

    Returns:
      Returns a struct containing the following fields:
        transitive_sources: List of Files containing sources of transitive
            dependencies
        imports: List of Strings containing import flags set by transitive
            dependency targets.
    """
    transitive_sources = []
    imports = []
    for dep in deps:
        transitive_sources.append(dep.transitive_jsonnet_files)
        imports.append(dep.imports)

    return struct(
        imports = depset(transitive = imports),
        transitive_sources = depset(transitive = transitive_sources, order = "postorder"),
    )

def _jsonnet_library_impl(ctx):
    """Implementation of the jsonnet_library rule."""
    depinfo = _setup_deps(ctx.attr.deps)
    sources = depset(ctx.files.srcs, transitive = [depinfo.transitive_sources])
    imports = depset(_add_prefix_to_imports(ctx.label, ctx.attr.imports), transitive = [depinfo.imports])
    transitive_data = depset(
        transitive = [dep.data_runfiles.files for dep in ctx.attr.deps],
    )

    return struct(
        files = depset(),
        imports = imports,
        runfiles = ctx.runfiles(
            transitive_files = transitive_data,
            collect_data = True,
        ),
        transitive_jsonnet_files = sources,
    )

def _jsonnet_toolchain(ctx):
    return struct(
        jsonnet_path = ctx.executable.jsonnet.path,
    )

def _quote(s):
    return '"' + s.replace('"', '\\"') + '"'

def _stamp_resolve(ctx, string, output):
    stamps = [ctx.info_file, ctx.version_file]
    stamp_args = [
        "--stamp-info-file=%s" % sf.path
        for sf in stamps
    ]
    ctx.actions.run(
        executable = ctx.executable._stamper,
        arguments = [
            "--format=%s" % string,
            "--output=%s" % output.path,
        ] + stamp_args,
        inputs = stamps,
        tools = [ctx.executable._stamper],
        outputs = [output],
        mnemonic = "Stamp",
    )

def _make_resolve(ctx, val):
    if val[0:2] == "$(" and val[-1] == ")":
        return ctx.var[val[2:-1]]
    else:
        return val

def _make_stamp_resolve(ext_vars, ctx, relative = True):
    results = {}
    stamp_inputs = []
    for key, val in ext_vars.items():
        # Check for make variables
        val = _make_resolve(ctx, val)

        # Check for stamp variables
        if ctx.attr.stamp_keys:
            if key in ctx.attr.stamp_keys:
                stamp_file = ctx.actions.declare_file(ctx.label.name + ".jsonnet_" + key)
                _stamp_resolve(ctx, val, stamp_file)
                if relative:
                    val = "$(cat %s)" % stamp_file.short_path
                else:
                    val = "$(cat %s)" % stamp_file.path
                stamp_inputs += [stamp_file]

        results[key] = val

    return results, stamp_inputs

def _jsonnet_to_json_impl(ctx):
    """Implementation of the jsonnet_to_json rule."""

    if ctx.attr.vars:
        print("'vars' attribute is deprecated, please use 'ext_strs'.")
    if ctx.attr.code_vars:
        print("'code_vars' attribute is deprecated, please use 'ext_code'.")

    depinfo = _setup_deps(ctx.attr.deps)
    toolchain = _jsonnet_toolchain(ctx)
    jsonnet_ext_strs = ctx.attr.ext_strs or ctx.attr.vars
    jsonnet_ext_str_envs = ctx.attr.ext_str_envs
    jsonnet_ext_code = ctx.attr.ext_code or ctx.attr.code_vars
    jsonnet_ext_code_envs = ctx.attr.ext_code_envs
    jsonnet_ext_str_files = ctx.files.ext_str_files
    jsonnet_ext_str_file_vars = ctx.attr.ext_str_file_vars
    jsonnet_ext_code_files = ctx.files.ext_code_files
    jsonnet_ext_code_file_vars = ctx.attr.ext_code_file_vars
    jsonnet_tla_strs = ctx.attr.tla_strs
    jsonnet_tla_str_envs = ctx.attr.tla_str_envs
    jsonnet_tla_code = ctx.attr.tla_code
    jsonnet_tla_code_envs = ctx.attr.tla_code_envs
    jsonnet_tla_str_files = ctx.attr.tla_str_files
    jsonnet_tla_code_files = ctx.attr.tla_code_files

    jsonnet_ext_strs, strs_stamp_inputs = _make_stamp_resolve(ctx.attr.ext_strs, ctx, False)
    jsonnet_ext_code, code_stamp_inputs = _make_stamp_resolve(ctx.attr.ext_code, ctx, False)
    jsonnet_tla_strs, tla_strs_stamp_inputs = _make_stamp_resolve(ctx.attr.tla_strs, ctx, False)
    jsonnet_tla_code, tla_code_stamp_inputs = _make_stamp_resolve(ctx.attr.tla_code, ctx, False)
    stamp_inputs = strs_stamp_inputs + code_stamp_inputs + tla_strs_stamp_inputs + tla_code_stamp_inputs

    if ctx.attr.stamp_keys and not stamp_inputs:
        fail("Stamping requested but found no stamp variable to resolve for.")

    other_args = ctx.attr.extra_args + (["-y"] if ctx.attr.yaml_stream else [])

    command = (
        [
            "set -e;",
            toolchain.jsonnet_path,
        ] + ["-J %s" % im for im in _add_prefix_to_imports(ctx.label, ctx.attr.imports)] +
        ["-J %s" % im for im in depinfo.imports.to_list()] + [
            "-J .",
            "-J %s" % ctx.genfiles_dir.path,
            "-J %s" % ctx.bin_dir.path,
        ] + other_args +
        ["--ext-str %s=%s" %
         (_quote(key), _quote(val)) for key, val in jsonnet_ext_strs.items()] +
        ["--ext-str '%s'" %
         ext_str_env for ext_str_env in jsonnet_ext_str_envs] +
        ["--ext-code %s=%s" %
         (_quote(key), _quote(val)) for key, val in jsonnet_ext_code.items()] +
        ["--ext-code %s" %
         ext_code_env for ext_code_env in jsonnet_ext_code_envs] +
        ["--ext-str-file %s=%s" %
         (var, jfile.path) for var, jfile in zip(jsonnet_ext_str_file_vars, jsonnet_ext_str_files)] +
        ["--ext-code-file %s=%s" %
         (var, jfile.path) for var, jfile in zip(jsonnet_ext_code_file_vars, jsonnet_ext_code_files)] +
        ["--tla-str %s=%s" %
         (_quote(key), _quote(val)) for key, val in jsonnet_tla_strs.items()] +
        ["--tla-str '%s'" %
         tla_str_env for tla_str_env in jsonnet_tla_str_envs] +
        ["--tla-code %s=%s" %
         (_quote(key), _quote(val)) for key, val in jsonnet_tla_code.items()] +
        ["--tla-code %s" %
         tla_code_env for tla_code_env in jsonnet_tla_code_envs] +
        ["--tla-str-file %s=%s" %
         (var, jfile.files.to_list()[0].path) for jfile, var in jsonnet_tla_str_files.items()] +
        ["--tla-code-file %s=%s" %
         (var, jfile.files.to_list()[0].path) for jfile, var in jsonnet_tla_code_files.items()]
    )

    outputs = []

    # If multiple_outputs is set to true, then jsonnet will be invoked with the
    # -m flag for multiple outputs. Otherwise, jsonnet will write the resulting
    # JSON to stdout, which is redirected into a single JSON output file.
    if len(ctx.attr.outs) > 1 or ctx.attr.multiple_outputs:
        output_manifest = ctx.actions.declare_file("_%s_outs.mf" % ctx.label.name)
        outputs += ctx.outputs.outs + [output_manifest]
        command += ["-m", ctx.outputs.outs[0].dirname, ctx.file.src.path, "-o", output_manifest.path]
    elif len(ctx.attr.outs) > 1:
        fail("Only one file can be specified in outs if multiple_outputs is " +
             "not set.")
    else:
        compiled_json = ctx.outputs.outs[0]
        outputs += [compiled_json]
        command += [ctx.file.src.path, "-o", compiled_json.path]

    transitive_data = depset(transitive = [dep.data_runfiles.files for dep in ctx.attr.deps] +
                                          [l.files for l in jsonnet_tla_code_files.keys()] +
                                          [l.files for l in jsonnet_tla_str_files.keys()])
    # NB(sparkprime): (1) transitive_data is never used, since runfiles is only
    # used when .files is pulled from it.  (2) This makes sense - jsonnet does
    # not need transitive dependencies to be passed on the commandline. It
    # needs the -J but that is handled separately.

    files = jsonnet_ext_str_files + jsonnet_ext_code_files

    runfiles = ctx.runfiles(
        collect_data = True,
        files = files,
        transitive_files = depset(transitive_data),
    )

    compile_inputs = (
        [ctx.file.src] +
        runfiles.files.to_list() +
        depinfo.transitive_sources.to_list()
    )

    tools = [ctx.executable.jsonnet]

    ctx.actions.run_shell(
        inputs = compile_inputs + stamp_inputs,
        tools = tools,
        outputs = outputs,
        mnemonic = "Jsonnet",
        command = " ".join(command),
        use_default_shell_env = True,
        progress_message = "Compiling Jsonnet to JSON for " + ctx.label.name,
    )

_EXIT_CODE_COMPARE_COMMAND = """
EXIT_CODE=$?
EXPECTED_EXIT_CODE=%d
if [ $EXIT_CODE -ne $EXPECTED_EXIT_CODE ] ; then
  echo "FAIL (exit code): %s"
  echo "Expected: $EXPECTED_EXIT_CODE"
  echo "Actual: $EXIT_CODE"
  if [ %s = true ]; then
    echo "Output: $OUTPUT"
  fi
  exit 1
fi
"""

_DIFF_COMMAND = """
GOLDEN=$(%s %s)
if [ "$OUTPUT" != "$GOLDEN" ]; then
  echo "FAIL (output mismatch): %s"
  echo "Diff:"
  diff <(echo "$GOLDEN") <(echo "$OUTPUT")
  if [ %s = true ]; then
    echo "Expected: $GOLDEN"
    echo "Actual: $OUTPUT"
  fi
  exit 1
fi
"""

_REGEX_DIFF_COMMAND = """
GOLDEN_REGEX=$(%s %s)
if [[ ! "$OUTPUT" =~ $GOLDEN_REGEX ]]; then
  echo "FAIL (regex mismatch): %s"
  if [ %s = true ]; then
    echo "Output: $OUTPUT"
  fi
  exit 1
fi
"""

def _jsonnet_to_json_test_impl(ctx):
    """Implementation of the jsonnet_to_json_test rule."""
    depinfo = _setup_deps(ctx.attr.deps)
    toolchain = _jsonnet_toolchain(ctx)

    golden_files = []
    diff_command = ""
    if ctx.file.golden:
        golden_files += [ctx.file.golden]

        # Note that we only run jsonnet to canonicalize the golden output if the
        # expected return code is 0, and canonicalize_golden was not explicitly disabled.
        # Otherwise, the golden file contains the
        # expected error output.

        # For legacy reasons, we also disable canonicalize_golden for yaml_streams.
        canonicalize = not (ctx.attr.yaml_stream or not ctx.attr.canonicalize_golden)
        dump_golden_cmd = (ctx.executable.jsonnet.short_path if ctx.attr.error == 0 and canonicalize else "/bin/cat")
        if ctx.attr.regex:
            diff_command = _REGEX_DIFF_COMMAND % (
                dump_golden_cmd,
                ctx.file.golden.short_path,
                ctx.label.name,
                "true" if ctx.attr.output_file_contents else "false",
            )
        else:
            diff_command = _DIFF_COMMAND % (
                dump_golden_cmd,
                ctx.file.golden.short_path,
                ctx.label.name,
                "true" if ctx.attr.output_file_contents else "false",
            )

    jsonnet_ext_str_envs = ctx.attr.ext_str_envs
    jsonnet_ext_code_envs = ctx.attr.ext_code_envs
    jsonnet_ext_str_files = ctx.files.ext_str_files
    jsonnet_ext_str_file_vars = ctx.attr.ext_str_file_vars
    jsonnet_ext_code_files = ctx.files.ext_code_files
    jsonnet_ext_code_file_vars = ctx.attr.ext_code_file_vars
    jsonnet_tla_str_envs = ctx.attr.tla_str_envs
    jsonnet_tla_code_envs = ctx.attr.tla_code_envs
    jsonnet_tla_str_files = ctx.attr.tla_str_files
    jsonnet_tla_code_files = ctx.attr.tla_code_files

    jsonnet_ext_strs, strs_stamp_inputs = _make_stamp_resolve(ctx.attr.ext_strs, ctx, True)
    jsonnet_ext_code, code_stamp_inputs = _make_stamp_resolve(ctx.attr.ext_code, ctx, True)
    jsonnet_tla_strs, tla_strs_stamp_inputs = _make_stamp_resolve(ctx.attr.tla_strs, ctx, True)
    jsonnet_tla_code, tla_code_stamp_inputs = _make_stamp_resolve(ctx.attr.tla_code, ctx, True)
    stamp_inputs = strs_stamp_inputs + code_stamp_inputs + tla_strs_stamp_inputs + tla_code_stamp_inputs

    other_args = ctx.attr.extra_args + (["-y"] if ctx.attr.yaml_stream else [])
    jsonnet_command = " ".join(
        ["OUTPUT=$(%s" % ctx.executable.jsonnet.short_path] +
        ["-J %s" % im for im in _add_prefix_to_imports(ctx.label, ctx.attr.imports)] +
        ["-J %s" % im for im in depinfo.imports.to_list()] + ["-J ."] +
        other_args +
        ["--ext-str %s=%s" %
         (_quote(key), _quote(val)) for key, val in jsonnet_ext_strs.items()] +
        ["--ext-str %s" %
         ext_str_env for ext_str_env in jsonnet_ext_str_envs] +
        ["--ext-code %s=%s" %
         (_quote(key), _quote(val)) for key, val in jsonnet_ext_code.items()] +
        ["--ext-code %s" %
         ext_code_env for ext_code_env in jsonnet_ext_code_envs] +
        ["--ext-str-file %s=%s" %
         (var, jfile.path) for var, jfile in zip(jsonnet_ext_str_file_vars, jsonnet_ext_str_files)] +
        ["--ext-code-file %s=%s" %
         (var, jfile.path) for var, jfile in zip(jsonnet_ext_code_file_vars, jsonnet_ext_code_files)] +
        ["--tla-str %s=%s" %
         (_quote(key), _quote(val)) for key, val in jsonnet_tla_strs.items()] +
        ["--tla-str '%s'" %
         tla_str_env for tla_str_env in jsonnet_tla_str_envs] +
        ["--tla-code %s=%s" %
         (_quote(key), _quote(val)) for key, val in jsonnet_tla_code.items()] +
        ["--tla-code %s" %
         tla_code_env for tla_code_env in jsonnet_tla_code_envs] +
        ["--tla-str-file %s=%s" %
         (var, jfile.files.to_list()[0].path) for jfile, var in jsonnet_tla_str_files.items()] +
        ["--tla-code-file %s=%s" %
         (var, jfile.files.to_list()[0].path) for jfile, var in jsonnet_tla_code_files.items()] +
        [
            ctx.file.src.short_path,
            "2>&1)",
        ],
    )

    command = [
        "#!/bin/bash",
        jsonnet_command,
        _EXIT_CODE_COMPARE_COMMAND % (
            ctx.attr.error,
            ctx.label.name,
            "true" if ctx.attr.output_file_contents else "false",
        ),
    ]
    if diff_command:
        command += [diff_command]

    ctx.actions.write(
        output = ctx.outputs.executable,
        content = "\n".join(command),
        is_executable = True,
    )

    transitive_data = depset(
        transitive = [dep.data_runfiles.files for dep in ctx.attr.deps] +
                     [l.files for l in jsonnet_tla_code_files.keys()] +
                     [l.files for l in jsonnet_tla_str_files.keys()],
    )

    test_inputs = (
        [ctx.file.src, ctx.executable.jsonnet] + golden_files +
        transitive_data.to_list() +
        depinfo.transitive_sources.to_list() +
        jsonnet_ext_str_files +
        jsonnet_ext_code_files +
        stamp_inputs
    )

    return struct(
        runfiles = ctx.runfiles(
            files = test_inputs,
            transitive_files = transitive_data,
            collect_data = True,
        ),
    )

_jsonnet_common_attrs = {
    "data": attr.label_list(
        allow_files = True,
    ),
    "imports": attr.string_list(),
    "jsonnet": attr.label(
        default = Label("//jsonnet:jsonnet_tool"),
        cfg = "host",
        executable = True,
        allow_single_file = True,
    ),
    "deps": attr.label_list(
        providers = ["transitive_jsonnet_files"],
        allow_files = False,
    ),
}

_jsonnet_library_attrs = {
    "srcs": attr.label_list(allow_files = _JSONNET_FILETYPE),
}

jsonnet_library = rule(
    _jsonnet_library_impl,
    attrs = dict(_jsonnet_library_attrs.items() +
                 _jsonnet_common_attrs.items()),
)

"""Creates a logical set of Jsonnet files.

Args:
    name: A unique name for this rule.
    srcs: List of `.jsonnet` files that comprises this Jsonnet library.
    deps: List of targets that are required by the `srcs` Jsonnet files.
    imports: List of import `-J` flags to be passed to the `jsonnet` compiler.

Example:
  Suppose you have the following directory structure:

  ```
  [workspace]/
      WORKSPACE
      configs/
          BUILD
          backend.jsonnet
          frontend.jsonnet
  ```

  You can use the `jsonnet_library` rule to build a collection of `.jsonnet`
  files that can be imported by other `.jsonnet` files as dependencies:

  `configs/BUILD`:

  ```python
  load("@io_bazel_rules_jsonnet//jsonnet:jsonnet.bzl", "jsonnet_library")

  jsonnet_library(
      name = "configs",
      srcs = [
          "backend.jsonnet",
          "frontend.jsonnet",
      ],
  )
  ```
"""

_jsonnet_compile_attrs = {
    "src": attr.label(allow_single_file = _JSONNET_FILETYPE),
    "code_vars": attr.string_dict(),  # Deprecated (use 'ext_code').
    "ext_code": attr.string_dict(),
    "ext_code_envs": attr.string_list(),
    "ext_code_file_vars": attr.string_list(),
    "ext_code_files": attr.label_list(
        allow_files = True,
    ),
    "ext_str_envs": attr.string_list(),
    "ext_str_file_vars": attr.string_list(),
    "ext_str_files": attr.label_list(
        allow_files = True,
    ),
    "ext_strs": attr.string_dict(),
    "tla_code": attr.string_dict(),
    "tla_code_envs": attr.string_list(),
    "tla_strs": attr.string_dict(),
    "tla_str_envs": attr.string_list(),
    "tla_str_files": attr.label_keyed_string_dict(allow_files = True),
    "tla_code_files": attr.label_keyed_string_dict(allow_files = True),
    "stamp_keys": attr.string_list(
        default = [],
        mandatory = False,
    ),
    "yaml_stream": attr.bool(
        default = False,
        mandatory = False,
    ),
    "extra_args": attr.string_list(),
    "vars": attr.string_dict(),  # Deprecated (use 'ext_strs').
    "_stamper": attr.label(
        default = Label("//jsonnet:stamper"),
        cfg = "host",
        executable = True,
        allow_files = True,
    ),
}

_jsonnet_to_json_attrs = {
    "outs": attr.output_list(mandatory = True),
    "multiple_outputs": attr.bool(),
}

jsonnet_to_json = rule(
    _jsonnet_to_json_impl,
    attrs = dict(_jsonnet_compile_attrs.items() +
                 _jsonnet_to_json_attrs.items() +
                 _jsonnet_common_attrs.items()),
)

"""Compiles Jsonnet code to JSON.

Args:
  name: A unique name for this rule.

    This name will be used as the name of the JSON file generated by this rule.
  src: The `.jsonnet` file to convert to JSON.
  deps: List of targets that are required by the `src` Jsonnet file.
  outs: Names of the output `.json` files to be generated by this rule.

    If you are generating only a single JSON file and are not using jsonnet
    multiple output files, then this attribute should only contain the file
    name of the JSON file you are generating.

    If you are generating multiple JSON files using jsonnet multiple file output
    (`jsonnet -m`), then list the file names of all the JSON files to be
    generated. The file names specified here must match the file names
    specified in your `src` Jsonnet file.

    For the case where multiple file output is used but only for generating one
    output file, set the `multiple_outputs` attribute to 1 to explicitly enable
    the `-m` flag for multiple file output.
  multiple_outputs: Set to 1 to explicitly enable multiple file output via the
    `jsonnet -m` flag.

    This is used for the case where multiple file output is used but only for
    generating a single output file. For example:

    ```
    local foo = import "foo.jsonnet";

    {
      "foo.json": foo,
    }
    ```
  imports: List of import `-J` flags to be passed to the `jsonnet` compiler.
  vars: *Deprecated* Use `ext_strs`.  Map of variables to pass to jsonnet via
    `--var key=value` flags. Values containing make variables will be expanded.
  code_vars: *Deprecated* Use `ext_code`.  Map of code variables to pass to
    jsonnet via `--code-var key-value` flags.

Example:
  ### Example

  Suppose you have the following directory structure:

  ```
  [workspace]/
      WORKSPACE
      workflows/
          BUILD
          workflow.libsonnet
          wordcount.jsonnet
          intersection.jsonnet
  ```

  Say that `workflow.libsonnet` is a base configuration library for a workflow
  scheduling system and `wordcount.jsonnet` and `intersection.jsonnet` both
  import `workflow.libsonnet` to define workflows for performing a wordcount and
  intersection of two files, respectively.

  First, create a `jsonnet_library` target with `workflow.libsonnet`:

  `workflows/BUILD`:

  ```python
  load("@io_bazel_rules_jsonnet//jsonnet:jsonnet.bzl", "jsonnet_library")

  jsonnet_library(
      name = "workflow",
      srcs = ["workflow.libsonnet"],
  )
  ```

  To compile `wordcount.jsonnet` and `intersection.jsonnet` to JSON, define two
  `jsonnet_to_json` targets:

  ```python
  jsonnet_to_json(
      name = "wordcount",
      src = "wordcount.jsonnet",
      outs = ["wordcount.json"],
      deps = [":workflow"],
  )

  jsonnet_to_json(
      name = "intersection",
      src = "intersection.jsonnet",
      outs = ["intersection.json"],
      deps = [":workflow"],
  )
  ```

  ### Example: Multiple output files

  To use Jsonnet's [multiple output files][multiple-output-files], suppose you
  add a file `shell-workflows.jsonnet` that imports `wordcount.jsonnet` and
  `intersection.jsonnet`:

  `workflows/shell-workflows.jsonnet`:

  ```
  local wordcount = import "workflows/wordcount.jsonnet";
  local intersection = import "workflows/intersection.jsonnet";

  {
    "wordcount-workflow.json": wordcount,
    "intersection-workflow.json": intersection,
  }
  ```

  To compile `shell-workflows.jsonnet` into the two JSON files,
  `wordcount-workflow.json` and `intersection-workflow.json`, first create a
  `jsonnet_library` target containing the two files that
  `shell-workflows.jsonnet` depends on:

  ```python
  jsonnet_library(
      name = "shell-workflows-lib",
      srcs = [
          "wordcount.jsonnet",
          "intersection.jsonnet",
      ],
      deps = [":workflow"],
  )
  ```

  Then, create a `jsonnet_to_json` target and set `outs` to the list of output
  files to indicate that multiple output JSON files are generated:

  ```python
  jsonnet_to_json(
      name = "shell-workflows",
      src = "shell-workflows.jsonnet",
      deps = [":shell-workflows-lib"],
      outs = [
          "wordcount-workflow.json",
          "intersection-workflow.json",
      ],
  )
  ```

  [multiple-output-files]: http://google.github.io/jsonnet/doc/commandline.html
"""

_jsonnet_to_json_test_attrs = {
    "error": attr.int(),
    "golden": attr.label(allow_single_file = True),
    "regex": attr.bool(),
    "canonicalize_golden": attr.bool(default = True),
    "output_file_contents": attr.bool(default = True),
}

jsonnet_to_json_test = rule(
    _jsonnet_to_json_test_impl,
    attrs = dict(_jsonnet_compile_attrs.items() +
                 _jsonnet_to_json_test_attrs.items() +
                 _jsonnet_common_attrs.items()),
    executable = True,
    test = True,
)

"""Compiles Jsonnet code to JSON and checks the output.

Args:
  name: A unique name for this rule.

    This name will be used as the name of the JSON file generated by this rule.
  src: The `.jsonnet` file to convert to JSON.
  deps: List of targets that are required by the `src` Jsonnet file.
  imports: List of import `-J` flags to be passed to the `jsonnet` compiler.
  vars: *Deprecated* Use `ext_strs`.  Map of variables to pass to jsonnet via
    `--var key=value` flags. Values containing make variables will be expanded.
  code_vars: *Deprecated* Use `ext_code`.  Map of code variables to pass to'
    jsonnet via `--code-var key-value` flags.
  golden: The expected (combined stdout and stderr) output to compare to the
    output of running `jsonnet` on `src`.
  error: The expected error code from running `jsonnet` on `src`.
  regex: Set to 1 if `golden` contains a regex used to match the output of
    running `jsonnet` on `src`.

Example:
  Suppose you have the following directory structure:

  ```
  [workspace]/
      WORKSPACE
      config/
          BUILD
          base_config.libsonnet
          test_config.jsonnet
          test_config.json
  ```

  Suppose that `base_config.libsonnet` is a library Jsonnet file, containing the
  base configuration for a service. Suppose that `test_config.jsonnet` is a test
  configuration file that is used to test `base_config.jsonnet`, and
  `test_config.json` is the expected JSON output from compiling
  `test_config.jsonnet`.

  The `jsonnet_to_json_test` rule can be used to verify that compiling a Jsonnet
  file produces the expected JSON output. Simply define a `jsonnet_to_json_test`
  target and provide the input test Jsonnet file and the `golden` file containing
  the expected JSON output:

  `config/BUILD`:

  ```python
  load(
      "@io_bazel_rules_jsonnet//jsonnet:jsonnet.bzl",
      "jsonnet_library",
      "jsonnet_to_json_test",
  )

  jsonnet_library(
      name = "base_config",
      srcs = ["base_config.libsonnet"],
  )

  jsonnet_to_json_test(
      name = "test_config_test",
      src = "test_config",
      deps = [":base_config"],
      golden = "test_config.json",
  )
  ```

  To run the test: `bazel test //config:test_config_test`

  ### Example: Negative tests

  Suppose you have the following directory structure:

  ```
  [workspace]/
      WORKSPACE
      config/
          BUILD
          base_config.libsonnet
          invalid_config.jsonnet
          invalid_config.output
  ```

  Suppose that `invalid_config.jsonnet` is a Jsonnet file used to verify that
  an invalid config triggers an assertion in `base_config.jsonnet`, and
  `invalid_config.output` is the expected error output.

  The `jsonnet_to_json_test` rule can be used to verify that compiling a Jsonnet
  file results in an expected error code and error output. Simply define a
  `jsonnet_to_json_test` target and provide the input test Jsonnet file, the
  expected error code in the `error` attribute, and the `golden` file containing
  the expected error output:

  `config/BUILD`:

  ```python
  load(
      "@io_bazel_rules_jsonnet//jsonnet:jsonnet.bzl",
      "jsonnet_library",
      "jsonnet_to_json_test",
  )

  jsonnet_library(
      name = "base_config",
      srcs = ["base_config.libsonnet"],
  )

  jsonnet_to_json_test(
      name = "invalid_config_test",
      src = "invalid_config",
      deps = [":base_config"],
      golden = "invalid_config.output",
      error = 1,
  )
  ```

  To run the test: `bazel test //config:invalid_config_test`
"""

def jsonnet_repositories():
    """Adds the external dependencies needed for the Jsonnet rules."""
    http_archive(
        name = "jsonnet",
        sha256 = "076b52edf888c01097010ad4299e3b2e7a72b60a41abbc65af364af1ed3c8dbe",
        strip_prefix = "jsonnet-0.17.0",
        urls = [
            "https://github.com/google/jsonnet/archive/v0.17.0.tar.gz",
        ],
    )

    http_archive(
        name = "google_jsonnet_go",
        sha256 = "4fd04d0c9e38572ef388d28ea6b1ac151b8a9a5026ff94e3a68bdbc18c4db38a",
        strip_prefix = "go-jsonnet-0.17.0",
        urls = ["https://github.com/google/go-jsonnet/archive/refs/tags/v0.17.0.tar.gz"],
    )
