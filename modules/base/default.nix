{ config, pkgs, lib, ... }:

{
  imports = [
    ./packages.nix
    ./ruby.nix
    ./tmux.nix
    ./neovim.nix
    ./shell.nix
    ./git.nix
    ./lazygit.nix
  ];

  languages.ruby.provider = "rbenv";
}
