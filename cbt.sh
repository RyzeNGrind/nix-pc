#!/usr/bin/env bash

set -euo pipefail

COMMITS=("f9abad0" "5706ff5")
REPO_DIR="$(pwd)"

for COMMIT in "${COMMITS[@]}"; do
  echo "🔍 Testing commit $COMMIT"

  git -C "$REPO_DIR" worktree add --detach "/tmp/nix-flake-test-$COMMIT" "$COMMIT"
  
  pushd "/tmp/nix-flake-test-$COMMIT" > /dev/null

  echo "🧪 Running nix develop in clean state at $COMMIT..."
  if nix develop -c bash -c 'echo ✅ nix develop works in commit: '"$COMMIT"; then
    echo "🎉 SUCCESS: Working flake at $COMMIT"
  else
    echo "❌ FAILURE: Flake did not build at $COMMIT"
  fi

  popd > /dev/null
  git -C "$REPO_DIR" worktree remove --force "/tmp/nix-flake-test-$COMMIT"
done
