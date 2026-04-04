# Personal Nix Home Manager Configuration

A modular, portable Nix configuration for development environments across macOS and Linux.

## Two Flavors Available

This repository provides **two independent Neovim configurations** to choose from:

### 🔧 Vanilla (Default)
Custom lazy.nvim configuration with hand-picked plugins and complete control.
- **Explorer**: Neo-tree with multi-source support (files, buffers, git, symbols)
- **Finder**: Snacks.picker for fuzzy finding
- **LSPs**: All managed via Nix packages
- **Full control**: Every plugin explicitly configured

### 🚀 LazyVim
LazyVim distribution with minimal overrides for best-practice defaults.
- **Explorer**: Snacks.explorer (lightweight file tree)
- **Finder**: Snacks.picker (same as vanilla)
- **LSPs**: Mason auto-installs most LSPs, Ruby/Sorbet via Nix
- **Less config**: Leverages LazyVim's excellent defaults
- **Easy updates**: Stay current with LazyVim releases

**Both configurations:**
- Share the same core tools and environment
- Work with Shopify Ruby overlay for shadowenv LSP support
- Support runtime colorscheme switching
- Are fully tested and production-ready

## Features

### Core Tools (Always Available)
- **Development**: JDK 21, Node.js 20, Git, GitHub CLI
- **CLI Tools**: btop, ripgrep, fd, fzf, bat, eza, lazygit, jq, tree
- **Nix**: nil LSP, nixfmt, nix-direnv
- **Shell**: Zsh with oh-my-zsh, Starship prompt, custom fzf integration

