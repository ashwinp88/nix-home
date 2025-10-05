return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  keys = {
    -- Git toggles (avoid conflicts with snacks.nvim)
    { "<leader>gtb", "<cmd>Gitsigns toggle_current_line_blame<cr>", desc = "Toggle git blame" },
    { "<leader>gtd", "<cmd>Gitsigns toggle_deleted<cr>", desc = "Toggle git deleted" },

    -- Hunk operations under <leader>gh
    { "<leader>ghs", "<cmd>Gitsigns stage_hunk<cr>", desc = "Stage hunk", mode = { "n", "v" } },
    { "<leader>ghr", "<cmd>Gitsigns reset_hunk<cr>", desc = "Reset hunk", mode = { "n", "v" } },
    { "<leader>ghS", "<cmd>Gitsigns stage_buffer<cr>", desc = "Stage buffer" },
    { "<leader>ghu", "<cmd>Gitsigns undo_stage_hunk<cr>", desc = "Undo stage hunk" },
    { "<leader>ghR", "<cmd>Gitsigns reset_buffer<cr>", desc = "Reset buffer" },
    { "<leader>ghp", "<cmd>Gitsigns preview_hunk<cr>", desc = "Preview hunk" },
    { "<leader>ghb", function() require('gitsigns').blame_line{full=true} end, desc = "Blame line (full)" },
    { "<leader>ghd", "<cmd>Gitsigns diffthis<cr>", desc = "Diff this" },
    { "<leader>ghD", function() require('gitsigns').diffthis('~') end, desc = "Diff this ~" },

    -- Navigation
    { "]h", "<cmd>Gitsigns next_hunk<cr>", desc = "Next hunk" },
    { "[h", "<cmd>Gitsigns prev_hunk<cr>", desc = "Prev hunk" },
  },
  opts = {
    signs = {
      add = { text = "▎" },
      change = { text = "▎" },
      delete = { text = "" },
      topdelete = { text = "" },
      changedelete = { text = "▎" },
    },
  },
}