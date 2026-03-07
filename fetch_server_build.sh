#!/usr/bin/env bash

set -euo pipefail

REPO="rhung123/Monifactory"
BRANCH="main"
WORKFLOW="build_pr.yml"

OUTPUT_DIR="${1:-.}"
SERVER_ZIP="$OUTPUT_DIR/server.zip"

#############################################
# Reuse existing build if present
#############################################

if [[ -f "$SERVER_ZIP" ]]; then
  echo "==> server.zip already exists at $SERVER_ZIP"
  echo "==> Skipping GitHub Actions build"
  exit 0
fi

mkdir -p "$OUTPUT_DIR"

#############################################
# Sync fork with upstream
#############################################

echo "==> Syncing fork with upstream"
gh api \
  --method POST \
  repos/$REPO/merge-upstream \
  -f branch="$BRANCH"

#############################################
# Get latest commit SHA
#############################################

echo "==> Retrieving latest commit SHA"
SHA=$(gh api repos/$REPO/commits/$BRANCH --jq '.sha' | cut -c1-7)
echo "Latest SHA: $SHA"

#############################################
# Trigger workflow
#############################################

echo "==> Triggering workflow"
gh workflow run "$WORKFLOW" \
  --repo "$REPO" \
  --ref "$BRANCH"

sleep 5

#############################################
# Get workflow run id
#############################################

RUN_ID=$(gh run list \
  --repo "$REPO" \
  --workflow "$WORKFLOW" \
  --branch "$BRANCH" \
  --limit 1 \
  --json databaseId \
  -q '.[0].databaseId')

echo "==> Watching workflow run $RUN_ID"
gh run watch "$RUN_ID" --repo "$REPO"

#############################################
# Download artifact
#############################################

echo "==> Downloading artifacts"
gh run download "$RUN_ID" \
  --repo "$REPO" \
  --dir artifact_tmp

SERVER_BUILD="artifact_tmp/server-build/server.zip"

if [[ ! -f "$SERVER_BUILD" ]]; then
  echo "ERROR: Expected artifact not found at $SERVER_BUILD"
  exit 1
fi

mv "$SERVER_BUILD" "$SERVER_ZIP"

rm -rf artifact_tmp

echo "==> server.zip ready at $SERVER_ZIP"