{ config, pkgs, lib, ... }:

{
  programs.git = {
    enable = true;
    userName = "Ashwin Purushotaman";
    userEmail = "ashwin.p88@gmail.com";

    extraConfig = {
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      pull.rebase = true;

      core = {
        editor = "nvim";
        autocrlf = "input";
      };

      # Better diff
      diff = {
        algorithm = "histogram";
        colorMoved = "default";
      };

      merge = {
        conflictStyle = "zdiff3";
      };

      # Improve performance
      feature.manyFiles = true;

      # GitHub CLI integration
      credential."https://github.com" = {
        helper = "!gh auth git-credential";
      };
    };

    # Git aliases
    aliases = {
      st = "status -sb";
      co = "checkout";
      br = "branch";
      ci = "commit";
      unstage = "reset HEAD --";
      last = "log -1 HEAD";
      lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      amend = "commit --amend --no-edit";
    };
  };
}