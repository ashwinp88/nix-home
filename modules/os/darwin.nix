{ config, pkgs, lib, ... }:

{
  # macOS-specific packages
  home.packages = with pkgs; [
    reattach-to-user-namespace  # For macOS clipboard support in tmux
    nerd-fonts.fira-code       # Primary font for Ghostty and terminal
    nerd-fonts.jetbrains-mono  # Alternative font option
  ];

  # macOS-specific tmux configuration (ONLY clipboard)
  programs.tmux.extraConfig = ''
    set -g default-command "reattach-to-user-namespace -l ''${SHELL}"
    bind-key -T copy-mode-vi y send-keys -X copy-pipe "reattach-to-user-namespace pbcopy"
    bind-key -T copy-mode-vi Enter send-keys -X copy-pipe-and-cancel "reattach-to-user-namespace pbcopy"
    run-shell 'tmux bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-selection-no-clear'
  '';

  # Homebrew environment variables
  home.sessionVariables = {
    HOMEBREW_PREFIX = "/opt/homebrew";
    HOMEBREW_CELLAR = "/opt/homebrew/Cellar";
    HOMEBREW_REPOSITORY = "/opt/homebrew";
  };

  home.sessionPath = [
    "/opt/homebrew/bin"
    "/opt/homebrew/sbin"
  ];

  # Ghostty configuration
  xdg.configFile."ghostty/config" = {
    text = ''
      font-family = "FiraCode Nerd Font"
      font-size = 14
      font-thicken = true

      background = #1e1e2e
      foreground = #cdd6f4

      palette = 0=#45475a
      palette = 8=#585b70
      palette = 1=#f38ba8
      palette = 9=#f38ba8
      palette = 2=#a6e3a1
      palette = 10=#a6e3a1
      palette = 3=#f9e2af
      palette = 11=#f9e2af
      palette = 4=#89b4fa
      palette = 12=#89b4fa
      palette = 5=#f5c2e7
      palette = 13=#f5c2e7
      palette = 6=#94e2d5
      palette = 14=#94e2d5
      palette = 7=#bac2de
      palette = 15=#a6adc8

      cursor-color = #f5e0dc
      cursor-text = #1e1e2e

      selection-background = #585b70
      selection-foreground = #cdd6f4

      window-padding-x = 10
      window-padding-y = 10
      window-decoration = true
      window-theme = dark

      scrollback-limit = 10000

      audible-bell = false
      visual-bell = false

      cursor-style = block
      cursor-blink = true

      copy-on-select = true

      shell-integration = zsh

      keybind = cmd+n=new_window
      keybind = cmd+t=new_tab
      keybind = cmd+shift+t=new_tab:current_pane_directory
      keybind = cmd+enter=toggle_fullscreen
      keybind = cmd+d=split_right
      keybind = cmd+shift+d=split_down
      keybind = cmd+w=close_surface
      keybind = cmd+shift+[=previous_tab
      keybind = cmd+shift+]=next_tab
      keybind = cmd+1=goto_tab:1
      keybind = cmd+2=goto_tab:2
      keybind = cmd+3=goto_tab:3
      keybind = cmd+4=goto_tab:4
      keybind = cmd+5=goto_tab:5
      keybind = cmd+6=goto_tab:6
      keybind = cmd+7=goto_tab:7
      keybind = cmd+8=goto_tab:8
      keybind = cmd+9=goto_tab:9
      keybind = cmd+0=goto_tab:10
      keybind = cmd+k=clear_screen
      keybind = cmd+shift+k=clear_scrollback

      macos-option-as-alt = true
      macos-non-native-fullscreen = false
      macos-titlebar-style = transparent
      macos-titlebar-proxy-icon = hidden

      gpu-backend = metal
      max-fps = 120

      working-directory = home
    '';
  };

  # Install Homebrew and Ghostty
  home.activation.setupHomebrew = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if [ ! -x /opt/homebrew/bin/brew ]; then
      echo "Installing Homebrew..."
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    if command -v brew &> /dev/null; then
      brew list --cask ghostty &>/dev/null || brew install --cask ghostty || true
    fi
  '';
}