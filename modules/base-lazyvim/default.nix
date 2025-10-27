# Base modules for LazyVim configuration
{ config, pkgs, lib, ... }:

{
  imports = [
    ../base/packages.nix
    ../base/tmux.nix
    ../base/neovim-lazyvim.nix  # Use LazyVim module instead
    ../base/shell.nix
    ../base/git.nix
    ../base/lazygit.nix
  ];
}
