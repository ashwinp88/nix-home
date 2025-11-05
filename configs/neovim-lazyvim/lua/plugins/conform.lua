-- Conform.nvim configuration override
-- LazyVim handles format-on-save automatically, we just configure formatters

return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      python = { "isort", "black" },
      javascript = { "prettier" },
      typescript = { "prettier" },
      javascriptreact = { "prettier" },
      typescriptreact = { "prettier" },
      css = { "prettier" },
      html = { "prettier" },
      json = { "prettier" },
      yaml = { "prettier" },
      markdown = { "prettier" },
      -- Ruby formatter will be added by ruby-conform.lua when Ruby module is active
    },
    -- Don't set format_on_save - LazyVim handles it automatically
  },
  keys = {
    {
      "<leader>cF",
      function()
        require("conform").format({ async = true, lsp_fallback = true })
      end,
      mode = "",
      desc = "Format buffer (conform)",
    },
  },
}
