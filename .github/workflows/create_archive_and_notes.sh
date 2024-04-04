#!/usr/bin/env bash
# Copyright 2024 The Bazel Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -o errexit -o nounset -o pipefail

# Set by GH actions, see
# https://docs.github.com/en/actions/learn-github-actions/environment-variables#default-environment-variables
TAG=${GITHUB_REF_NAME}
# A prefix is added to better match the GitHub generated archives.
PREFIX="rules_jsonnet-${TAG}"
ARCHIVE="rules_jsonnet-$TAG.tar.gz"
git archive --format=tar --prefix=${PREFIX}/ ${TAG} | gzip > $ARCHIVE
SHA=$(shasum -a 256 $ARCHIVE | awk '{print $1}')

cat > release_notes.txt << EOF
## Setup

To use the Jsonnet rules, add the following to your \`MODULE.bazel\` file:

\`\`\`starlark
bazel_dep(name = "rules_jsonnet", version = "${TAG}")
\`\`\`

If you are using an older version of Bazel that does not support Bzlmod,
add the following to your \`WORKSPACE\` file to add the external
repositories for Jsonnet:

\`\`\`starlark
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "io_bazel_rules_jsonnet",
    sha256 = "${SHA}",
    strip_prefix = "${PREFIX}",
    urls = ["https://github.com/bazelbuild/rules_jsonnet/releases/download/${TAG}/rules_jsonnet-${TAG}.tar.gz",
)

load("@io_bazel_rules_jsonnet//jsonnet:jsonnet.bzl", "jsonnet_repositories")

jsonnet_repositories()

load("@google_jsonnet_go//bazel:repositories.bzl", "jsonnet_go_repositories")

jsonnet_go_repositories()

load("@google_jsonnet_go//bazel:deps.bzl", "jsonnet_go_dependencies")

jsonnet_go_dependencies()
\`\`\`
EOF
