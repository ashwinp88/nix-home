# Personal Nix Home Manager Configuration

A modular, portable Nix configuration for development environments across macOS and Linux.

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
- **Plugins**: catppuccin, tmux-cpu, tmux-yank

### Neovim Configuration
- **Base plugins**: LSP, treesitter, completion, git integration, file navigation
- **UI**: Catppuccin theme, lualine, bufferline, which-key
- **Keybindings**: Organized by function (`<leader>g` for git, `<leader>f` for find, etc.)
- **Extensible**: Designed to be extended with language-specific plugins

### Platform-Specific

#### macOS
- **Fonts**: FiraCode Nerd Font, JetBrainsMono Nerd Font
- **Terminal**: Ghostty with FiraCode and Catppuccin theme
- **Clipboard**: tmux integration with pbcopy
- **Homebrew**: Environment setup and optional installation

#### Linux (Headless)
- **Docker**: Docker Engine included
- **Clipboard**: tmux buffer-only (no GUI dependencies)
- **No fonts**: Optimized for headless servers

## Quick Start

### Installation

```bash
# Install via one-liner (installs Nix if needed and runs the bootstrap helper)
curl -L https://raw.githubusercontent.com/ashwinp88/nix-home/main/install.sh | bash

# Or clone manually
git clone https://github.com/ashwinp88/nix-home.git ~/Code/nix-home
cd ~/Code/nix-home

# Install Nix (multi-user) from https://nixos.org/download.html first if you
# skip the one-liner. Then run the bootstrap helper; it detects the OS
# automatically and enables flakes/nix-command before invoking Home Manager.

./scripts/bootstrap.sh                 # auto-detects macOS/Linux
./scripts/bootstrap.sh --prepare-only  # just build (no switch)
./scripts/bootstrap.sh --base          # apply base modules only
./scripts/bootstrap.sh --home /custom/home   # override HOME if needed
# Existing ~/.zshrc is saved to ~/.zshrc.pre-nix-home and sourced from ~/.config/zsh/local.zsh
./scripts/bootstrap.sh --home /custom/home   # override HOME if needed

# Use --darwin/--linux to override detection and pass extra flags after --, e.g.
./scripts/bootstrap.sh -- --show-trace
```

### First-Time Setup

For tmux plugins to work:
```bash
# Start tmux (it will auto-install TPM)
tmux

# Inside tmux, install plugins
# Press: Ctrl+s then I (capital i)
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
- Tmux with pbcopy integration
- Neovim with base plugins
- FiraCode and JetBrainsMono Nerd Fonts
- Ghostty terminal emulator
- Homebrew environment setup
- Oh-my-zsh with custom configuration

### `base-linux` (Headless Linux)
Optimized configuration for headless Linux servers.

**Includes:**
- All core tools (JDK, Node.js, development CLI tools)
- Tmux with buffer-only clipboard
- Neovim with base plugins
- Docker Engine
- Oh-my-zsh with custom configuration
- No fonts, no Ghostty (headless)

## Directory Structure

```
nix-home/
├── flake.nix                     # Main flake definition
├── flake.lock                    # Locked dependencies
├── modules/
│   ├── base/                     # OS-agnostic base modules
│   │   ├── default.nix           # Imports all base modules
│   │   ├── packages.nix          # Core packages (JDK, Node, tools)
│   │   ├── tmux.nix              # Tmux configuration (OS-agnostic)
│   │   ├── neovim.nix            # Neovim setup
│   │   ├── shell.nix             # Zsh, oh-my-zsh, custom config
│   │   └── git.nix               # Git configuration
│   └── os/                       # OS-specific modules
│       ├── darwin.nix            # macOS: fonts, Ghostty, clipboard
│       └── linux.nix             # Linux: Docker, tmux buffer clipboard
└── configs/
    └── neovim/                   # Neovim Lua configuration
        ├── init.lua              # Bootstrap lazy.nvim
        ├── lua/
        │   ├── config/           # Editor settings, keymaps
        │   └── plugins/          # Base plugins (no language-specific)
        └── commands/             # Custom commands
```

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

### Customizing Neovim

Base Neovim plugins are in `configs/neovim/lua/plugins/`. Each plugin is self-contained and can be:
- Modified directly
- Removed (just delete the file)
- Added (create new plugin file)

### Customizing Tmux

Edit `modules/base/tmux.nix` for global settings, or `modules/os/darwin.nix` / `modules/os/linux.nix` for OS-specific tweaks.

## Extending This Configuration

This configuration is designed to be extended via Nix flake composition. See the "Extending" section below for how to create an overlay flake that adds language-specific tools while keeping this base clean.

### Example: Adding Language-Specific Tools

You can create a separate flake that references this one:

```nix
# In your work/project flake.nix
{
  inputs = {
    nix-home.url = "github:ashwinp88/nix-home";
    nixpkgs.follows = "nix-home/nixpkgs";
    home-manager.follows = "nix-home/home-manager";
  };

  outputs = { self, nix-home, home-manager, ... }: {
    homeConfigurations.work-env =
      home-manager.lib.homeManagerConfiguration {
        pkgs = nix-home.inputs.nixpkgs.legacyPackages.aarch64-darwin;
        modules = [
          nix-home.homeConfigurations.base-darwin.config
          {
            # Add language-specific Neovim plugins
            xdg.configFile."nvim/lua/plugins/ruby-lsp.lua".source = ./ruby-lsp.lua;

            # Override git email for work
            programs.git.userEmail = lib.mkForce "work@company.com";

            # Add work-specific environment
            programs.zsh.initContent = lib.mkAfter ''
              [ -f /opt/work/setup.sh ] && source /opt/work/setup.sh
            '';
          }
        ];
      };
  };
}
```

This pattern allows you to:
- Keep your base configuration clean and portable
- Add work/project-specific tools in separate repositories
- Share the base configuration across multiple machines
- Maintain different environments (personal, work, etc.)

## Key Design Decisions

### Why JDK and Node in Base?
These are fundamental development tools needed across many projects. Having them always available simplifies development setup.

### Why Separate OS Modules?
- **Fonts/Ghostty**: Only needed on macOS (headless Linux doesn't need them)
- **Clipboard**: Different mechanisms (pbcopy vs tmux buffer)
- **Docker**: Only needed on Linux for this setup

### Why No Language-Specific Plugins in Base?
Keeps the base lightweight and allows extension via separate flakes. For example, a Shopify-specific flake can add Ruby LSP, test runners, and debugging tools without cluttering the base.

## Tmux Keybindings

- **Prefix**: `Ctrl+s` (instead of default `Ctrl+b`)
- **Split horizontal**: `Prefix + |`
- **Split vertical**: `Prefix + -`
- **Copy mode**: `Prefix + [`
- **Yank**: `y` (in copy mode, stays in copy mode)
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

# Inside tmux, press: Ctrl+s then I
```

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