{ config, pkgs, lib, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [ "git" ];
    };

    initContent = ''
      export JAVA_HOME="${pkgs.jdk21}/lib/openjdk"
      export PATH="$JAVA_HOME/bin:$PATH"

      export NODE_OPTIONS="--max-old-space-size=12288"

      fzf-history-widget() {
        local selected num
        setopt localoptions noglobsubst noposixbuiltins pipefail no_aliases 2> /dev/null
        selected="$(fc -rl 1 | fzf --height=40% --reverse --tiebreak=index --query="$LBUFFER")"
        local ret=$?
        if [ -n "$selected" ]; then
          num=$(echo "$selected" | sed 's/^ *\([0-9]*\).*/\1/')
          if [ -n "$num" ]; then
            zle vi-fetch-history -n $num
          fi
        fi
        zle reset-prompt
        return $ret
      }
      zle -N fzf-history-widget
      bindkey '^r' fzf-history-widget

      PROMPT='%{$fg[blue]%}%~%{$reset_color%} $(git_prompt_info)
%{$fg[green]%}❯%{$reset_color%} '

      ZSH_THEME_GIT_PROMPT_PREFIX="on %{$fg[green]%}"
      ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
      ZSH_THEME_GIT_PROMPT_DIRTY=" %{$fg[red]%}[!+]%{$reset_color%}"
      ZSH_THEME_GIT_PROMPT_CLEAN=""

      setopt EXTENDED_HISTORY
      setopt HIST_EXPIRE_DUPS_FIRST
      setopt HIST_IGNORE_DUPS
      setopt HIST_IGNORE_SPACE
      setopt HIST_VERIFY
      setopt SHARE_HISTORY
      setopt AUTO_CD
      setopt AUTO_PUSHD
      setopt PUSHD_IGNORE_DUPS
      setopt PUSHD_SILENT
      setopt COMPLETE_IN_WORD
      setopt ALWAYS_TO_END
    '';

    sessionVariables = {
      DISABLE_AUTO_TITLE = "true";
    };

    shellAliases = {
      # Git aliases
      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gl = "git pull";
      gd = "git diff";
      gco = "git checkout";
      gb = "git branch";

      # Directory navigation
      ll = "eza -l --icons";
      la = "eza -la --icons";
      lt = "eza --tree --icons";

      # Shortcuts
      vim = "nvim";
      vi = "nvim";

      # Nix shortcuts
      nrs = "home-manager switch";
      nrb = "home-manager build";
    };
  };


  # Enable direnv for automatic environment switching
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  # FZF configuration
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = "fd --type f --hidden --follow --exclude .git";
    defaultOptions = [
      "--height=40%"
      "--layout=reverse"
      "--border"
      "--inline-info"
      "--color=dark"
    ];
  };

  # Bat configuration
  programs.bat = {
    enable = true;
    config = {
      theme = "Catppuccin-mocha";
      style = "numbers,changes,header";
    };
  };
}