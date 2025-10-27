-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua

-- Custom editor settings (ported from custom config)

-- Folding settings (using treesitter)
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldcolumn = "1"       -- Show fold column
vim.opt.foldlevel = 99         -- Open all folds by default
vim.opt.foldlevelstart = 99    -- Open all folds when opening a file
vim.opt.foldenable = true      -- Enable folding
vim.opt.foldtext = ""          -- Use treesitter for fold text (neovim 0.10+)

-- Auto-reload files when changed externally
vim.opt.autoread = true

-- Limit recent files stored
vim.opt.shada = "'50,<50,s10,h"  -- Store max 50 files in oldfiles

-- LazyVim already sets these, but including for clarity:
-- vim.opt.number = true
-- vim.opt.relativenumber = true
-- vim.opt.expandtab = true
-- vim.opt.shiftwidth = 2
-- vim.opt.tabstop = 2
-- vim.opt.smartindent = true
-- vim.opt.wrap = false
-- vim.opt.termguicolors = true
-- vim.opt.scrolloff = 8
-- vim.opt.signcolumn = "yes"
-- vim.opt.clipboard = "unnamedplus"

-- Diagnostic configuration (enhanced version)
vim.diagnostic.config({
  virtual_text = {
    spacing = 4,
    source = "if_many",
    prefix = "●",
    format = function(diagnostic)
      return string.format("%s", diagnostic.message)
    end,
  },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = " ",
      [vim.diagnostic.severity.WARN] = " ",
      [vim.diagnostic.severity.HINT] = " ",
      [vim.diagnostic.severity.INFO] = " ",
    },
  },
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = "rounded",
    source = "always",
    header = "",
    prefix = "",
  },
})
