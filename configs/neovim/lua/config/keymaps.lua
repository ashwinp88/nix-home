-- General keymaps that don't belong to specific plugins

-- Clear search highlighting with ESC
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights", silent = true })

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
