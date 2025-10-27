-- File Explorer Configuration
-- Disable neo-tree, enable snacks.explorer

return {
  -- Disable neo-tree
  { "nvim-neo-tree/neo-tree.nvim", enabled = false },

  -- Configure snacks.nvim to enable explorer
  {
    "folke/snacks.nvim",
    opts = {
      explorer = {
        enabled = true,
        focus_on_open = true,  -- Focus when opening
        follow = true,         -- Highlight currently open file
      },
    },
    keys = {
      {
        "<leader>e",
        function()
          require("snacks").explorer()
        end,
        desc = "Toggle file explorer",
      },
      {
        "<leader>E",
        function()
          require("snacks").explorer({ focus = true })
        end,
        desc = "Focus file explorer",
      },
    },
  },
}
