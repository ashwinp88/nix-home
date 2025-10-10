#!/usr/bin/env bash
set -euo pipefail

print_step() {
  printf '\n==> %s\n' "$1"
}

usage() {
  cat <<'USAGE'
Usage: ./scripts/bootstrap.sh [options] [-- [home-manager args...]]

Options:
  --darwin         Force the macOS configuration.
  --linux          Force the Linux configuration.
  --base           Use the base modules only (skip OS-specific extras).
  --prepare-only   Prepare configuration and run `home-manager build`.
  --flake REF      Override the flake reference (default: local repo or github:ashwinp88/nix-home).
  --arch ARCH      Override Linux architecture detection (x86_64, aarch64).
  -h, --help       Show this help message.

Any arguments provided after `--` (or the first unrecognised flag)
are passed straight through to `home-manager`.
USAGE
}

TARGET_SYSTEM=""
TARGET_ARCH=""
BASE_ONLY="false"
PREPARE_ONLY="false"
FLAKE_BASE=""
HM_ARGS=()

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if REPO_DIR=$(cd "${SCRIPT_DIR}/.." 2>/dev/null && pwd); then
  :
else
  REPO_DIR="$SCRIPT_DIR"
fi
DEFAULT_FLAKE_BASE="$REPO_DIR"
if [[ ! -f "${REPO_DIR}/flake.nix" ]]; then
  DEFAULT_FLAKE_BASE="github:ashwinp88/nix-home"
fi

if [[ -z "${USER:-}" ]]; then
  USER="$(id -un 2>/dev/null || echo "unknown")"
  export USER
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    --linux)
      TARGET_SYSTEM="linux"
      shift
      ;;
    --darwin)
      TARGET_SYSTEM="darwin"
      shift
      ;;
    --base)
      BASE_ONLY="true"
      shift
      ;;
    --prepare-only)
      PREPARE_ONLY="true"
      shift
      ;;
    --flake)
      [[ $# -ge 2 ]] || { echo "--flake expects an argument" >&2; exit 1; }
      FLAKE_BASE="$2"
      shift 2
      ;;
    --arch)
      [[ $# -ge 2 ]] || { echo "--arch expects an argument" >&2; exit 1; }
      TARGET_ARCH="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      HM_ARGS+=("$@")
      break
      ;;
    *)
      HM_ARGS+=("$@")
      break
      ;;
  esac
done

default_system() {
  case "$(uname -s)" in
    Darwin) echo "darwin" ;;
    Linux) echo "linux" ;;
    *)
      echo "Unsupported OS: $(uname -s)" >&2
      exit 1
      ;;
  esac
}

attr_for_system() {
  local system="$1"
  local base_only="$2"
  local arch="$3"
  if [[ "$base_only" == "true" ]]; then
    case "$system" in
      darwin) echo "base-core-darwin" ;;
      linux)
        case "$arch" in
          x86_64|amd64|"") echo "base-core-linux-x86_64" ;;
          aarch64|arm64) echo "base-core-linux-aarch64" ;;
          *) echo "Unsupported Linux architecture: $arch" >&2; exit 1 ;;
        esac
        ;;
      *) echo "Unsupported system: $system" >&2; exit 1 ;;
    esac
  else
    case "$system" in
      darwin) echo "base-darwin" ;;
      linux)
        case "$arch" in
          x86_64|amd64|"") echo "base-linux-x86_64" ;;
          aarch64|arm64) echo "base-linux-aarch64" ;;
          *) echo "Unsupported Linux architecture: $arch" >&2; exit 1 ;;
        esac
        ;;
      *) echo "Unsupported system: $system" >&2; exit 1 ;;
    esac
  fi
}

detect_arch() {
  case "$(uname -m)" in
    x86_64|amd64) echo "x86_64" ;;
    aarch64|arm64) echo "aarch64" ;;
    *) echo "" ;;
  esac
}

if [[ -z "$TARGET_SYSTEM" ]]; then
  TARGET_SYSTEM="$(default_system)"
fi

if [[ "$TARGET_SYSTEM" == "linux" ]]; then
  if [[ -z "$TARGET_ARCH" ]]; then
    TARGET_ARCH="$(detect_arch)"
    if [[ -z "$TARGET_ARCH" ]]; then
      echo "Unable to detect Linux architecture (uname -m=$(uname -m)). Use --arch to specify." >&2
      exit 1
    fi
  fi
fi

if [[ -z "$FLAKE_BASE" ]]; then
  FLAKE_BASE="$DEFAULT_FLAKE_BASE"
fi

FLAKE_ATTR="$(attr_for_system "$TARGET_SYSTEM" "$BASE_ONLY" "$TARGET_ARCH")"
FLAKE_PATH="${FLAKE_BASE}#${FLAKE_ATTR}"
HM_USER="${USER:-}"
if [[ -z "$HM_USER" ]]; then
  HM_USER="$(id -un 2>/dev/null || echo root)"
  export USER="$HM_USER"
fi

if ! command -v nix >/dev/null 2>&1; then
  echo "Nix is not installed. Install Nix first: https://nixos.org/download.html" >&2
  exit 1
fi

print_step "Ensuring experimental features are enabled"
CONFIG_DIR="${HOME}/.config/nix"
CONFIG_FILE="${CONFIG_DIR}/nix.conf"
mkdir -p "${CONFIG_DIR}"
if [[ ! -f "${CONFIG_FILE}" ]]; then
  printf 'experimental-features = nix-command flakes\n' > "${CONFIG_FILE}"
else
  tmp_file=$(mktemp)
  awk '
    BEGIN { done = 0 }
    /^experimental-features[[:space:]]*=/ {
      line = $0
      if (index(line, "nix-command") == 0) {
        line = line " nix-command"
      }
      if (index(line, "flakes") == 0) {
        line = line " flakes"
      }
      print line
      done = 1
      next
    }
    { print }
    END {
      if (done == 0) {
        print "experimental-features = nix-command flakes"
      }
    }
  ' "${CONFIG_FILE}" > "${tmp_file}"
  mv "${tmp_file}" "${CONFIG_FILE}"
fi

if [[ "$PREPARE_ONLY" == "true" ]]; then
  print_step "Building home-manager configuration (${FLAKE_ATTR})"
  env USER="$HM_USER" nix run --refresh --impure \
    --extra-experimental-features 'nix-command flakes' \
    home-manager/master \
    -- build --flake "${FLAKE_PATH}" "${HM_ARGS[@]}"
else
  print_step "Running home-manager switch (${FLAKE_ATTR})"
  exec env USER="$HM_USER" nix run --refresh --impure \
    --extra-experimental-features 'nix-command flakes' \
    home-manager/master \
    -- switch --flake "${FLAKE_PATH}" "${HM_ARGS[@]}"
fi
