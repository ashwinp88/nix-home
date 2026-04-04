{ config, pkgs, lib, ... }:

{
  # Linux-specific packages
  home.packages = lib.mkAfter (with pkgs; [
    docker          # Docker Engine
    gh              # GitHub CLI (ensure present on Linux too)
    libyaml         # Headers needed for psych when compiling Ruby
    libffi          # Headers needed for fiddle when compiling Ruby
    ncurses         # Terminfo database + infocmp for Nix-provided terminal apps (tmux)
  ]);

  # Ensure Nix-provided tmux can find terminfo on Debian systems
  home.sessionVariables = {
    TERMINFO_DIRS = "$HOME/.nix-profile/share/terminfo:/usr/share/terminfo";
  };

}
