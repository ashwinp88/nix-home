#!/usr/bin/env bash
set -euo pipefail

root="$1"
shift
cmd=("$@")

if command -v shadowenv >/dev/null 2>&1; then
  exec shadowenv exec -- "${cmd[@]}"
else
  exec "${cmd[@]}"
fi
