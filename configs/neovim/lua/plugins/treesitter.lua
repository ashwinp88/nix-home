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

    -- Install parsers using new API
    require("nvim-treesitter").install(parsers)

    -- Enable treesitter highlighting for these filetypes
    vim.api.nvim_create_autocmd("FileType", {
      pattern = parsers,
      callback = function()
        pcall(vim.treesitter.start)
      end,
    })
  end,
}
