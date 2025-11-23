{ config, pkgs, lib, ... }:

let
  osc52CopyScript = ''
    #!/usr/bin/env bash
    set -euo pipefail

    tty_target='''${1:-}
    if [[ -z "$tty_target" ]]; then
      echo "osc52-copy: missing tty" >&2
      exit 1
    fi

    tmp=$(mktemp)
    trap 'rm -f "$tmp"' EXIT
    cat > "$tmp"

    if [[ ! -s "$tmp" ]]; then
      exit 0
    fi

    enc=$(base64 < "$tmp" | tr -d '\n')
    printf '\e]52;c;%s\a' "$enc" > "$tty_target"
  '';
in
{
  # Linux-specific packages
  home.packages = lib.mkAfter (with pkgs; [
    docker          # Docker Engine
    gh              # GitHub CLI (ensure present on Linux too)
  ]);

  # Script used to relay tmux selections via OSC52 (host clipboard over SSH)
  home.file.".config/tmux/bin/osc52-copy" = {
    text = osc52CopyScript;
    executable = true;
  };

  # Linux-specific tmux configuration
  programs.tmux.extraConfig = ''
    # Allow OSC52 passthrough so remote copies reach the SSH client
    set -g allow-passthrough on

    # Copy selections to the host clipboard using OSC52 escape sequences
    set -g @osc52_copy_cmd '~/.config/tmux/bin/osc52-copy #{pane_tty}'

    bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "#{@osc52_copy_cmd}"
    bind-key -T copy-mode-vi Enter send-keys -X copy-pipe-and-cancel "#{@osc52_copy_cmd}"
    bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "#{@osc52_copy_cmd}"

    # Keep tmux buffer copy as a fallback (prefix + ])
    bind-key -T copy-mode-vi Y send-keys -X copy-selection
  '';
}
