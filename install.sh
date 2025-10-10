#!/usr/bin/env bash
set -euo pipefail

REPO_OWNER="ashwinp88"
REPO_NAME="nix-home"
REF="main"
BOOTSTRAP_URL=""
BOOTSTRAP_ARGS=()
TMP_DIR=""

print_step() {
  printf '\n==> %s\n' "$1"
}

usage() {
  cat <<'USAGE'
Usage: install.sh [options] [-- [bootstrap args...]]

Options:
  --ref REF            Git ref (branch/tag/commit) to fetch (default: main)
  --bootstrap-url URL  Override the bootstrap script URL
  -h, --help           Show this help message

All additional arguments after `--` (or the first unrecognised flag) are
forwarded to `scripts/bootstrap.sh`.

Examples:
  curl -L https://raw.githubusercontent.com/ashwinp88/nix-home/main/install.sh | bash
  curl -L .../install.sh | bash -s -- --prepare-only
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --ref)
      [[ $# -ge 2 ]] || { echo "--ref expects an argument" >&2; exit 1; }
      REF="$2"
      shift 2
      ;;
    --bootstrap-url)
      [[ $# -ge 2 ]] || { echo "--bootstrap-url expects an argument" >&2; exit 1; }
      BOOTSTRAP_URL="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      BOOTSTRAP_ARGS+=("$@")
      break
      ;;
    *)
      BOOTSTRAP_ARGS+=("$@")
      break
      ;;
  esac
 done

if [[ -z "$BOOTSTRAP_URL" ]]; then
  BOOTSTRAP_URL="https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${REF}/scripts/bootstrap.sh"
fi

cleanup() {
  if [[ -n "$TMP_DIR" && -d "$TMP_DIR" ]]; then
    rm -rf "$TMP_DIR"
  fi
}
trap cleanup EXIT

require_cmd() {
  local cmd="$1"
  local msg="$2"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "$msg" >&2
    exit 1
  fi
}

require_cmd curl "curl is required to download installers"
require_cmd bash "bash is required to run bootstrap"

activate_nix() {
  local profile
  for profile in \
    /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh \
    "$HOME/.nix-profile/etc/profile.d/nix.sh"; do
    if [[ -f "$profile" ]]; then
      # shellcheck disable=SC1090
      . "$profile"
    fi
  done
}

install_nix() {
  if command -v nix >/dev/null 2>&1; then
    print_step "Nix already installed"
    activate_nix
    return
  fi

  print_step "Installing Nix (multi-user)"
  require_cmd sh "sh is required to run the Nix installer"

  set +e
  curl -L https://nixos.org/nix/install | sh -s -- --daemon
  local status=$?
  set -e
  if [[ $status -ne 0 ]]; then
    echo "Nix installation failed (exit code $status)" >&2
    exit $status
  fi

  print_step "Activating Nix in current shell"
  activate_nix

  if ! command -v nix >/dev/null 2>&1; then
    echo "Nix command not found after installation. Try restarting your shell and re-run install.sh" >&2
    exit 1
  fi
}

install_nix

TMP_DIR=$(mktemp -d)

print_step "Downloading bootstrap helper"
curl -fsSL "$BOOTSTRAP_URL" -o "$TMP_DIR/bootstrap.sh"
chmod +x "$TMP_DIR/bootstrap.sh"

print_step "Running bootstrap (flake auto-detected)"
bash "$TMP_DIR/bootstrap.sh" "${BOOTSTRAP_ARGS[@]}"
