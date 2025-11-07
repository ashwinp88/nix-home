return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main", -- Use the new rewrite (requires Neovim 0.11+)
  build = ":TSUpdate",
  lazy = false, -- Treesitter should not be lazy-loaded
  config = function()
    -- New nvim-treesitter API: only handles parser installation
    -- Highlighting, indent, folds are now built into Neovim

    -- Install parsers
    local ts = require("nvim-treesitter")
    ts.install({
      "lua",
      "vim",
      "vimdoc",
      "ruby",
      "javascript",
      "typescript",
      "python",
      "markdown",
      "markdown_inline",
    })

    -- Enable treesitter highlighting globally
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "lua", "vim", "ruby", "javascript", "typescript", "python", "markdown" },
      callback = function()
        vim.treesitter.start()
      end,
    })
  end,
}
