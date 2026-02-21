#!/usr/bin/env bash

set -euo pipefail

REPO="rhung123/Monifactory"
BRANCH="main"
WORKFLOW="build_pr.yml"

CURRENT_DIR="$(pwd)"
LATEST_DIR="$CURRENT_DIR/moniserver-prod"

echo "==> Syncing fork with upstream"
gh api \
  --method POST \
  repos/$REPO/merge-upstream \
  -f branch="$BRANCH"

echo "==> Retrieving latest commit SHA"
SHA=$(gh api repos/$REPO/commits/$BRANCH --jq '.sha' | cut -c1-7)
echo "Latest SHA: $SHA"

echo "==> Triggering workflow"
gh workflow run "$WORKFLOW" \
  --repo "$REPO" \
  --ref "$BRANCH"

sleep 5

RUN_ID=$(gh run list \
  --repo "$REPO" \
  --workflow "$WORKFLOW" \
  --branch "$BRANCH" \
  --limit 1 \
  --json databaseId \
  -q '.[0].databaseId')

echo "==> Watching workflow run $RUN_ID"
gh run watch "$RUN_ID" --repo "$REPO"

echo "==> Downloading artifacts"
gh run download "$RUN_ID" \
  --repo "$REPO" \
  --dir artifact_tmp

SERVER_ZIP="artifact_tmp/server-build/server.zip"

if [[ ! -f "$SERVER_ZIP" ]]; then
  echo "ERROR: Expected artifact not found at $SERVER_ZIP"
  exit 1
fi

TARGET_DIR="$CURRENT_DIR/moniserver-$SHA"
mkdir -p "$TARGET_DIR"

echo "==> Moving server.zip into $TARGET_DIR"
mv "$SERVER_ZIP" "$TARGET_DIR/"

echo "==> Unzipping server.zip"
cd "$TARGET_DIR"
unzip -o server.zip
cd "$CURRENT_DIR"

rm -rf artifact_tmp

#############################################
# Update moniserver-prod
#############################################

if [[ ! -d "$LATEST_DIR" ]]; then
  echo "ERROR: moniserver-prod directory not found."
  exit 1
fi

echo "==> Updating moniserver-prod configs"

DIRS_TO_REPLACE=(
  "config-overrides"
  "config"
  "defaultconfigs"
  "kubejs"
  "mods"
)

for dir in "${DIRS_TO_REPLACE[@]}"; do
  echo "   -> Replacing $dir"

  rm -rf "$LATEST_DIR/$dir"

  if [[ -d "$TARGET_DIR/$dir" ]]; then
    cp -R "$TARGET_DIR/$dir" "$LATEST_DIR/"
  else
    echo "WARNING: $dir not found in new build"
  fi
done

echo "==> Update complete"
echo "New build directory: moniserver-$SHA"
echo "moniserver-prod updated successfully."
