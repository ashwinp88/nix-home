return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main", -- Use the new rewrite (requires Neovim 0.11+)
  build = ":TSUpdate",
  lazy = false, -- Treesitter should not be lazy-loaded
  config = function()
    local parsers = {
      "lua",
      "vim",
      "vimdoc",
      "javascript",
      "typescript",
      "yaml",
      "python",
      "markdown",
      "markdown_inline",
    }

    -- Configure the official Treesitter modules instead of calling a non-existent API
    require("nvim-treesitter.configs").setup {
      ensure_installed = parsers,
      auto_install = false,
      highlight = { enable = true },
      indent = { enable = true },
    }
  end,
}
