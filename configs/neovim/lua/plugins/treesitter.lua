return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter.config").setup({
      ensure_installed = {
        "lua",
        "vim",
        "vimdoc",
        "ruby",
        "javascript",
        "typescript",
        "python",
        "markdown",
        "markdown_inline",
      },
      auto_install = true,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      indent = {
        enable = true,
      },
      -- Note: Folding is built into Neovim 0.10+ with treesitter
      -- No need for a separate fold module
      ignore_install = { "python" },
    })
  end,
}
