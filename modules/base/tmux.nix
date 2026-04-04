{ config, pkgs, lib, ... }:

{
  programs.tmux = {
    enable = true;
    mouse = true;
    terminal = "tmux-256color";
    historyLimit = 10000;
    keyMode = "vi";
    prefix = "C-b";

    # Use TPM for all plugins - no Nix plugins
    plugins = [];

    extraConfig = ''
      unbind r
      bind r source-file ~/.config/tmux/tmux.conf

      # Disable "/" in copy-mode, only allow search via prefix + /
      unbind -T copy-mode-vi /
      bind / copy-mode \; command-prompt -p "search down:" "send-keys -X search-forward '%%'"

      # Extended keys: keep on, but prefer xterm format for app compatibility.
      set -s extended-keys on
      set -s extended-keys-format xterm

      # Allow OSC52 passthrough from nested apps while keeping tmux copy-mode
      # as the primary clipboard path.
      set -g allow-passthrough on

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

      # Enable OSC 52 clipboard (works over SSH without pbcopy/xclip)
      set -g set-clipboard on
      set -ag terminal-features ',*:clipboard'

      # Native copy-mode bindings. These update tmux's paste buffer and let tmux
      # forward clipboard contents via OSC52 when supported by the client terminal.
      bind-key -T copy-mode-vi y send-keys -X copy-selection-no-clear
      bind-key -T copy-mode-vi Enter send-keys -X copy-selection-and-cancel
      # Keep mouse selections visible after release instead of tmux's default
      # copy-pipe-and-cancel behavior on drag end.
      bind-key -T copy-mode MouseDragEnd1Pane send-keys -X copy-selection-no-clear
      bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-selection-no-clear

      # List of plugins
      set -g @plugin 'tmux-plugins/tpm'
      set -g @plugin 'catppuccin/tmux'
      set -g @plugin 'tmux-plugins/tmux-cpu'
      set -g @plugin 'pcasaretto/tmux-git-worktree'
      set -g @plugin 'tmux-plugins/tmux-resurrect'
      set -g @plugin 'tmux-plugins/tmux-continuum'

      # tmux-resurrect settings
      set -g @resurrect-capture-pane-contents 'on'
      set -g @resurrect-strategy-nvim 'session'
      set -g @resurrect-save 'S'
      set -g @resurrect-restore 'R'

      # tmux-continuum settings
      set -g @continuum-restore 'on'
      set -g @continuum-save-interval '15'

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
      set -ga status-left "#{?#{!=:#{git_worktree},},#[bg=#{@thm_bg},fg=#{@thm_overlay_0}]│#[bg=#{@thm_bg},fg=#{@thm_flamingo}]  #{git_worktree} ,}"

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
