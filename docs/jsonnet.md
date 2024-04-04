<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Jsonnet Rules

These are build rules for working with [Jsonnet][jsonnet] files with Bazel.

[jsonnet]: https://jsonnet.org/

## Setup

To use the Jsonnet rules, add the following to your `MODULE.bazel` file:

```python
bazel_dep(name = "rules_jsonnet", version = "0.5.0")
```

If you are using an older version of Bazel that does not support Bzlmod,
add the following to your `WORKSPACE` file to add the external
repositories for Jsonnet:

```python
http_archive(
    name = "io_bazel_rules_jsonnet",
    sha256 = "c51ba0dba41d667fa5c64e56e252ba54be093e5ae764af6470dabca901f373eb",
    strip_prefix = "rules_jsonnet-0.5.0",
    urls = ["https://github.com/bazelbuild/rules_jsonnet/archive/0.5.0.tar.gz"],
)
load("@io_bazel_rules_jsonnet//jsonnet:jsonnet.bzl", "jsonnet_repositories")

jsonnet_repositories()

load("@google_jsonnet_go//bazel:repositories.bzl", "jsonnet_go_repositories")

jsonnet_go_repositories()

load("@google_jsonnet_go//bazel:deps.bzl", "jsonnet_go_dependencies")

jsonnet_go_dependencies()
```

<a id="jsonnet_library"></a>

## jsonnet_library

<pre>
jsonnet_library(<a href="#jsonnet_library-name">name</a>, <a href="#jsonnet_library-deps">deps</a>, <a href="#jsonnet_library-srcs">srcs</a>, <a href="#jsonnet_library-data">data</a>, <a href="#jsonnet_library-imports">imports</a>, <a href="#jsonnet_library-jsonnet">jsonnet</a>)
</pre>

Creates a logical set of Jsonnet files.

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

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="jsonnet_library-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="jsonnet_library-deps"></a>deps |  List of targets that are required by the `srcs` Jsonnet files.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="jsonnet_library-srcs"></a>srcs |  List of `.jsonnet` files that comprises this Jsonnet library   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="jsonnet_library-data"></a>data |  -   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="jsonnet_library-imports"></a>imports |  List of import `-J` flags to be passed to the `jsonnet` compiler.   | List of strings | optional |  `[]`  |
| <a id="jsonnet_library-jsonnet"></a>jsonnet |  A jsonnet binary   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `"@rules_jsonnet//jsonnet:jsonnet_tool"`  |


<a id="jsonnet_to_json"></a>

## jsonnet_to_json

<pre>
jsonnet_to_json(<a href="#jsonnet_to_json-name">name</a>, <a href="#jsonnet_to_json-deps">deps</a>, <a href="#jsonnet_to_json-src">src</a>, <a href="#jsonnet_to_json-data">data</a>, <a href="#jsonnet_to_json-outs">outs</a>, <a href="#jsonnet_to_json-code_vars">code_vars</a>, <a href="#jsonnet_to_json-ext_code">ext_code</a>, <a href="#jsonnet_to_json-ext_code_envs">ext_code_envs</a>, <a href="#jsonnet_to_json-ext_code_file_vars">ext_code_file_vars</a>,
                <a href="#jsonnet_to_json-ext_code_files">ext_code_files</a>, <a href="#jsonnet_to_json-ext_str_envs">ext_str_envs</a>, <a href="#jsonnet_to_json-ext_str_file_vars">ext_str_file_vars</a>, <a href="#jsonnet_to_json-ext_str_files">ext_str_files</a>, <a href="#jsonnet_to_json-ext_strs">ext_strs</a>, <a href="#jsonnet_to_json-extra_args">extra_args</a>,
                <a href="#jsonnet_to_json-imports">imports</a>, <a href="#jsonnet_to_json-jsonnet">jsonnet</a>, <a href="#jsonnet_to_json-multiple_outputs">multiple_outputs</a>, <a href="#jsonnet_to_json-stamp_keys">stamp_keys</a>, <a href="#jsonnet_to_json-tla_code">tla_code</a>, <a href="#jsonnet_to_json-tla_code_envs">tla_code_envs</a>,
                <a href="#jsonnet_to_json-tla_code_files">tla_code_files</a>, <a href="#jsonnet_to_json-tla_str_envs">tla_str_envs</a>, <a href="#jsonnet_to_json-tla_str_files">tla_str_files</a>, <a href="#jsonnet_to_json-tla_strs">tla_strs</a>, <a href="#jsonnet_to_json-vars">vars</a>, <a href="#jsonnet_to_json-yaml_stream">yaml_stream</a>)
