return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    local ok, configs = pcall(require, "nvim-treesitter.configs")
    if not ok then
      vim.notify("nvim-treesitter not available", vim.log.levels.WARN)
      return
    end

    configs.setup({
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
      },
      indent = {
        enable = true,
      },
    })
  end,
}
