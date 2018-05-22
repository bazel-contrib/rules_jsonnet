#!/usr/bin/env bash

echo "STABLE_GIT_COMMIT $(git rev-parse HEAD)"
echo "STABLE_GIT_COMMIT_SHORT $(git rev-parse --short HEAD)"
echo "STABLE_BRANCH_NAME $(git rev-parse --abbrev-ref HEAD)"
echo "STABLE_K8S_CLUSTER $(kubectl config current-context)"
