{ config, pkgs, lib, ... }:

{
  imports = [
    ./packages.nix
    ./tmux.nix
    ./neovim.nix
    ./shell.nix
    ./git.nix
  ];
}