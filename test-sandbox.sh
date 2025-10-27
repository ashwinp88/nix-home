#!/usr/bin/env bash
# Sandbox test script for install.sh
# Creates isolated environment, tests installation, then cleans up

set -euo pipefail

TEST_HOME=$(mktemp -d)
TEST_USER="testuser"

echo "==> Creating sandbox environment"
echo "    TEST_HOME: $TEST_HOME"
echo "    TEST_USER: $TEST_USER"
echo ""

cleanup() {
  echo ""
  echo "==> Cleaning up sandbox"
  rm -rf "$TEST_HOME"
  echo "    Deleted: $TEST_HOME"
}
trap cleanup EXIT

# Test function
test_config() {
  local config_type="$1"
  local flake_subdir="$2"

  echo "==> Testing $config_type configuration"
  echo "    Flake: $([ -z "$flake_subdir" ] && echo "root" || echo "$flake_subdir")"

  (
    export HOME="$TEST_HOME"
    export USER="$TEST_USER"
    export FLAKE_SUBDIR="$flake_subdir"

    cd "$(dirname "$0")"
    ./scripts/bootstrap.sh --prepare-only

    if [ $? -eq 0 ]; then
      echo "    ✓ $config_type build successful"
    else
      echo "    ✗ $config_type build failed"
      exit 1
    fi
  )
}

echo "========================================="
echo "Test 1: Vanilla Configuration"
echo "========================================="
test_config "Vanilla" ""

echo ""
echo "========================================="
echo "Test 2: LazyVim Configuration"
echo "========================================="
test_config "LazyVim" "lazyvim"

echo ""
echo "========================================="
echo "✓ All tests passed!"
echo "========================================="
