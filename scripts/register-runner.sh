#!/bin/bash

set -e

if [ -z "$GITHUB_ACCOUNT" ]; then
    echo "Error: GITHUB_ACCOUNT is not set"
    exit 1
fi

if [ -z "$GITHUB_TOKEN" ]; then
    echo "Error: GITHUB_TOKEN is not set"
    exit 1
fi

echo "Getting runner token..."
source ./scripts/get-runner-token.sh

export RUNNER_TOKEN="$TOKEN"

RUNNER_NAME="${RUNNER_NAME_PREFIX:-github-runner}-${HOSTNAME:-$(date +%s)}"
RUNNER_LABELS="${RUNNER_LABELS:-self-hosted}"
RUNNER_WORKDIR="${RUNNER_WORKDIR:-/_runner/_work}"

cd /runner

./config.sh \
    --url "https://github.com/${GITHUB_ACCOUNT}" \
    --token "$RUNNER_TOKEN" \
    --labels "$RUNNER_LABELS" \
    --name "$RUNNER_NAME" \
    --work "$RUNNER_WORKDIR" \
    --unattended

echo "Runner registered successfully"
