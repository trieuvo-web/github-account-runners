#!/bin/bash

set -e

echo "Starting GitHub Actions Runner..."

if [ -z "$GITHUB_ACCOUNT" ]; then
    echo "Error: GITHUB_ACCOUNT is not set"
    exit 1
fi

if [ -z "$GITHUB_TOKEN" ]; then
    echo "Error: GITHUB_TOKEN is not set"
    exit 1
fi

echo "Getting runner registration token..."
if [ -n "$GITHUB_REPO" ]; then
    RUNNER_TOKEN=$(curl -s -X POST \
        -H "Accept: application/vnd.github+json" \
        -H "Authorization: Bearer ${GITHUB_TOKEN}" \
        -H "X-GitHub-Api-Version: 2022-11-28" \
        "https://api.github.com/repos/${GITHUB_REPO}/actions/runners/registration-token" | jq -r '.token')
    RUNNER_URL="https://github.com/${GITHUB_REPO}"
else
    RUNNER_TOKEN=$(curl -s -X POST \
        -H "Accept: application/vnd.github+json" \
        -H "Authorization: Bearer ${GITHUB_TOKEN}" \
        -H "X-GitHub-Api-Version: 2022-11-28" \
        "https://api.github.com/repos/${GITHUB_REPO}/actions/runners/registration-token" | jq -r '.token')
    RUNNER_URL="https://github.com/${GITHUB_REPO}"
fi

if [ -z "$RUNNER_TOKEN" ] || [ "$RUNNER_TOKEN" = "null" ]; then
    echo "Error: Failed to get runner token"
    exit 1
fi

echo "Runner token obtained successfully"

RUNNER_NAME="${RUNNER_NAME_PREFIX:-github-runner}-${HOSTNAME:-$(date +%s)}"
RUNNER_LABELS="${RUNNER_LABELS:-self-hosted}"
RUNNER_WORKDIR="${RUNNER_WORKDIR:-/_runner/_work}"

cd /runner

if [ -d "./runner" ]; then
    echo "Runner already exists, skipping download"
else
    echo "Downloading GitHub Actions Runner..."
    RUNNER_VERSION="2.322.0"
    ARCH=$(uname -m)
    if [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
        RUNNER_ARCH="arm64"
    else
        RUNNER_ARCH="x64"
    fi
    wget -q "https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-${RUNNER_ARCH}-${RUNNER_VERSION}.tar.gz" -O runner.tar.gz
    tar xzf runner.tar.gz
    rm runner.tar.gz
fi

export RUNNER_ALLOW_RUNASROOT=1

echo "Configuring runner..."
./config.sh \
    --url "$RUNNER_URL" \
    --token "$RUNNER_TOKEN" \
    --labels "$RUNNER_LABELS" \
    --name "$RUNNER_NAME" \
    --work "$RUNNER_WORKDIR" \
    --unattended \
    --replace

echo "Starting runner..."
exec ./run.sh
