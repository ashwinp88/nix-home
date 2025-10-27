{ config, pkgs, lib, ... }:

let
  cfg = config.programs.neovim;

  # Read options with environment variable overrides
  useLazyVim = let
    envVal = builtins.getEnv "NVIM_USE_LAZYVIM";
  in if envVal != "" then envVal == "true" else cfg.useLazyVim;

  colorScheme = let
    envVal = builtins.getEnv "NVIM_COLORSCHEME";
  in if envVal != "" then envVal else cfg.colorScheme;

  # LSP packages: minimal for LazyVim (Mason handles most), full for custom config
  lspPackages = if useLazyVim then [
    # LazyVim: Only keep packages Mason doesn't handle well
    # Mason will handle: lua_ls, nil_ls, tsserver, etc.
  ] else [
    # Custom config: Full LSP list
    pkgs.lua-language-server
    pkgs.nil  # Nix LSP
    pkgs.nodePackages.typescript-language-server
    pkgs.nodePackages.vscode-langservers-extracted  # HTML, CSS, JSON, ESLint
  ];
in
{
  options.programs.neovim = {
    useLazyVim = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Use LazyVim distribution instead of custom config (can be overridden by NVIM_USE_LAZYVIM env var)";
    };

    colorScheme = lib.mkOption {
      type = lib.types.str;
      default = "catppuccin";
      description = "Color scheme to use (can be overridden by NVIM_COLORSCHEME env var)";
    };
  };

  config = {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      withRuby = false;  # Use project-specific Ruby via shadowenv
      withPython3 = true;
      withNodeJs = true;

      # Extra packages available to Neovim
      extraPackages = with pkgs; [
        # Formatters and linters (not managed by Mason)
        stylua
        nixfmt-rfc-style
        nodePackages.prettier

        # Essential tools (always needed)
        tree-sitter
        ripgrep
        fd
        git

        # For yanky.nvim and snacks.nvim
        sqlite
      ] ++ lspPackages;
    };

    # Conditionally select config directory based on useLazyVim
    xdg.configFile."nvim" = {
      source = if useLazyVim
        then ../../configs/neovim-lazyvim
        else ../../configs/neovim;
      recursive = true;
    };

    # Pass colorscheme to Neovim via environment variable
    home.sessionVariables = {
      NVIM_COLORSCHEME = colorScheme;
    };
  };
}