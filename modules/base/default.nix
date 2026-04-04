{ config, pkgs, lib, ... }:

{
  imports = [
    ./homebrew-options.nix
    ./packages.nix
    ./ruby.nix
    ./tmux.nix
    ./neovim.nix
    ./shell.nix
    ./git.nix
    ./lazygit.nix
  ];
}
