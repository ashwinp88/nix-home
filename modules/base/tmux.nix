{ config, pkgs, lib, ... }:

{
  programs.tmux = {
    enable = true;
    prefix = "C-s";
    mouse = true;
    terminal = "screen-256color";
    historyLimit = 10000;
    keyMode = "vi";

    # Use TPM for all plugins - no Nix plugins
    plugins = [];

    extraConfig = ''
      unbind r
      bind r source-file ~/.config/tmux/tmux.conf

      # Disable automatic clipboard access (we'll use explicit copy with 'y')
      set -s set-clipboard off

      # Terminal overrides for proper cursor support (use vertical bar cursor)
      set -ga terminal-overrides ',*:Ss=\E[%p1%d q:Se=\E[6 q'
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

      # Keep position when copying with mouse
      set -g @yank_action 'copy-pipe'  # Stay in copy mode after yanking

      # tmux-yank settings - disable mouse copy
      set -g @yank_with_mouse off

      # List of plugins
      set -g @plugin 'tmux-plugins/tpm'
      set -g @plugin 'catppuccin/tmux'
      set -g @plugin 'tmux-plugins/tmux-cpu'
      set -g @plugin 'tmux-plugins/tmux-yank'
      set -g @plugin 'pcasaretto/tmux-git-worktree'

      # Copy mode configuration
      set-window-option -g mode-keys vi
      set-window-option -g wrap-search on

      # Copy mode search highlighting (Catppuccin colors)
      set -g mode-style "fg=#{@thm_bg},bg=#{@thm_yellow}"  # Search highlight
      set -g copy-mode-match-style "fg=#{@thm_bg},bg=#{@thm_green}"  # Current match
      set -g copy-mode-current-match-style "fg=#{@thm_bg},bg=#{@thm_peach}"  # Current match under cursor
      set -g copy-mode-mark-style "fg=#{@thm_bg},bg=#{@thm_red}"  # Selection marking

      # Configure Catppuccin
      set -g @catppuccin_flavour "macchiato"
      set -g @catppuccin_window_left_separator ""
      set -g @catppuccin_window_right_separator " "
      set -g @catppuccin_window_middle_separator " █"
      set -g @catppuccin_window_number_position "right"
      set -g @catppuccin_window_default_fill "number"
      set -g @catppuccin_window_default_text "#W"
      set -g @catppuccin_window_current_fill "number"
      set -g @catppuccin_window_current_text "#W"
      set -g @catppuccin_status_modules_right ""
      set -g @catppuccin_status_modules_left ""
      set -g @catppuccin_status_left_separator  " "
      set -g @catppuccin_status_right_separator ""
      set -g @catppuccin_status_fill "icon"
      set -g @catppuccin_status_connect_separator "no"

      # status left look and feel
      set -g status-left-length 100
      set -g status-left ""
      set -ga status-left "#{?client_prefix,#{#[bg=#{@thm_red},fg=#{@thm_bg},bold] 󰆍 #S },#{#[bg=#{@thm_bg},fg=#{@thm_green}] 󰆍 #S }}"
      set -ga status-left "#[bg=#{@thm_bg},fg=#{@thm_overlay_0},none]│"
      set -ga status-left "#[bg=#{@thm_bg},fg=#{@thm_maroon}]  #{pane_current_command} "
      set -ga status-left "#[bg=#{@thm_bg},fg=#{@thm_overlay_0},none]│"
      set -ga status-left "#[bg=#{@thm_bg},fg=#{@thm_blue}] 󰉋 #{=/-32/...:#{s|$USER|~|:#{b:pane_current_path}}} "
      set -ga status-left "#[bg=#{@thm_bg},fg=#{@thm_overlay_0},none]#{?window_zoomed_flag,│,}"
      set -ga status-left "#[bg=#{@thm_bg},fg=#{@thm_yellow}]#{?window_zoomed_flag,  zoom ,}"
      set -ga status-left "#{?#{!=:#{git_worktree},},#[bg=#{@thm_bg}#,fg=#{@thm_overlay_0}]│#[bg=#{@thm_bg}#,fg=#{@thm_flamingo}]  #{git_worktree} ,}"

      # status right look and feel
      set -g status-right '#[bg=#{@thm_bg},fg=#{@thm_green}]   CPU #{cpu_percentage} '
      set -ag status-right '#[bg=#{@thm_bg},fg=#{@thm_flamingo}]   MEM #{ram_percentage} '

      # bootstrap tpm
      if "test ! -d ~/.tmux/plugins/tpm" \
         "run 'git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm && ~/.tmux/plugins/tpm/bin/install_plugins'"

      # Initialize TMUX plugin manager
      run '~/.tmux/plugins/tpm/tpm'

      # Configure Tmux
      set -g status-position top
      set -g status-style "bg=#{@thm_bg}"
      set -g status-justify "absolute-centre"

      # pane border look and feel
      # setw -g pane-active-border-style "fg=#{@thm_blue}"
      # setw -g pane-border-style "fg=#{@thm_surface_0}"
      
      # Set inactive pane border style
      set -g pane-border-style "fg=colour240,bg=default"

      # Set active pane border style to a prominent color
      set -g pane-active-border-style "fg=cyan,bg=default"

      # Use simple lines for borders
      set -g pane-border-lines "simple"
      
      # window look and feel
      # set -wg automatic-rename on
      # set -g automatic-rename-format "Window"

      set -g window-status-format " #I#{?#{!=:#{window_name},Window},: #W,} "
      set -g window-status-style "bg=#{@thm_bg},fg=#{@thm_rosewater}"
      set -g window-status-last-style "bg=#{@thm_bg},fg=#{@thm_peach}"
      set -g window-status-activity-style "bg=#{@thm_red},fg=#{@thm_bg}"
      set -g window-status-bell-style "bg=#{@thm_red},fg=#{@thm_bg},bold"
      set -gF window-status-separator "#[bg=#{@thm_bg},fg=#{@thm_overlay_0}]│"
      set -g window-status-current-format " #I#{?#{!=:#{window_name},Window},: #W,} "
      set -g window-status-current-style "bg=#{@thm_peach},fg=#{@thm_bg},bold"
    '';
  };
}
