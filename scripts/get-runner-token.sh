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

echo "Getting org-level runner registration token for: $GITHUB_ACCOUNT"

TOKEN=$(gh api "orgs/${GITHUB_ACCOUNT}/actions/runners/registration-token" \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    --jq '.token')

if [ -z "$TOKEN" ]; then
    echo "Error: Failed to get runner token"
    exit 1
fi

echo "Successfully obtained runner registration token"
echo "RUNNER_TOKEN=$TOKEN"
