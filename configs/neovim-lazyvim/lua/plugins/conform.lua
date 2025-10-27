-- Conform.nvim configuration override
-- Enable format_on_save

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
    format_on_save = { timeout_ms = 500, lsp_fallback = true },
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
