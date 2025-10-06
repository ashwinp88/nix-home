{ config, pkgs, lib, ... }:

{
  programs.lazygit = {
    enable = true;
    settings = {
      git = {
        autoFetch = false;
        paging = {
          colorArg = "always";
          pager = "delta --dark --paging=never";
        };
      };

      gui = {
        theme = {
          activeBorderColor = ["#89b4fa" "bold"];
          inactiveBorderColor = ["#45475a"];
          selectedLineBgColor = ["#313244"];
          selectedRangeBgColor = ["#313244"];
          cherryPickedCommitBgColor = ["#45475a"];
          cherryPickedCommitFgColor = ["#89b4fa"];
          unstagedChangesColor = ["#f38ba8"];
          defaultFgColor = ["#cdd6f4"];
        };

        nerdFontsVersion = "3";
        showFileTree = true;
        showRandomTip = false;

        commitLength = {
          show = true;
        };
      };
    };
  };
}