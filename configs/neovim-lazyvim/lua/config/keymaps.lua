-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

-- Custom keymaps (ported from custom config)

-- Copy relative path of current buffer
vim.keymap.set("n", "<leader>;", function()
  local path = vim.fn.expand("%:.")
  vim.fn.setreg("+", path)
  vim.notify("Copied relative path: " .. path, vim.log.levels.INFO)
end, { desc = "Copy relative path", nowait = true })

-- Copy full path of current buffer
vim.keymap.set("n", "<leader>'", function()
  local path = vim.fn.expand("%:p")
  vim.fn.setreg("+", path)
  vim.notify("Copied full path: " .. path, vim.log.levels.INFO)
end, { desc = "Copy full path", nowait = true })

-- Save file with Ctrl-S
vim.keymap.set({ "n", "i", "v" }, "<C-s>", "<cmd>write<cr>", { desc = "Save File" })

-- Quit keybindings
vim.keymap.set("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all" })
vim.keymap.set("n", "<leader>qQ", "<cmd>qa!<cr>", { desc = "Quit all without saving" })
vim.keymap.set("n", "<leader>qw", "<cmd>wqa<cr>", { desc = "Save all and quit" })
