#!/usr/bin/env bash
# flake-check-build-tag.sh

set -euo pipefail

NUM_COMMITS=5
REPO_DIR="$(pwd)"
SUCCESSFUL_COMMITS=()
FAILED_COMMITS=()
COMMITS=($(git log --format="%h" -n "$NUM_COMMITS"))
HOST_ID="pc"  # Customize your host label

for COMMIT in "${COMMITS[@]}"; do
  echo -e "\n🔍 Testing commit $COMMIT"

  WORKTREE="/tmp/nix-flake-test-$COMMIT"
  git worktree add --detach "$WORKTREE" "$COMMIT"

  pushd "$WORKTREE" > /dev/null

  echo "⚡ Running nix-fast-build..."
  if nix-fast-build; then
    echo "✅ nix-fast-build succeeded"

    echo "🔍 Running optional flake checks..."
    if nix flake check; then
      echo "✅ nix flake check passed"
    else
      echo "⚠️ nix flake check failed (ignoring for now)"
    fi

    echo "🔍 Checking devshell..."
    if nix develop -c true; then
      echo "✅ devshell environment works"
    else
      echo "⚠️ devshell failed (ignoring for now)"
    fi

    SUCCESSFUL_COMMITS+=("$COMMIT")
  else
    echo "❌ nix-fast-build failed at $COMMIT"
    FAILED_COMMITS+=("$COMMIT")
  fi

  popd > /dev/null
  git worktree remove --force "$WORKTREE"

  if (( ${#SUCCESSFUL_COMMITS[@]} > ${#FAILED_COMMITS[@]} )); then
    echo -e "\n🛑 More successes than failures — stopping early."
    break
  fi
done

echo -e "\n=================="
echo -e "✅ Verified Commits:"
for COMMIT in "${SUCCESSFUL_COMMITS[@]}"; do
  SHORT_MSG=$(git log --format="%s" -n 1 "$COMMIT")
  echo "$COMMIT: $SHORT_MSG"
done

echo -e "\n📌 Suggested Tags:"
i=1
for COMMIT in "${SUCCESSFUL_COMMITS[@]}"; do
  echo "v0.0.$i:$HOST_ID:nixos-25.05:veriBuild # $COMMIT"
  ((i++))
done
