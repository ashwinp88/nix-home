{ lib, ... }:

let
  inherit (lib) mkOption types;
in
{
  options.homebrew = {
    formulas = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Homebrew formula packages to install.";
    };

    casks = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Homebrew cask packages to install.";
    };
  };
}
