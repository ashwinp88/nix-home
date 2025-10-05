return {
  "folke/trouble.nvim",
  cmd = { "Trouble" },
  keys = {
    { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Toggle Diagnostics (Trouble)" },
    { "<leader>xw", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)" },
    { "<leader>xl", "<cmd>Trouble loclist toggle<cr>", desc = "Toggle Loclist (Trouble)" },
    { "<leader>xq", "<cmd>Trouble qflist toggle<cr>", desc = "Toggle Quickfix (Trouble)" },
  },
  opts = {},
}
