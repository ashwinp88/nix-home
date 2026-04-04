# Base modules for LazyVim configuration
{ config, pkgs, lib, ... }:

{
  imports = [
    ../base/homebrew-options.nix
    ../base/packages.nix
    ../base/ruby.nix
    ../base/tmux.nix
    ../base/neovim-lazyvim.nix  # Use LazyVim module instead
    ../base/shell.nix
    ../base/git.nix
    ../base/lazygit.nix
  ];
}
