{ config, pkgs, ... }:

{
  programs.rbenv = {
    enable = true;
    enableZshIntegration = true;
    plugins = [
      {
        name = "ruby-build";
        src = pkgs.ruby-build.src;
      }
    ];
  };
}
