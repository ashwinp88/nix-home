{ config, pkgs, lib, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    withRuby = false;  # Use project-specific Ruby via shadowenv
    withPython3 = true;
    withNodeJs = true;

    # Extra packages available to Neovim
    extraPackages = with pkgs; [
      # Language servers
      lua-language-server
      nil  # Nix LSP
      nodePackages.typescript-language-server
      nodePackages.vscode-langservers-extracted  # HTML, CSS, JSON, ESLint

      # Formatters and linters
      stylua
      nixfmt-rfc-style
      nodePackages.prettier

      # Essential tools
      tree-sitter
      ripgrep
      fd
      git

      # For yanky.nvim
      sqlite
    ];
  };

  # Copy the base Neovim configuration
  # Ruby-specific plugins are added by the Ruby module
  xdg.configFile."nvim" = {
    source = ../../configs/neovim;
    recursive = true;
  };
}