### Tmux Configuration
- **Theme**: Catppuccin Macchiato with custom status bar
- **Yank behavior**: Stays in copy mode (doesn't scroll down)
- **Visual feedback**: Pane dimming for better focus
- **Git integration**: Shows current worktree in status bar
- **Clipboard**: Native tmux copy-mode with OSC52 forwarding
- **Plugins**: catppuccin, tmux-cpu, tmux-git-worktree, tmux-resurrect, tmux-continuum

### Neovim Configuration
- **Base plugins**: LSP, treesitter, completion, git integration, file navigation
- **UI**: Catppuccin theme, lualine, bufferline, which-key
- **Keybindings**: Organized by function (`<leader>g` for git, `<leader>f` for find, etc.)
- **Extensible**: Designed to be extended with language-specific plugins

### Platform-Specific

#### macOS
- **Fonts**: FiraCode Nerd Font, JetBrainsMono Nerd Font
- **Terminal**: Ghostty with FiraCode and Catppuccin theme
- **Clipboard**: Native tmux copy-mode with OSC52 forwarding
- **Homebrew**: Environment setup and optional installation

#### Linux (Headless)
- **Docker**: Docker Engine included
- **Clipboard**: Native tmux copy-mode with OSC52 forwarding over SSH
- **No fonts**: Optimized for headless servers

## Quick Start

### One-Shot Installation (Recommended)

**Vanilla (Custom lazy.nvim):**
```bash
curl -L https://raw.githubusercontent.com/ashwinp88/nix-home/main/install.sh | bash
```

**LazyVim:**
```bash
curl -L https://raw.githubusercontent.com/ashwinp88/nix-home/main/install.sh | bash -s -- --lazyvim
```

The install script will:
1. Install Nix (if not present)
2. Enable flakes and nix-command
3. Run home-manager switch
4. Backup existing dotfiles (`.zshrc`, `.bashrc`, `.profile`)

**Options:**
- `--clean`: Remove Nix caches first
- `--skip-nix-install`: Assume Nix is already installed
- `--lazyvim`: Use LazyVim configuration (default: vanilla)
- `--custom`: Explicitly use vanilla configuration

### Manual Installation (Local Development)

**Clone and switch:**
```bash
git clone https://github.com/ashwinp88/nix-home.git ~/Code/nix-home
cd ~/Code/nix-home

# Vanilla configuration
home-manager switch --impure --flake .#base-darwin

# LazyVim configuration
home-manager switch --impure --flake ./lazyvim#base-darwin
```

**Bootstrap script (auto-detects OS):**
```bash
./scripts/bootstrap.sh                 # Vanilla (auto-detects macOS/Linux)
./scripts/bootstrap.sh --prepare-only  # Just build (no switch)
./scripts/bootstrap.sh --base          # Base modules only
./scripts/bootstrap.sh --home /custom/home   # Override HOME

# Use --darwin/--linux to override detection and pass extra flags after --, e.g.
./scripts/bootstrap.sh -- --show-trace
```

**Note:** Existing dotfiles are automatically backed up:
- `.zshrc` → `.zshrc.pre-nix-home` (sourced from `~/.config/zsh/local.zsh`)
- `.bashrc` → `.bashrc.pre-nix-home` (sourced from `~/.config/bash/local.bash`)
- `.profile` → `.profile.pre-nix-home` (sourced from `~/.config/bash/local.profile`)

### First-Time Setup

For tmux plugins to work:
```bash
# Start tmux (TPM bootstraps on first launch)
tmux

# If any plugin is still missing, install/update from inside tmux
# Press: Ctrl+b then I (capital i)
```

For Neovim plugins:
```bash
# Open Neovim (lazy.nvim will auto-install plugins)
nvim

# Wait for plugins to install
# Check status with: :Lazy
```

## Available Configurations

### `base-darwin` (macOS)
Complete development environment for macOS with GUI tools and fonts.

**Includes:**
- All core tools (JDK, Node.js, development CLI tools)
- Tmux with native copy-mode and OSC52 clipboard forwarding
- Neovim with base plugins
- FiraCode and JetBrainsMono Nerd Fonts
- Ghostty terminal emulator
- Homebrew environment setup
- Oh-my-zsh with custom configuration

### `home-darwin` (macOS)
`base-darwin` plus personal Ruby tooling via Nix-managed `rbenv`.

### `base-linux` (Headless Linux)
Optimized configuration for headless Linux servers.

**Includes:**
- All core tools (JDK, Node.js, development CLI tools)
- Tmux with native copy-mode and OSC52 clipboard forwarding
- Neovim with base plugins
- Docker Engine
- Oh-my-zsh with custom configuration
- No fonts, no Ghostty (headless)

### `home-linux` (Headless Linux)
`base-linux` plus personal Ruby tooling via Nix-managed `rbenv`.

## Directory Structure

```
nix-home/
├── flake.nix                     # Vanilla configuration flake
├── flake.lock                    # Locked dependencies (vanilla)
├── lazyvim/
│   ├── flake.nix                 # LazyVim configuration flake
│   └── flake.lock                # Locked dependencies (LazyVim)
├── install.sh                    # One-shot installer with --lazyvim flag
├── test-sandbox.sh               # Sandbox testing script
├── modules/
│   ├── base/                     # Vanilla base modules
│   │   ├── default.nix           # Imports all vanilla modules
│   │   ├── homebrew-options.nix  # Shared Homebrew option declarations
│   │   ├── neovim.nix            # Vanilla neovim (full LSP packages)
│   │   ├── packages.nix          # Core packages (JDK, Node, tools)
│   │   ├── ruby.nix              # Optional Ruby capability module
│   │   ├── tmux.nix              # Tmux configuration
│   │   ├── shell.nix             # Zsh, oh-my-zsh, custom config
│   │   ├── git.nix               # Git configuration
│   │   └── lazygit.nix           # Lazygit configuration
│   ├── base-lazyvim/             # LazyVim base modules
│   │   ├── default.nix           # Imports all LazyVim modules
│   │   └── neovim-lazyvim.nix    # LazyVim neovim (minimal LSPs, Mason handles rest)
│   ├── personal/
│   │   └── ruby.nix              # Personal Ruby/rbenv overlay
│   └── os/                       # OS-specific modules (shared by both)
│       ├── darwin.nix            # macOS: fonts, Ghostty, clipboard
│       └── linux.nix             # Linux: Docker, terminfo
├── configs/
│   ├── neovim/                   # Vanilla Neovim configuration
│   │   ├── init.lua              # Bootstrap lazy.nvim
│   │   ├── lua/
│   │   │   ├── config/           # Editor settings, keymaps
│   │   │   └── plugins/          # Complete plugin set
│   │   │       ├── neo-tree.lua  # File explorer
│   │   │       ├── snacks.lua    # Snacks.nvim features
│   │   │       ├── completion.lua
│   │   │       └── ...
│   │   └── commands/             # Custom commands
│   └── neovim-lazyvim/           # LazyVim minimal overrides
│       ├── init.lua              # LazyVim bootstrap
│       ├── lua/
│       │   ├── config/           # Custom options, keymaps, autocmds
│       │   └── plugins/          # Minimal overrides only
│       │       ├── lsp.lua       # Disable Mason for Ruby/Sorbet
│       │       ├── telescope.lua # Disable (using snacks.picker)
│       │       ├── explorer.lua  # Enable snacks.explorer
│       │       ├── yanky.lua     # Not in LazyVim, add it
│       │       └── ...
└── scripts/
    └── bootstrap.sh              # Bootstrap helper
```

### Architecture Principles

**Vanilla Config:**
- Complete, standalone configuration
- Every plugin explicitly configured
- All LSPs managed via Nix packages
- Full control over all settings

**LazyVim Config:**
- Minimal override approach
- Leverages LazyVim's built-in configurations
- Only overrides what's necessary (LSP, explorer, custom plugins)
- Mason manages most LSPs automatically (except Ruby/Sorbet)

**Separation of Concerns:**
- Two independent flakes, two independent configs
- No shared state, no conflicts
- Choose at install time or switch anytime
- Both can be extended via overlay flakes (e.g., Shopify-specific tools)

## Customization

### Adding Packages

Edit `modules/base/packages.nix`:
```nix
home.packages = with pkgs; [
  # Add your packages here
  your-package-name
];
```

### Customizing Shell

Edit `modules/base/shell.nix`:
- Change oh-my-zsh theme
- Add more plugins
- Add custom aliases
- Modify shell initialization

### Switching Between Vanilla and LazyVim

**Locally:**
```bash
cd ~/Code/nix-home

# Switch to Vanilla
home-manager switch --impure --flake .#base-darwin

# Switch to Vanilla + personal Ruby
home-manager switch --impure --flake .#home-darwin

# Switch to LazyVim
home-manager switch --impure --flake ./lazyvim#base-darwin

# Switch to LazyVim + personal Ruby
home-manager switch --impure --flake ./lazyvim#home-darwin

# Changes take effect immediately (restart nvim)
```

**For overlay flakes** (like Shopify config):
```nix
# In ~/.config/your-work-config/flake.nix

# Use vanilla
inputs.nix-home.url = "github:ashwinp88/nix-home";

# Use LazyVim
inputs.nix-home.url = "github:ashwinp88/nix-home?dir=lazyvim";
```

### Customizing Neovim

**Vanilla:** Plugins are in `configs/neovim/lua/plugins/`. Each plugin is self-contained and can be:
- Modified directly
- Removed (just delete the file)
- Added (create new plugin file)

**LazyVim:** Only create override files in `configs/neovim-lazyvim/lua/plugins/` for:
- Plugins not in LazyVim (e.g., yanky.lua, gitlinker.lua)
- Specific settings to override (e.g., conform.lua for auto-format)
- Disabling built-ins (e.g., telescope.lua to use snacks.picker)
- LazyVim's built-ins handle most configuration automatically

**Colorscheme switching (both configs):**
Switch at runtime inside nvim - LazyVim persists your choice automatically:
```vim
:colorscheme catppuccin
:colorscheme tokyonight
:colorscheme gruvbox
```

### Customizing Tmux

Edit `modules/base/tmux.nix` for global settings, or `modules/os/darwin.nix` / `modules/os/linux.nix` for OS-specific tweaks.

## Extending This Configuration

This configuration is designed to be extended via Nix flake composition. See the "Extending" section below for how to create an overlay flake that adds language-specific tools while keeping this base clean.

### Example: Adding Language-Specific Tools (Overlay Flakes)

You can create a separate flake that references this one:

```nix
# In your work/project flake.nix
{
  inputs = {
    # Choose vanilla or LazyVim
    nix-home.url = "github:ashwinp88/nix-home";        # Vanilla
    # nix-home.url = "github:ashwinp88/nix-home?dir=lazyvim";  # LazyVim

    nixpkgs.follows = "nix-home/nixpkgs";
    home-manager.follows = "nix-home/home-manager";
  };

  outputs = { self, nix-home, home-manager, nixpkgs, ... }:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      homeConfigurations."work-darwin" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        modules = [
          # Import base modules from nix-home
          "${nix-home.outPath}/modules/base"           # For vanilla
          # "${nix-home.outPath}/modules/base-lazyvim" # For LazyVim
          "${nix-home.outPath}/modules/os/darwin.nix"

          # Add work-specific overlays
          ./modules/work-ruby.nix
          ./modules/work-dev.nix

          # Override settings
          {
            home = {
              username = "ashwin";
              homeDirectory = "/Users/ashwin";
              stateVersion = "24.05";
            };

            # Add Ruby LSP plugins (works with both vanilla and LazyVim)
            xdg.configFile."nvim/lua/plugins/ruby-lsp.lua".source = ./ruby-lsp.lua;
            xdg.configFile."nvim/lua/plugins/ruby-dap.lua".source = ./ruby-dap.lua;

            # Override git email for work
            programs.git.settings.user.email = lib.mkForce "work@company.com";

            programs.home-manager.enable = true;
          }
        ];

        extraSpecialArgs = { inherit system; };
      };
    };
}
```

**This pattern allows you to:**
- Keep your base configuration clean and portable
- Add work/project-specific tools in separate repositories
- Share the base configuration across multiple machines
- Maintain different environments (personal, work, etc.)
- Choose vanilla or LazyVim as the foundation
- Ruby/language-specific plugins work with both configurations

## Key Design Decisions

### Why Two Neovim Configurations?

**Choose Vanilla if you:**
- Want complete control over every plugin and setting
- Prefer explicit configuration you can read and understand
- Want all LSPs managed via Nix (reproducible)
- Like Neo-tree's multi-source explorer (files, buffers, git, symbols)
- Enjoy hand-crafting your editor configuration

**Choose LazyVim if you:**
- Want best-practice defaults out of the box
- Prefer less configuration maintenance
- Don't mind Mason managing LSP installations
- Want to stay current with LazyVim releases easily
- Like the simpler snacks.explorer
- Want to focus on coding, not configuring

**Both are production-ready** and fully supported. The architecture allows switching between them anytime.

### Why JDK and Node in Base?
These are fundamental development tools needed across many projects. Having them always available simplifies development setup.

### Why Separate OS Modules?
- **Fonts/Ghostty**: Only needed on macOS (headless Linux doesn't need them)
- **Clipboard transport**: Same tmux copy workflow, but terminals and hosts differ in OSC52 support
- **Docker**: Only needed on Linux for this setup

### Why Make Ruby Optional?
Ruby is a personal/workflow concern, not an OS concern. Keeping it as an opt-in module lets personal profiles enable `rbenv` without forcing Ruby onto shared base or work profiles built on top of this repo.

### Why No Language-Specific Plugins in Base?
Keeps the base lightweight and allows extension via separate flakes. For example, a Shopify-specific flake can add Ruby LSP, test runners, and debugging tools without cluttering the base.

## Tmux Keybindings

- **Prefix**: `Ctrl+b`
- **Split horizontal**: `Prefix + |`
- **Split vertical**: `Prefix + -`
- **Copy mode**: `Prefix + [`
- **Yank**: `y` (in copy mode, stays in copy mode and forwards via OSC52 when supported)
- **Paste**: `Prefix + ]`
- **Reload config**: `Prefix + r`

## Neovim Keybindings

See `configs/neovim/KEYBINDINGS.md` for complete keybinding documentation.

### Quick Reference
- **Leader key**: `Space`
- **Quit**: `<leader>qq` (quit all), `<leader>qw` (save and quit)
- **Git**: `<leader>g*` (branches, log, status, hunks)
- **Find**: `<leader>f*` (files, grep, recent)
- **LSP**: `<leader>l*` (info, rename, symbols)
- **Code**: `<leader>c*` (actions, format)
- **Buffers**: `<leader>b*` (list, delete)

## Troubleshooting

### Tmux Plugins Not Loading
```bash
# Manually install TPM
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Inside tmux, press: Ctrl+b then I
```

### Clipboard Not Reaching Your Local Machine Over SSH
- Confirm your terminal emulator supports OSC52 clipboard integration.
- Reconnect SSH after updating tmux so the client picks up the new settings.
- Verify tmux still copied the text into its own buffer with `Prefix + ]` even if system clipboard forwarding failed.

### Fonts Not Showing in Terminal
- Restart your terminal emulator after switching configurations
- For Ghostty, ensure it's installed: `brew list --cask ghostty`

### Homebrew Installation on macOS
```bash
# If Homebrew isn't auto-installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Reverting Changes
Since this is managed by Nix, you can always roll back:
```bash
# List previous generations
home-manager generations

# Rollback to previous generation
/nix/store/...-generation/activate
```

## Requirements

- **Nix**: Multi-user installation recommended
- **Home Manager**: Installed via flake (included in this config)
- **macOS**: Big Sur or later (for Apple Silicon: aarch64-darwin)
- **Linux**: x86_64 architecture, any modern distribution

## License

MIT License - Feel free to use, modify, and share.

## Author

**Ashwin Purushotaman**
- GitHub: [@ashwinp88](https://github.com/ashwinp88)
- Email: ashwin.p88@gmail.com

## Acknowledgments

- Built with [Nix](https://nixos.org/) and [Home Manager](https://github.com/nix-community/home-manager)
- Theme: [Catppuccin](https://github.com/catppuccin/catppuccin)
- Inspired by the Nix community's excellent dotfile configurations
