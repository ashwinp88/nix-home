-- Bufferline configuration override

return {
  "akinsho/bufferline.nvim",
  opts = {
    options = {
      mode = "buffers",
      separator_style = "slant",  -- Custom separator style
      always_show_bufferline = true,
      diagnostics = "nvim_lsp",
      offsets = {
        {
          filetype = "snacks_picker_list",  -- snacks.explorer uses picker infrastructure
          text = "Explorer",
          text_align = "center",
          separator = true,
        },
      },
      left_trunc_marker = "",
      right_trunc_marker = "",
    },
  },
  keys = {
    -- Buffer navigation keymaps (LazyVim compatible)
    { "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev buffer" },
    { "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer" },
    { "[b", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev buffer" },
    { "]b", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer" },
    { "<leader>bp", "<cmd>BufferLinePickClose<cr>", desc = "Pick buffer to close" },
    { "<leader>bo", "<cmd>BufferLineCloseOthers<cr>", desc = "Close other buffers" },
  },
}
