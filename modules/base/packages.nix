{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    # Development tools
    lazygit         # Git UI
    delta           # Better git diff
    ripgrep         # Better grep
    fd              # Better find
    fzf             # Fuzzy finder
    bat             # Better cat
    eza             # Better ls (exa replacement)
    jq              # JSON processor
    tree            # Directory tree
    btop            # Better process viewer (replaced htop)

    # Version control
    git
    gh              # GitHub CLI

    # Nix tools
    nil             # Nix LSP
    nixfmt-rfc-style # Nix formatter
    nix-direnv      # Direnv with Nix support

    # Language runtimes (always available)
    nodejs_20       # Node.js for development
    jdk21           # Java Development Kit

    # Additional tools
    tmux            # Terminal multiplexer
    direnv          # Environment management
    sqlite          # For yanky.nvim database
  ];

  # Base environment variables
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    PAGER = "less";
    LESS = "-R";
  };
}