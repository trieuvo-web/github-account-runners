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

echo "Getting runner removal token for account: $GITHUB_ACCOUNT"

REMOVAL_TOKEN=$(gh api "users/${GITHUB_ACCOUNT}/actions/runners/registration-token" \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    --jq '.token')

cd /runner

./config.sh remove --token "$REMOVAL_TOKEN"

echo "Runner removed successfully"
