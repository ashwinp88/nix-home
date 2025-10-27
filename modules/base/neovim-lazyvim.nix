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

    # Minimal packages - LazyVim's Mason handles most LSPs
    extraPackages = with pkgs; [
      # Formatters and linters (not managed by Mason)
      stylua
      nixfmt-rfc-style
      nodePackages.prettier

      # Essential tools (always needed)
      tree-sitter
      ripgrep
      fd
      git

      # For yanky.nvim and snacks.nvim
      sqlite
    ];
  };

  # Copy the LazyVim Neovim configuration
  # Ruby-specific plugins are added by the Ruby module
  xdg.configFile."nvim" = {
    source = ../../configs/neovim-lazyvim;
    recursive = true;
  };
}