</pre>

Compiles Jsonnet code to JSON.

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

  [multiple-output-files]: https://jsonnet.org/learning/getting_started.html#multi

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="jsonnet_to_json-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="jsonnet_to_json-deps"></a>deps |  List of targets that are required by the `srcs` Jsonnet files.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="jsonnet_to_json-src"></a>src |  The `.jsonnet` file to convert to JSON.   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |
| <a id="jsonnet_to_json-data"></a>data |  -   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="jsonnet_to_json-outs"></a>outs |  Names of the output `.json` files to be generated by this rule.<br><br>If you are generating only a single JSON file and are not using jsonnet multiple output files, then this attribute should only contain the file name of the JSON file you are generating.<br><br>If you are generating multiple JSON files using jsonnet multiple file output (`jsonnet -m`), then list the file names of all the JSON files to be generated. The file names specified here must match the file names specified in your `src` Jsonnet file.<br><br>For the case where multiple file output is used but only for generating one output file, set the `multiple_outputs` attribute to 1 to explicitly enable the `-m` flag for multiple file output.   | List of labels | required |  |
| <a id="jsonnet_to_json-code_vars"></a>code_vars |  Deprecated (use 'ext_code').   | <a href="https://bazel.build/rules/lib/dict">Dictionary: String -> String</a> | optional |  `{}`  |
| <a id="jsonnet_to_json-ext_code"></a>ext_code |  -   | <a href="https://bazel.build/rules/lib/dict">Dictionary: String -> String</a> | optional |  `{}`  |
| <a id="jsonnet_to_json-ext_code_envs"></a>ext_code_envs |  -   | List of strings | optional |  `[]`  |
| <a id="jsonnet_to_json-ext_code_file_vars"></a>ext_code_file_vars |  -   | List of strings | optional |  `[]`  |
| <a id="jsonnet_to_json-ext_code_files"></a>ext_code_files |  -   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="jsonnet_to_json-ext_str_envs"></a>ext_str_envs |  -   | List of strings | optional |  `[]`  |
| <a id="jsonnet_to_json-ext_str_file_vars"></a>ext_str_file_vars |  -   | List of strings | optional |  `[]`  |
| <a id="jsonnet_to_json-ext_str_files"></a>ext_str_files |  -   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="jsonnet_to_json-ext_strs"></a>ext_strs |  -   | <a href="https://bazel.build/rules/lib/dict">Dictionary: String -> String</a> | optional |  `{}`  |
| <a id="jsonnet_to_json-extra_args"></a>extra_args |  -   | List of strings | optional |  `[]`  |
| <a id="jsonnet_to_json-imports"></a>imports |  List of import `-J` flags to be passed to the `jsonnet` compiler.   | List of strings | optional |  `[]`  |
| <a id="jsonnet_to_json-jsonnet"></a>jsonnet |  A jsonnet binary   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `"@rules_jsonnet//jsonnet:jsonnet_tool"`  |
| <a id="jsonnet_to_json-multiple_outputs"></a>multiple_outputs |  Set to `True` to explicitly enable multiple file output via the `jsonnet -m` flag.<br><br>This is used for the case where multiple file output is used but only for generating a single output file. For example:<br><br><pre><code>local foo = import "foo.jsonnet";&#10;&#10;{&#10;    "foo.json": foo,&#10;}</code></pre>   | Boolean | optional |  `False`  |
| <a id="jsonnet_to_json-stamp_keys"></a>stamp_keys |  -   | List of strings | optional |  `[]`  |
| <a id="jsonnet_to_json-tla_code"></a>tla_code |  -   | <a href="https://bazel.build/rules/lib/dict">Dictionary: String -> String</a> | optional |  `{}`  |
| <a id="jsonnet_to_json-tla_code_envs"></a>tla_code_envs |  -   | List of strings | optional |  `[]`  |
| <a id="jsonnet_to_json-tla_code_files"></a>tla_code_files |  -   | <a href="https://bazel.build/rules/lib/dict">Dictionary: Label -> String</a> | optional |  `{}`  |
| <a id="jsonnet_to_json-tla_str_envs"></a>tla_str_envs |  -   | List of strings | optional |  `[]`  |
| <a id="jsonnet_to_json-tla_str_files"></a>tla_str_files |  -   | <a href="https://bazel.build/rules/lib/dict">Dictionary: Label -> String</a> | optional |  `{}`  |
| <a id="jsonnet_to_json-tla_strs"></a>tla_strs |  -   | <a href="https://bazel.build/rules/lib/dict">Dictionary: String -> String</a> | optional |  `{}`  |
| <a id="jsonnet_to_json-vars"></a>vars |  Deprecated (use 'ext_strs').   | <a href="https://bazel.build/rules/lib/dict">Dictionary: String -> String</a> | optional |  `{}`  |
| <a id="jsonnet_to_json-yaml_stream"></a>yaml_stream |  -   | Boolean | optional |  `False`  |


