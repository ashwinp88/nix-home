return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 300  -- Keep default timeout for key sequences
  end,
  config = function()
    local wk = require("which-key")
    wk.setup({
      delay = 1000,  -- 1 second delay before showing which-key popup
      preset = "classic",
      win = {
        no_overlap = true,
        width = 40,
        height = { min = 4, max = 0.9 },
        col = -1,
        row = -1,
        border = "single",
        padding = { 1, 2 },
        title = true,
        title_pos = "center",
      },
      layout = {
        width = { min = 20, max = 40 },
        spacing = 3,
      },
    })
    -- Add key group names
    wk.add({
      { "<leader>l", group = "lsp" },
      { "<leader>g", group = "git" },
      { "<leader>gh", group = "hunks" },
      { "<leader>gt", group = "git toggles" },
      -- test and debug groups removed - added by Ruby plugins when active
      { "<leader>q", group = "quit" },
      { "<leader>b", group = "buffers" },
      { "<leader>c", group = "code" },
      { "<leader>f", group = "find" },
      { "<leader>s", group = "search" },
      { "<leader>u", group = "ui toggles" },
      { "<leader>x", group = "trouble" },
      { "<leader>m", group = "markdown" },
    })
  end,
}