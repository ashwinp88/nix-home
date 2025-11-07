# Enhanced Grep

A powerful NeoVim search plugin with a tree-style folding interface, flexible pattern filtering, and preset management. Built on top of ripgrep for blazing-fast searches.

## Features

- **Folding Tree View**: Results organized by file with collapsible sections
- **Flexible Filtering**: Unified include/exclude patterns supporting wildcards and paths
- **Smart Presets**: Built-in presets for common languages and scenarios
- **Interactive UI**: Checkbox controls and editable filter fields
- **State Persistence**: Remembers your last search and filter preferences
- **Search History**: Quick access to previous searches
- **Quickfix Integration**: Export results to quickfix list
- **Keyboard-Driven**: Efficient navigation and interaction

## Installation

Already installed in your config at `configs/neovim/lua/plugins/enhanced-grep.lua`

## Usage

### Commands

- `:EnhancedGrep [pattern]` - Start enhanced grep search
- `:EnhancedGrepNoTests [pattern]` - Search excluding test files
- `:EnhancedGrepPreset <preset> [pattern]` - Search with a preset

### Keybindings

- `<leader>sE` - Enhanced Grep (interactive)
- `<leader>sT` - Enhanced Grep (No Tests)
- `<leader>sP` - Enhanced Grep (Preset selector)
- `<leader>sW` - Grep word under cursor
- `<leader>s<leader>` - Repeat last search

### Results Window Keybindings

- `<CR>` - Jump to match under cursor
- `<Tab>` / `za` - Toggle fold
- `zR` - Expand all folds
- `zM` - Collapse all folds
- `<C-q>` - Send results to quickfix list
- `q` / `<Esc>` - Close results window

## Pattern Syntax

### Include Patterns

Specify which files to search in:

```
*.rb                    # All Ruby files
*.{js,ts}              # JavaScript and TypeScript files
lib/**/*.py            # Python files in lib/ recursively
config/*               # Files in config/ directory
Gemfile Rakefile       # Specific files
```

### Exclude Patterns

Specify which files to skip:

```
/test/*                # All files in test directory
/spec/*                # All files in spec directory
*_test.*               # Files ending with _test
*_spec.*               # Files ending with _spec
/vendor/*              # Vendor directory
*.min.js               # Minified JavaScript
```

### Wildcard Patterns

- `*` - Matches any characters except path separators
- `**` - Matches any characters including path separators (recursive)
- `?` - Matches exactly one character
- `{a,b}` - Matches either pattern a or b
- `/path/*` - Path-based pattern (from project root)

## Built-in Presets

### All
Search all files without restrictions.

### Ruby
- **Include**: `*.rb`, `*.rake`, `Gemfile`, `Rakefile`, `*.gemspec`
- **Exclude**: `*_test.rb`, `*_spec.rb`, `/test/*`, `/spec/*`, `/vendor/*`

### Python
- **Include**: `*.py`, `*.pyi`, `requirements.txt`, `setup.py`
- **Exclude**: `test_*.py`, `*_test.py`, `/tests/*`, `__pycache__/*`, `/venv/*`

### JavaScript/TypeScript
- **Include**: `*.js`, `*.jsx`, `*.ts`, `*.tsx`, `package.json`
- **Exclude**: `*.min.js`, `/node_modules/*`, `/dist/*`, `/build/*`

### Go
- **Include**: `*.go`, `go.mod`, `go.sum`
- **Exclude**: `*_test.go`, `/vendor/*`, `/testdata/*`

### Lua
- **Include**: `*.lua`
- **Exclude**: `/plugin/*`, `/.deps/*`

### No Tests
- **Exclude**: `/test/*`, `/tests/*`, `/spec/*`, `*_test.*`, `*_spec.*`, `test_*.*`

### No Dependencies
- **Exclude**: `/vendor/*`, `/node_modules/*`, `/deps/*`, `/target/*`, `/venv/*`, `/build/*`, `/dist/*`

## Examples

### Basic Search
```vim
" Interactive search
:EnhancedGrep

" Direct search
:EnhancedGrep last_active_was_trial
```

### Search with Patterns
When prompted:
- **Pattern**: `last_active_was_trial`
- **Include**: `*.rb *.rake`
- **Exclude**: `/test/* /spec/* *_test.rb`

### Search with Preset
```vim
" Ruby files only
:EnhancedGrepPreset ruby function_name

" No tests
:EnhancedGrepNoTests important_method
```

### Grep Word Under Cursor
```vim
" Place cursor on word, press:
<leader>sW
```

## Configuration

The plugin is configured in `lua/plugins/enhanced-grep.lua`:

```lua
require("enhanced-grep").setup({
  defaults = {
    ignore_tests = true,
    use_gitignore = true,
    case_sensitive = false,
    fold_by_default = false,
    include = {},
    exclude = {"/test/*", "/spec/*", "*_test.*", "*_spec.*"},
  },
  window = {
    width = 0.8,  -- 80% of screen width
    height = 0.8, -- 80% of screen height
  },
})
```

## State Persistence

The plugin automatically saves:
- Last search pattern
- Last include/exclude patterns
- Fold states for each file
- Search history (last 50 searches)

State is stored in: `~/.local/share/nvim/enhanced-grep-state.json`

## Tips

1. **Quick Filtering**: Press `<leader>sT` for instant no-test searches
2. **Fold Management**: Use `zR` to expand all, `zM` to collapse all
3. **Quickfix Export**: Use `<C-q>` to send results to quickfix for further manipulation
4. **Preset Selector**: `<leader>sP` shows a menu of all available presets
5. **Repeat Searches**: `<leader>s<leader>` repeats your last search

## Troubleshooting

### No Results Found
- Check your include/exclude patterns
- Try with preset "All" to see all matches
- Verify ripgrep is installed: `:!rg --version`

### Ripgrep Not Found
The plugin requires `ripgrep` to be installed. It's included in your Nix config at `modules/base/neovim.nix`.

### Slow Searches
- Use more specific include patterns to reduce search scope
- Add common exclusions like `/node_modules/*`, `/vendor/*`
- Consider searching from a subdirectory instead of project root

## Technical Details

### Module Structure
```
enhanced-grep/
├── init.lua       # Main entry point & API
├── ripgrep.lua    # Ripgrep wrapper & execution
├── patterns.lua   # Pattern parsing & conversion
├── presets.lua    # Preset management
├── state.lua      # State persistence
└── ui.lua         # UI rendering & interaction
```

### Ripgrep Integration
The plugin uses ripgrep's `--json` output format for structured parsing and converts patterns to ripgrep's `--glob` syntax for efficient filtering.

## License

Part of your personal NeoVim configuration.