<a id="jsonnet_to_json_test"></a>

## jsonnet_to_json_test

<pre>
jsonnet_to_json_test(<a href="#jsonnet_to_json_test-name">name</a>, <a href="#jsonnet_to_json_test-deps">deps</a>, <a href="#jsonnet_to_json_test-src">src</a>, <a href="#jsonnet_to_json_test-data">data</a>, <a href="#jsonnet_to_json_test-canonicalize_golden">canonicalize_golden</a>, <a href="#jsonnet_to_json_test-code_vars">code_vars</a>, <a href="#jsonnet_to_json_test-error">error</a>, <a href="#jsonnet_to_json_test-ext_code">ext_code</a>,
                     <a href="#jsonnet_to_json_test-ext_code_envs">ext_code_envs</a>, <a href="#jsonnet_to_json_test-ext_code_file_vars">ext_code_file_vars</a>, <a href="#jsonnet_to_json_test-ext_code_files">ext_code_files</a>, <a href="#jsonnet_to_json_test-ext_str_envs">ext_str_envs</a>,
                     <a href="#jsonnet_to_json_test-ext_str_file_vars">ext_str_file_vars</a>, <a href="#jsonnet_to_json_test-ext_str_files">ext_str_files</a>, <a href="#jsonnet_to_json_test-ext_strs">ext_strs</a>, <a href="#jsonnet_to_json_test-extra_args">extra_args</a>, <a href="#jsonnet_to_json_test-golden">golden</a>, <a href="#jsonnet_to_json_test-imports">imports</a>, <a href="#jsonnet_to_json_test-jsonnet">jsonnet</a>,
                     <a href="#jsonnet_to_json_test-output_file_contents">output_file_contents</a>, <a href="#jsonnet_to_json_test-regex">regex</a>, <a href="#jsonnet_to_json_test-stamp_keys">stamp_keys</a>, <a href="#jsonnet_to_json_test-tla_code">tla_code</a>, <a href="#jsonnet_to_json_test-tla_code_envs">tla_code_envs</a>, <a href="#jsonnet_to_json_test-tla_code_files">tla_code_files</a>,
                     <a href="#jsonnet_to_json_test-tla_str_envs">tla_str_envs</a>, <a href="#jsonnet_to_json_test-tla_str_files">tla_str_files</a>, <a href="#jsonnet_to_json_test-tla_strs">tla_strs</a>, <a href="#jsonnet_to_json_test-vars">vars</a>, <a href="#jsonnet_to_json_test-yaml_stream">yaml_stream</a>)
</pre>

