# Base modules for LazyVim configuration
{ ... }:

{
  imports = [
    ../base/git.nix
    ../base/shell.nix
    ../base/terminal.nix
    ../base/neovim-lazyvim.nix  # Use LazyVim module instead
    ../base/tmux.nix
    ../base/tools.nix
  ];
}
