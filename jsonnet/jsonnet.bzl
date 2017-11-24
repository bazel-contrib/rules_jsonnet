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

_JSONNET_FILETYPE = FileType([".jsonnet", ".libsonnet"])

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
  transitive_sources = depset(order="postorder")
  imports = depset()
  for dep in deps:
    transitive_sources += dep.transitive_jsonnet_files
    imports += ["%s/%s" % (dep.label.package, im) for im in dep.imports]

  return struct(
      transitive_sources = transitive_sources,
      imports = imports)

def _jsonnet_library_impl(ctx):
  """Implementation of the jsonnet_library rule."""
  depinfo = _setup_deps(ctx.attr.deps)
  sources = depinfo.transitive_sources + ctx.files.srcs
  imports = depinfo.imports + ctx.attr.imports
  transitive_data = depset()
  for dep in ctx.attr.deps:
    transitive_data += dep.data_runfiles.files
  return struct(
      files = depset(),
      transitive_jsonnet_files = sources,
      imports = imports,
      runfiles = ctx.runfiles(
          transitive_files = transitive_data,
          collect_data = True,
      ))

def _jsonnet_toolchain(ctx):
  return struct(
      jsonnet_path = ctx.executable.jsonnet.path)

def _jsonnet_to_json_impl(ctx):
  """Implementation of the jsonnet_to_json rule."""
  depinfo = _setup_deps(ctx.attr.deps)
  toolchain = _jsonnet_toolchain(ctx)
  jsonnet_vars = ctx.attr.vars
  jsonnet_code_vars = ctx.attr.code_vars
  command = (
      [
          "set -e;",
          toolchain.jsonnet_path,
      ] +
      ["-J %s/%s" % (ctx.label.package, im) for im in ctx.attr.imports] +
      ["-J %s" % im for im in depinfo.imports] +
      ["-J ."] +
      ["--var '%s'='%s'"
       % (var, jsonnet_vars[var]) for var in jsonnet_vars.keys()] +
      ["--code-var '%s'='%s'"
       % (var, jsonnet_code_vars[var]) for var in jsonnet_code_vars.keys()])

  outputs = []
  # If multiple_outputs is set to true, then jsonnet will be invoked with the
  # -m flag for multiple outputs. Otherwise, jsonnet will write the resulting
  # JSON to stdout, which is redirected into a single JSON output file.
  if len(ctx.attr.outs) > 1 or ctx.attr.multiple_outputs:
    outputs += ctx.outputs.outs
    command += ["-m", ctx.outputs.outs[0].dirname, ctx.file.src.path]
  elif len(ctx.attr.outs) > 1:
      fail("Only one file can be specified in outs if multiple_outputs is " +
           "not set.")
  else:
    compiled_json = ctx.outputs.outs[0]
    outputs += [compiled_json]
    command += [ctx.file.src.path, "-o", compiled_json.path]

  transitive_data = depset()
  for dep in ctx.attr.deps:
    transitive_data + dep.data_runfiles.files

  runfiles = ctx.runfiles(
      collect_data = True,
      transitive_files = transitive_data,
  )

  compile_inputs = (
      [ctx.file.src, ctx.executable.jsonnet] +
      list(runfiles.files) +
      list(depinfo.transitive_sources))

  ctx.action(
      inputs = compile_inputs,
      outputs = outputs,
      mnemonic = "Jsonnet",
      command = " ".join(command),
      use_default_shell_env = True,
      progress_message = "Compiling Jsonnet to JSON for " + ctx.label.name)

_EXIT_CODE_COMPARE_COMMAND = """
EXIT_CODE=$?
EXPECTED_EXIT_CODE=%d
if [ $EXIT_CODE -ne $EXPECTED_EXIT_CODE ] ; then
  echo "FAIL (exit code): %s"
  echo "Expected: $EXPECTED_EXIT_CODE"
  echo "Actual: $EXIT_CODE"
  echo "Output: $OUTPUT"
  exit 1
fi
"""

