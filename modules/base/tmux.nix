{ config, pkgs, lib, ... }:

{
  programs.tmux = {
    enable = true;
    prefix = "C-s";
    mouse = true;
    keyMode = "vi";
    terminal = "screen-256color";
    historyLimit = 10000;

    # Install plugins via Nix
    plugins = with pkgs.tmuxPlugins; [
      {
        plugin = catppuccin;
        extraConfig = ''
          set -g @catppuccin_flavor "macchiato"
          set -g @catppuccin_status_background "none"
          set -g @catppuccin_window_status_style "none"
          set -g @catppuccin_pane_status_enabled "off"
          set -g @catppuccin_pane_border_status "off"
        '';
      }
      {
        plugin = cpu;
        extraConfig = "";
      }
      {
        plugin = yank;
        extraConfig = ''
          # Keep position when copying with mouse (critical for not scrolling down)
          set -g @yank_action 'copy-pipe'
          set -g @yank_with_mouse off
        '';
      }
      # Note: git-worktree plugin needs manual installation for now
    ];

    extraConfig = ''
      # Reload config
      unbind r
      bind r source-file ~/.tmux.conf

      # Disable automatic clipboard access
      set -s set-clipboard off

      # Terminal overrides for proper cursor support
      set -ga terminal-overrides ',*:Ss=\E[%p1%d q:Se=\E[2 q'
      set -as terminal-features ',*:RGB'

      # Allow terminal to set cursor shape
      set -g -a terminal-overrides ',xterm*:Cr=\E[?12h\E[?25h'
      set -g -a terminal-overrides ',iterm*:Cr=\E[?12h\E[?25h'

      # Make new panes inherit current working directory
      bind % split-window -h -c "#{pane_current_path}"
      bind '"' split-window -v -c "#{pane_current_path}"
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"

      # Make new windows inherit current working directory
      bind c new-window -c "#{pane_current_path}"

      # Better mouse scrolling behavior
      set -g @scroll-speed-num-lines-per-scroll 3
      set -g @emulate-scroll-for-no-mouse-alternate-buffer on

      # Copy mode configuration
      set-window-option -g mode-keys vi
      set-window-option -g wrap-search on

      # Copy mode search highlighting (Catppuccin colors)
      set -g mode-style "fg=#{@thm_bg},bg=#{@thm_yellow}"  # Search highlight
      set -g copy-mode-match-style "fg=#{@thm_bg},bg=#{@thm_green}"  # Current match
      set -g copy-mode-current-match-style "fg=#{@thm_bg},bg=#{@thm_peach}"  # Current match under cursor
      set -g copy-mode-mark-style "fg=#{@thm_bg},bg=#{@thm_red}"  # Selection marking

      # Status bar configuration
      set -g status-position top
      set -g status-style "bg=#{@thm_bg}"
      set -g status-justify "absolute-centre"

      # Status left look and feel
      set -g status-left-length 100
      set -g status-left ""
      set -ga status-left "#{?client_prefix,#{#[bg=#{@thm_red},fg=#{@thm_bg},bold]  #S },#{#[bg=#{@thm_bg},fg=#{@thm_green}]  #S }}"
      set -ga status-left "#[bg=#{@thm_bg},fg=#{@thm_overlay_0},none]│"
      set -ga status-left "#[bg=#{@thm_bg},fg=#{@thm_maroon}]  #{pane_current_command} "
      set -ga status-left "#[bg=#{@thm_bg},fg=#{@thm_overlay_0},none]│"
      set -ga status-left "#[bg=#{@thm_bg},fg=#{@thm_blue}]  #{=/-32/...:#{s|$USER|~|:#{b:pane_current_path}}} "
      set -ga status-left "#[bg=#{@thm_bg},fg=#{@thm_overlay_0},none]#{?window_zoomed_flag,│,}"
      set -ga status-left "#[bg=#{@thm_bg},fg=#{@thm_yellow}]#{?window_zoomed_flag,  zoom ,}"

      # Git worktree in status (if plugin is available)
      set -ga status-left "#{?#{!=:#{git_worktree},},#[bg=#{@thm_bg}#,fg=#{@thm_overlay_0}]│#[bg=#{@thm_bg}#,fg=#{@thm_flamingo}]  #{git_worktree} ,}"

      # Status right look and feel
      set -g status-right '#[bg=#{@thm_bg},fg=#{@thm_green}] CPU #{cpu_percentage} '
      set -ag status-right '#[bg=#{@thm_bg},fg=#{@thm_flamingo}] MEM #{ram_percentage} '

      # Pane border look and feel
      setw -g pane-border-status top
      setw -g pane-border-format ""
      setw -g pane-active-border-style "bg=#{@thm_bg},fg=#{@thm_blue},bold"
      setw -g pane-border-style "bg=#{@thm_bg},fg=#{@thm_surface_0}"
      setw -g pane-border-lines single

      # Dim inactive panes for better focus indication
      set -g window-style 'bg=colour235'
      set -g window-active-style 'bg=colour232'

      # Hooks for pane focus changes (optional visual feedback)
      set-hook -g pane-focus-in 'selectp -P bg=default'
      set-hook -g pane-focus-out 'selectp -P bg=colour235'

      # Window look and feel
      set -wg automatic-rename on
      set -g automatic-rename-format "Window"

      set -g window-status-format " #I#{?#{!=:#{window_name},Window},: #W,} "
      set -g window-status-style "bg=#{@thm_bg},fg=#{@thm_rosewater}"
      set -g window-status-last-style "bg=#{@thm_bg},fg=#{@thm_peach}"
      set -g window-status-activity-style "bg=#{@thm_red},fg=#{@thm_bg}"
      set -g window-status-bell-style "bg=#{@thm_red},fg=#{@thm_bg},bold"
      set -gF window-status-separator "#[bg=#{@thm_bg},fg=#{@thm_overlay_0}]│"
      set -g window-status-current-format " #I#{?#{!=:#{window_name},Window},: #W,} "
      set -g window-status-current-style "bg=#{@thm_peach},fg=#{@thm_bg},bold"

      # Manual TPM installation and plugin loading for git-worktree
      # (Since it's not in nixpkgs yet)
      set -g @plugin 'pcasaretto/tmux-git-worktree'

      # Bootstrap TPM if needed (for manual plugins)
      if "test ! -d ~/.tmux/plugins/tpm" \
         "run 'git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm && ~/.tmux/plugins/tpm/bin/install_plugins'"

      # Initialize TMUX plugin manager (for manual plugins)
      run '~/.tmux/plugins/tpm/tpm'
    '';
  };
}