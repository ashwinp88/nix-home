-- Disable LazyVim's <leader>l binding to free it up for LSP submenu
-- Open Lazy via :Lazy command when needed

return {
  "folke/lazy.nvim",
  keys = {
    { "<leader>l", false },  -- Disable - frees up for LSP submenu
  },
}
