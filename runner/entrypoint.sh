#!/bin/bash

set -e

echo "Starting GitHub Actions Runner..."

if [ -z "$GITHUB_ACCOUNT" ]; then
    echo "Error: GITHUB_ACCOUNT is not set"
    exit 1
fi

if [ -z "$RUNNER_TOKEN" ]; then
    echo "Error: RUNNER_TOKEN is not set"
    exit 1
fi

RUNNER_NAME="${RUNNER_NAME_PREFIX:-github-runner}-${HOSTNAME:-$(date +%s)}"
RUNNER_LABELS="${RUNNER_LABELS:-self-hosted}"
RUNNER_WORKDIR="${RUNNER_WORKDIR:-/_runner/_work}"

cd /runner

if [ -d "./runner" ]; then
    echo "Runner already exists, skipping download"
else
    echo "Downloading GitHub Actions Runner..."
    RUNNER_VERSION="2.322.0"
    wget -q "https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz" -O runner.tar.gz
    tar xzf runner.tar.gz
    rm runner.tar.gz
fi

./config.sh \
    --url "https://github.com/${GITHUB_ACCOUNT}" \
    --token "$RUNNER_TOKEN" \
    --labels "$RUNNER_LABELS" \
    --name "$RUNNER_NAME" \
    --work "$RUNNER_WORKDIR" \
    --unattended \
    --replace

echo "Starting runner..."
./run.sh
