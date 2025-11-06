return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    -- Try the newer module name first (config without 's')
    local ok, config = pcall(require, "nvim-treesitter.config")
    if not ok then
      -- Fall back to older module name (configs with 's')
      ok, config = pcall(require, "nvim-treesitter.configs")
      if not ok then
        vim.notify("nvim-treesitter not available", vim.log.levels.WARN)
        return
      end
    end

    config.setup({
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
      fold = {
        enable = true,
      },
      ignore_install = { "python" },
      modules = {},
    })
  end,
}
