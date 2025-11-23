return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main", -- Use the new rewrite (requires Neovim 0.11+)
  build = ":TSUpdate",
  lazy = false, -- Treesitter should not be lazy-loaded
  opts = {
    -- Parsers that every profile should have; overlays can extend this list
    ensure_installed = {
      "lua",
      "vim",
      "vimdoc",
      "javascript",
      "typescript",
      "yaml",
      "python",
      "markdown",
      "markdown_inline",
    },
  },
  config = function(_, opts)
    -- New API exposes the installer separately from the highlight integration
    local installer = require("nvim-treesitter.install")
    installer.ensure_installed(opts.ensure_installed or {})

    -- Enable treesitter highlighting globally for shared languages
    vim.api.nvim_create_autocmd("FileType", {
      pattern = opts.ensure_installed,
      callback = function()
        pcall(vim.treesitter.start)
      end,
    })
  end,
}
