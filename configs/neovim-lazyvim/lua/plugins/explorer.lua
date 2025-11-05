-- File Explorer Configuration
-- Disable neo-tree, enable snacks.explorer

return {
  -- Disable neo-tree
  { "nvim-neo-tree/neo-tree.nvim", enabled = false },

  -- Configure snacks.nvim explorer (verified from actual docs)
  {
    "folke/snacks.nvim",
    opts = {
      explorer = {
        enabled = true,  -- Enable explorer feature
        follow = true,   -- Try top-level follow (you reported this worked)
      },
      picker = {
        sources = {
          explorer = {
            follow_file = true,  -- Automatically follow current buffer file
            watch = true,        -- Auto-refresh on file system changes
            tree = true,         -- Tree view formatting
            git_status = true,   -- Show git status indicators
            diagnostics = true,  -- Show diagnostics
          },
        },
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
          require("snacks").explorer()
        end,
        desc = "Focus file explorer",
      },
    },
  },
}
