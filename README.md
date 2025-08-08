[![Build status](https://badge.buildkite.com/c3449aba989713394a3237070971eb59b92ad19d6f69555a25.svg)](https://buildkite.com/bazel/rules-jsonnet-postsubmit)

# Jsonnet Rules

<div class="toc">
  <h2>Rules</h2>
  <ul>
    <li><a href="docs/jsonnet.md#jsonnet_library">jsonnet_library</a></li>
    <li><a href="docs/jsonnet.md#jsonnet_to_json">jsonnet_to_json</a></li>
    <li><a href="docs/jsonnet.md#jsonnet_to_json_test">jsonnet_to_json_test</a></li>
  </ul>
</div>

## Overview

These are build rules for working with [Jsonnet][jsonnet] files with Bazel.

[jsonnet]: https://jsonnet.org

## Setup

To use the Jsonnet rules as part of your Bazel project, please follow the
instructions on [the releases page](https://github.com/bazelbuild/rules_jsonnet/releases).

## Jsonnet Compiler Selection

By default for Bzlmod, Bazel will use the [Go
compiler](https://github.com/google/go-jsonnet). Note that the
primary development focus of the Jsonnet project is now with the Go compiler.
This repository's support for using the C++ compiler is deprecated, and may be
removed in a future release.

To use [the
C++](https://github.com/google/jsonnet) or
[Rust](https://github.com/CertainLach/jrsonnet) compiler of Jsonnet instead,
register a different compiler:

| Jsonnet compiler | MODULE.bazel directive            |
| ---------------- | --------------------------------- |
| Go               | `jsonnet.compiler(name = "go")`   |
| cpp              | `jsonnet.compiler(name = "cpp")`  |
| Rust             | `jsonnet.compiler(name = "rust")` |

### CLI

Use the `--extra_toolchains` flag to pass the preferred toolchain to the bazel
invocation:

```bash
bazel build //... --extra_toolchains=@rules_jsonnet//jsonnet:cpp_jsonnet_toolchain

bazel test //... --extra_toolchains=@rules_jsonnet//jsonnet:rust_jsonnet_toolchain

bazel run //... --extra_toolchains=@rules_jsonnet//jsonnet:go_jsonnet_toolchain
```

## Rule usage

Please refer to [the StarDoc generated documentation](docs/jsonnet.md)
for instructions on how to use these rules.