_DIFF_COMMAND = """
GOLDEN=$(%s %s)
if [ "$OUTPUT" != "$GOLDEN" ]; then
  echo "FAIL (output mismatch): %s"
  echo "Diff:"
  diff <(echo $GOLDEN) <(echo $OUTPUT)
  echo "Expected: $GOLDEN"
  echo "Actual: $OUTPUT"
  exit 1
fi
"""

_REGEX_DIFF_COMMAND = """
GOLDEN_REGEX=$(%s %s)
if [[ ! "$OUTPUT" =~ $GOLDEN_REGEX ]]; then
  echo "FAIL (regex mismatch): %s"
  echo "Output: $OUTPUT"
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
    # expected return code is 0. Otherwise, the golden file contains the
    # expected error output.
    dump_golden_cmd = (ctx.executable.jsonnet.short_path if ctx.attr.error == 0
                       else '/bin/cat')
    if ctx.attr.regex:
      diff_command = _REGEX_DIFF_COMMAND % (
          dump_golden_cmd,
          ctx.file.golden.short_path,
          ctx.label.name,
      )
    else:
      diff_command = _DIFF_COMMAND % (
          dump_golden_cmd,
          ctx.file.golden.short_path,
          ctx.label.name,
      )

  jsonnet_vars = ctx.attr.vars
  jsonnet_code_vars = ctx.attr.code_vars
  jsonnet_command = " ".join(
      ["OUTPUT=$(%s" % ctx.executable.jsonnet.short_path] +
      ["-J %s/%s" % (ctx.label.package, im) for im in ctx.attr.imports] +
      ["-J %s" % im for im in depinfo.imports] +
      ["-J ."] +
      ["--var %s=%s"
       % (var, jsonnet_vars[var]) for var in jsonnet_vars.keys()] +
      ["--code-var %s=%s"
       % (var, jsonnet_code_vars[var]) for var in jsonnet_code_vars.keys()] +
      [
          ctx.file.src.path,
          "2>&1)",
      ])

  command = [
      "#!/bin/bash",
      jsonnet_command,
      _EXIT_CODE_COMPARE_COMMAND % (ctx.attr.error, ctx.label.name),
  ]
  if diff_command:
    command += [diff_command]

  ctx.file_action(output = ctx.outputs.executable,
                  content = "\n".join(command),
                  executable = True);

  transitive_data = depset()
  for dep in ctx.attr.deps:
    transitive_data += dep.data_runfiles.files

  test_inputs = (
      [ctx.file.src, ctx.executable.jsonnet] +
      golden_files +
      list(transitive_data) +
      list(depinfo.transitive_sources))

  return struct(
      runfiles = ctx.runfiles(
          files = test_inputs,
          transitive_files = transitive_data,
          collect_data = True,
      ))

_jsonnet_common_attrs = {
    "deps": attr.label_list(
        providers = ["transitive_jsonnet_files"],
        allow_files = False,
    ),
    "imports": attr.string_list(),
    "jsonnet": attr.label(
        default = Label("@jsonnet//cmd:jsonnet"),
        cfg = "host",
        executable = True,
        single_file = True,
    ),
    "data": attr.label_list(
        allow_files = True,
        cfg = "data",
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
    "src": attr.label(
        allow_files = _JSONNET_FILETYPE,
        single_file = True,
    ),
    "vars": attr.string_dict(),
    "code_vars": attr.string_dict(),
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
  vars: Map of variables to pass to jsonnet via `--var key=value` flags.
  code_vars: Map of code variables to pass to jsonnet via `--code-var key-value`
    flags.

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
    "golden": attr.label(
        allow_files = True,
        single_file = True,
    ),
    "error": attr.int(),
    "regex": attr.bool(),
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
  vars: Map of variables to pass to jsonnet via `--var key=value` flags.
  code_vars: Map of code variables to pass to jsonnet via `--code-var key-value`
    flags.
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
  native.http_archive(
      name = "jsonnet",
      urls = [
          "http://mirror.bazel.build/github.com/google/jsonnet/archive/v0.9.5.tar.gz",
          "https://github.com/google/jsonnet/archive/v0.9.5.tar.gz",
      ],
      sha256 = "f504b6079882a18f0e8304f9e230f04eff70c2f0fb94a18fc26cbf989c7d838b",
      strip_prefix = "jsonnet-0.9.5",
  )