Compiles Jsonnet code to JSON and checks the output.

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

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="jsonnet_to_json_test-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="jsonnet_to_json_test-deps"></a>deps |  List of targets that are required by the `srcs` Jsonnet files.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="jsonnet_to_json_test-src"></a>src |  The `.jsonnet` file to convert to JSON.   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |
| <a id="jsonnet_to_json_test-data"></a>data |  -   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="jsonnet_to_json_test-canonicalize_golden"></a>canonicalize_golden |  -   | Boolean | optional |  `True`  |
| <a id="jsonnet_to_json_test-code_vars"></a>code_vars |  Deprecated (use 'ext_code').   | <a href="https://bazel.build/rules/lib/dict">Dictionary: String -> String</a> | optional |  `{}`  |
| <a id="jsonnet_to_json_test-error"></a>error |  The expected error code from running `jsonnet` on `src`.   | Integer | optional |  `0`  |
| <a id="jsonnet_to_json_test-ext_code"></a>ext_code |  -   | <a href="https://bazel.build/rules/lib/dict">Dictionary: String -> String</a> | optional |  `{}`  |
| <a id="jsonnet_to_json_test-ext_code_envs"></a>ext_code_envs |  -   | List of strings | optional |  `[]`  |
| <a id="jsonnet_to_json_test-ext_code_file_vars"></a>ext_code_file_vars |  -   | List of strings | optional |  `[]`  |
| <a id="jsonnet_to_json_test-ext_code_files"></a>ext_code_files |  -   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="jsonnet_to_json_test-ext_str_envs"></a>ext_str_envs |  -   | List of strings | optional |  `[]`  |
| <a id="jsonnet_to_json_test-ext_str_file_vars"></a>ext_str_file_vars |  -   | List of strings | optional |  `[]`  |
| <a id="jsonnet_to_json_test-ext_str_files"></a>ext_str_files |  -   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="jsonnet_to_json_test-ext_strs"></a>ext_strs |  -   | <a href="https://bazel.build/rules/lib/dict">Dictionary: String -> String</a> | optional |  `{}`  |
| <a id="jsonnet_to_json_test-extra_args"></a>extra_args |  -   | List of strings | optional |  `[]`  |
| <a id="jsonnet_to_json_test-golden"></a>golden |  The expected (combined stdout and stderr) output to compare to the output of running `jsonnet` on `src`.   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |
| <a id="jsonnet_to_json_test-imports"></a>imports |  List of import `-J` flags to be passed to the `jsonnet` compiler.   | List of strings | optional |  `[]`  |
| <a id="jsonnet_to_json_test-jsonnet"></a>jsonnet |  A jsonnet binary   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `"@rules_jsonnet//jsonnet:jsonnet_tool"`  |
| <a id="jsonnet_to_json_test-output_file_contents"></a>output_file_contents |  -   | Boolean | optional |  `True`  |
| <a id="jsonnet_to_json_test-regex"></a>regex |  Set to 1 if `golden` contains a regex used to match the output of running `jsonnet` on `src`.   | Boolean | optional |  `False`  |
| <a id="jsonnet_to_json_test-stamp_keys"></a>stamp_keys |  -   | List of strings | optional |  `[]`  |
| <a id="jsonnet_to_json_test-tla_code"></a>tla_code |  -   | <a href="https://bazel.build/rules/lib/dict">Dictionary: String -> String</a> | optional |  `{}`  |
| <a id="jsonnet_to_json_test-tla_code_envs"></a>tla_code_envs |  -   | List of strings | optional |  `[]`  |
| <a id="jsonnet_to_json_test-tla_code_files"></a>tla_code_files |  -   | <a href="https://bazel.build/rules/lib/dict">Dictionary: Label -> String</a> | optional |  `{}`  |
| <a id="jsonnet_to_json_test-tla_str_envs"></a>tla_str_envs |  -   | List of strings | optional |  `[]`  |
| <a id="jsonnet_to_json_test-tla_str_files"></a>tla_str_files |  -   | <a href="https://bazel.build/rules/lib/dict">Dictionary: Label -> String</a> | optional |  `{}`  |
| <a id="jsonnet_to_json_test-tla_strs"></a>tla_strs |  -   | <a href="https://bazel.build/rules/lib/dict">Dictionary: String -> String</a> | optional |  `{}`  |
| <a id="jsonnet_to_json_test-vars"></a>vars |  Deprecated (use 'ext_strs').   | <a href="https://bazel.build/rules/lib/dict">Dictionary: String -> String</a> | optional |  `{}`  |
| <a id="jsonnet_to_json_test-yaml_stream"></a>yaml_stream |  -   | Boolean | optional |  `False`  |


<a id="JsonnetLibraryInfo"></a>

## JsonnetLibraryInfo

<pre>
JsonnetLibraryInfo()
</pre>



**FIELDS**



<a id="jsonnet_repositories"></a>

## jsonnet_repositories

<pre>
jsonnet_repositories()
</pre>

Adds the external dependencies needed for the Jsonnet rules.



