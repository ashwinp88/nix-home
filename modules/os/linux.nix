{ config, pkgs, lib, ... }:

{
  # Linux-specific packages
  home.packages = lib.mkAfter (with pkgs; [
    docker          # Docker Engine
    gh              # GitHub CLI (ensure present on Linux too)
  ]);

  # Linux-specific tmux configuration
  programs.tmux.extraConfig = ''
    # Headless Linux - tmux buffer only (simplest, most reliable)
    # Copy stays within tmux buffers - can be pasted within tmux with prefix + ]

    # Copy selection to tmux buffer
    bind-key -T copy-mode-vi y send-keys -X copy-selection
    bind-key -T copy-mode-vi Enter send-keys -X copy-selection-and-cancel

    # Mouse selection stays in tmux buffer
    bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-selection-no-clear

    # Note for future enhancement:
    # Can upgrade to OSC 52 escape sequences later if SSH client supports it
    # Or install xclip if X11 forwarding becomes available
  '';

  # Linux-specific environment settings
  # To add Linux-specific environment variables use lib.mkAfter, e.g.:
  # home.sessionVariables = lib.mkAfter { KEY = "value"; };
}
