# Neovim Keybindings Reference

> **Leader key:** `<Space>`
>
> **Quick access:** Press `<Space>` and wait to see available keybindings via which-key
>
> **This document location:** `~/.config/nix-config/home/neovim/nvim/KEYBINDINGS.md`

## Table of Contents
- [General](#general)
- [File Operations](#file-operations)
- [Navigation](#navigation)
- [LSP (Language Server)](#lsp-language-server)
- [Search & Find](#search--find)
- [Git](#git)
- [Buffers](#buffers)
- [Testing (vim-test)](#testing-vim-test)
- [Debugging (DAP)](#debugging-dap)
- [Diagnostics & Trouble](#diagnostics--trouble)
- [UI Toggles](#ui-toggles)
- [Terminal](#terminal)
- [Code Actions](#code-actions)
- [Insert Mode](#insert-mode)
- [Visual Mode](#visual-mode)
- [Flash (Enhanced Motion)](#flash-enhanced-motion)
- [Yank/Paste (Yanky)](#yankpaste-yanky)
- [Scratch & Utility](#scratch--utility)

---

## General

| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `<C-s>` | n, i, v | Save file | Save current file |
| `<leader>qq` | n | `:qa` | Quit all |
| `<leader>qQ` | n | `:qa!` | Quit all without saving |
| `<leader>qw` | n | `:wqa` | Save all and quit |

---

## File Operations

| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `<leader>e` | n | Toggle Neo-tree | Toggle file explorer |
| `<leader>E` | n | Focus Neo-tree | Focus file explorer |
| `<leader><space>` | n | Smart find files | Smart file picker (git-aware) |
| `<leader>ff` | n | Find files | Find files in project |
| `<leader>fg` | n | Git files | Find git-tracked files |
| `<leader>fr` | n | Recent (project) | Recent files in current project |
| `<leader>fR` | n | Recent (global) | Recent files globally |
| `<leader>fc` | n | Find config | Find files in Neovim config |
| `<leader>fp` | n | Projects | Project picker |

---

## Navigation

### LSP Navigation

| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `gd` | n | Go to definition | Jump to definition (Sorbet) |
| `gr` | n | References | Find references (Sorbet) |
| `gD` | n | Go to declaration | Jump to declaration |
| `gI` | n | Go to implementation | Jump to implementation |
| `gy` | n | Go to type definition | Jump to type definition |
| `K` | n | Hover | Show hover documentation |
| `<C-k>` | n, i, v | Signature help | Show function signature |

### Buffer/Window Navigation

| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `<S-h>` | n | Previous buffer | Cycle to previous buffer |
| `<S-l>` | n | Next buffer | Cycle to next buffer |
| `[b` | n | Previous buffer | Cycle to previous buffer |
| `]b` | n | Next buffer | Cycle to next buffer |

### Code Structure

| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `<leader>a` | n | Aerial outline | Toggle aerial code outline |
| `{` | n | Aerial prev | Previous symbol in aerial |
| `}` | n | Aerial next | Next symbol in aerial |

### Word References

| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `]]` | n, t | Next reference | Jump to next word reference |
| `[[` | n, t | Prev reference | Jump to previous word reference |

---

## LSP (Language Server)

### Information

| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `<leader>li` | n | LSP Info | Show LSP server info |
| `<leader>lr` | n | LSP Restart | Restart LSP servers |
| `<leader>ls` | n | LSP Start | Start LSP servers |
| `<leader>lt` | n | LSP Stop | Stop LSP servers |
| `<leader>ll` | n | LSP Log | Open LSP log |

### Symbols

| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `<leader>ss` | n | LSP symbols | Buffer symbols picker |
| `<leader>sS` | n | Workspace symbols | Workspace symbols picker |

---

## Search & Find

### Content Search

| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `<leader>/` | n | Grep | Search in project files |
| `<leader>sg` | n | Grep | Search in project files |
| `<leader>sw` | n, x | Grep word/selection | Search current word or visual selection |
| `<leader>sb` | n | Buffer lines | Search lines in current buffer |
| `<leader>sB` | n | Grep buffers | Search in all open buffers |

### Pickers & Lists

| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `<leader>:` | n | Command history | Recent commands |
| `<leader>sc` | n | Command history | Recent commands |
| `<leader>s/` | n | Search history | Recent searches |
| `<leader>s"` | n | Registers | Register picker |
| `<leader>sk` | n | Keymaps | Keymap picker |
| `<leader>sh` | n | Help pages | Help documentation |
| `<leader>sm` | n | Marks | Jump marks |
| `<leader>sj` | n | Jumps | Jump list |
| `<leader>sl` | n | Location list | Location list picker |
| `<leader>sq` | n | Quickfix | Quickfix list picker |
| `<leader>sR` | n | Resume | Resume last picker |
| `<leader>su` | n | Undo history | Undo tree picker |

### Diagnostics

| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `<leader>sd` | n | Diagnostics | Project diagnostics |
| `<leader>sD` | n | Buffer diagnostics | Current buffer diagnostics |
| `[d` | n | Previous diagnostic | Jump to previous diagnostic |
| `]d` | n | Next diagnostic | Jump to next diagnostic |
| `<leader>cd` | n | Show diagnostic | Show diagnostic in float |
| `<leader>cl` | n | Diagnostics to loclist | Send diagnostics to location list |

### Meta

| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `<leader>sa` | n | Autocmds | Autocommands picker |
| `<leader>sC` | n | Commands | Available commands |
| `<leader>sH` | n | Highlights | Highlight groups |
| `<leader>si` | n | Icons | Icon picker |
| `<leader>sp` | n | Lazy plugins | Plugin specs |
| `<leader>sM` | n | Man pages | Man page picker |

---

## Git

### Git Operations

| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `<leader>gg` | n | Lazygit | Open lazygit |
| `<leader>ge` | n | Git explorer | Git status in neo-tree |
| `<leader>gB` | n | Git blame line | Show git blame for current line |

### Git Links (GitHub/GitLab)

| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `<leader>gy` | n, v | Copy git link | Copy GitHub link (current branch) |
| `<leader>gY` | n, v | Copy git link (main) | Copy GitHub link (default branch) |
| `<leader>go` | n, v | Open in browser | Open GitHub link in browser |
| `<leader>gO` | n, v | Open in browser (main) | Open GitHub link (default branch) |
| `<leader>gbb` | n, v | Copy blame link | Copy GitHub blame link |

### Git Pickers

| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `<leader>gb` | n | Git branches | Branch picker |
| `<leader>gl` | n | Git log | Commit log |
| `<leader>gL` | n | Git log line | Log for current line |
| `<leader>gs` | n | Git status | Changed files |
| `<leader>gS` | n | Git stash | Stash list |
| `<leader>gd` | n | Git diff | Diff hunks |
| `<leader>gf` | n | Git log file | File history |

### Git Hunks

| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `]h` | n | Next hunk | Jump to next git hunk |
| `[h` | n | Previous hunk | Jump to previous git hunk |
| `<leader>ghs` | n, v | Stage hunk | Stage git hunk |
| `<leader>ghr` | n, v | Reset hunk | Reset git hunk |
| `<leader>ghS` | n | Stage buffer | Stage entire buffer |
| `<leader>ghu` | n | Undo stage | Undo last stage |
| `<leader>ghR` | n | Reset buffer | Reset entire buffer |
| `<leader>ghp` | n | Preview hunk | Preview hunk diff |
| `<leader>ghb` | n | Blame line | Git blame current line |
| `<leader>ghd` | n | Diff this | Diff against index |
| `<leader>ghD` | n | Diff this ~ | Diff against last commit |

---

## Buffers

| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `<leader>bb` | n | Buffer picker | Pick from open buffers |
| `<leader>bd` | n | Delete buffer | Delete current buffer |
| `<leader>be` | n | Buffer explorer | Buffer list in neo-tree |
| `<leader>bp` | n | Pick to close | Pick buffer to close |
| `<leader>bo` | n | Close others | Close all other buffers |
| `<leader>fb` | n | Buffers | Buffer picker |

---

## Testing (vim-test)

| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `<leader>tt` | n | Run nearest test | Run test nearest to cursor |
| `<leader>tf` | n | Run current file | Run all tests in current file |
| `<leader>ts` | n | Run test suite | Run entire test suite |
| `<leader>tl` | n | Run last test | Re-run last test |
| `<leader>tv` | n | Visit test file | Open test file from implementation |

**Notes:**
- Tests run in a sticky terminal split at the bottom (reuses same terminal)
- Press `<C-w>q` in the terminal to close the split
- Uses default minitest executable (no custom wrapper)

---

## Debugging (DAP)

| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `<leader>db` | n | Toggle breakpoint | Set/remove breakpoint at current line |
| `<leader>dc` | n | Continue | Start/continue debugging |
| `<leader>di` | n | Step into | Step into function |
| `<leader>do` | n | Step over | Step over function |
| `<leader>dO` | n | Step out | Step out of function |
| `<leader>dr` | n | Toggle REPL | Open/close debug REPL |
| `<leader>dl` | n | Run last | Re-run last debug configuration |
| `<leader>du` | n | Toggle DAP UI | Show/hide debug UI |
| `<leader>dt` | n | Terminate | Stop debugging session |

**Notes:**
- DAP (Debug Adapter Protocol) is configured but not yet functional for test debugging
- Uses nvim-dap-ruby with default configuration
- DAP UI opens automatically when debugging starts

---

## Diagnostics & Trouble

| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `<leader>xx` | n | Toggle diagnostics | Toggle Trouble diagnostics window |
| `<leader>xw` | n | Buffer diagnostics | Trouble buffer diagnostics |
| `<leader>xl` | n | Toggle loclist | Toggle location list |
| `<leader>xq` | n | Toggle quickfix | Toggle quickfix list |

---

## UI Toggles

| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `<leader>z` | n | Zen mode | Toggle zen mode |
| `<leader>Z` | n | Zoom | Toggle window zoom |
| `<leader>uC` | n | Colorschemes | Colorscheme picker |
| `<leader>un` | n | Dismiss notifications | Hide all notifications |
| `<leader>us` | n | Toggle spelling | Toggle spell check |
| `<leader>uw` | n | Toggle wrap | Toggle line wrap |
| `<leader>uL` | n | Toggle relative number | Toggle relative line numbers |
| `<leader>ud` | n | Toggle diagnostics | Toggle diagnostic display |
| `<leader>ul` | n | Toggle line numbers | Toggle line numbers |
| `<leader>uc` | n | Toggle conceal | Toggle conceal level |
| `<leader>uT` | n | Toggle treesitter | Toggle treesitter |
| `<leader>ub` | n | Toggle background | Toggle dark/light background |
| `<leader>uh` | n | Toggle inlay hints | Toggle LSP inlay hints |
| `<leader>ug` | n | Toggle indent guides | Toggle indent guides |
| `<leader>uD` | n | Toggle dim | Toggle inactive window dimming |

---

## Terminal

| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `<c-/>` | n | Toggle terminal | Open/close terminal |
| `<c-_>` | n | Toggle terminal | Open/close terminal (alternative) |

---

## Code Actions

| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `<leader>ca` | n, v | Code action | Show code actions |
| `<leader>cf` | n, v | Format | Format code with LSP |
| `<leader>cR` | n | Rename | Rename symbol (LSP) |

---

## Insert Mode

### General

| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `<C-s>` | i | Save file | Save current file |

### Completion (nvim-cmp)

| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `<C-Space>` | i | Trigger completion | Manually trigger completion menu |
| `<CR>` | i | Confirm | Confirm completion selection |
| `<Tab>` | i, s | Next item | Select next completion item / expand snippet |
| `<S-Tab>` | i, s | Previous item | Select previous completion item / jump back in snippet |
| `<C-b>` | i | Scroll docs up | Scroll completion documentation up |
| `<C-f>` | i | Scroll docs down | Scroll completion documentation down |
| `<C-e>` | i | Abort | Close completion menu |

---

## Visual Mode

| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `<C-s>` | v | Save file | Save current file |
| `<leader>ca` | v | Code action | Code actions for selection |
| `<leader>cf` | v | Format | Format selected code |
| `<leader>sw` | x | Grep selection | Search for visual selection |
| `<leader>ghs` | v | Stage hunk | Stage selected git hunk |
| `<leader>ghr` | v | Reset hunk | Reset selected git hunk |
| `y` | x | Yank | Enhanced yank with history |
| `p` | x | Put after | Put yanked text after cursor |
| `P` | x | Put before | Put yanked text before cursor |
| `gp` | x | Put after selection | Put yanked text after selection |
| `gP` | x | Put before selection | Put yanked text before selection |

---

## Flash (Enhanced Motion)

| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `s` | n, x, o | Flash jump | Jump to any location with labels |
| `S` | n, x, o | Flash treesitter | Jump to treesitter nodes |
| `r` | o | Remote flash | Remote operations with flash |
| `R` | o, x | Treesitter search | Search treesitter nodes |
| `<c-s>` | c | Toggle flash search | Toggle flash search in command mode |

---

## Yank/Paste (Yanky)

| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `y` | n, x | Yank | Yank with history tracking |
| `Y` | n | Yank to EOL | Yank to end of line |
| `p` | n, x | Put after | Put yanked text after cursor |
| `P` | n, x | Put before | Put yanked text before cursor |
| `gp` | n, x | Put after | Put text after with cursor adjustment |
| `gP` | n, x | Put before | Put text before with cursor adjustment |
| `[y` | n | Cycle forward | Cycle forward through yank history |
| `]y` | n | Cycle backward | Cycle backward through yank history |
| `<leader>p` | n | Yank history | Open yank history picker |

---

## Scratch & Utility

| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `<leader>.` | n | Scratch buffer | Toggle scratch buffer |
| `<leader>,` | n | Select scratch | Select scratch buffer from list |
| `<leader>;` | n | Copy relative path | Copy relative path of current buffer |
| `<leader>'` | n | Copy full path | Copy full path of current buffer |
| `<leader>n` | n | Notification history | Show notification history |
| `<leader>N` | n | Neovim news | Show Neovim news |

---

## Tips & Notes

### LSP Configuration
- **Sorbet handles navigation** (references, definitions) when available
- **Ruby LSP handles** formatting, diagnostics, completion, hover
- Both servers run simultaneously with capability routing for optimal performance

### Plugin Highlights
- **Flash.nvim** - Enhanced f/F/t/T motions with labels (press `s` to jump anywhere)
- **Which-key** - Shows available bindings after pressing leader key
- **Snacks.nvim** - Powers most pickers, notifications, and UI elements
- **Yanky.nvim** - Enhanced yank/paste with history (press `<leader>p` for history)
- **Neo-tree** - File explorer with git integration
- **Gitsigns** - Git diff/hunk operations inline
- **vim-test** - Test runner with minitest support (runs in sticky terminal)
- **nvim-dap** - Debug Adapter Protocol for debugging (configured, not yet functional)
- **Gitlinker** - Generate GitHub/GitLab permalinks

### Quick Workflows

**Finding Files:**
1. `<leader><space>` - Smart find (git-aware)
2. `<leader>ff` - Find all files
3. `<leader>fr` - Recent files in project

**Searching Content:**
1. `<leader>/` or `<leader>sg` - Grep in project
2. `<leader>sw` - Search word under cursor
3. `<leader>sb` - Search lines in current buffer

**LSP Navigation:**
1. `gd` - Go to definition
2. `gr` - Find all references
3. `K` - Show documentation
4. `<leader>ca` - Code actions

**Git Operations:**
1. `<leader>gg` - Open Lazygit
2. `<leader>ghs` - Stage hunk
3. `<leader>ghr` - Reset hunk
4. `]h` / `[h` - Jump between hunks
5. `<leader>gy` - Copy GitHub link (current branch)
6. `<leader>gY` - Copy GitHub link (main/master)

**Buffer Management:**
1. `<S-h>` / `<S-l>` - Cycle buffers
2. `<leader>bb` - Buffer picker
3. `<leader>bd` - Delete buffer

**Testing (vim-test):**
1. `<leader>tt` - Run test at cursor
2. `<leader>tf` - Run all tests in file
3. `<leader>tl` - Re-run last test
4. `<leader>tv` - Visit test file from implementation
5. `<C-w>q` - Close test terminal split

### Mode Indicators
- `n` = Normal mode
- `i` = Insert mode
- `v` = Visual mode
- `x` = Visual mode (character-wise)
- `o` = Operator-pending mode
- `c` = Command-line mode
- `s` = Select mode
- `t` = Terminal mode
