-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Leader key
vim.g.mapleader = " "

-- Quit keybindings
vim.keymap.set("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all" })
vim.keymap.set("n", "<leader>qQ", "<cmd>qa!<cr>", { desc = "Quit all without saving" })
vim.keymap.set("n", "<leader>qw", "<cmd>wqa<cr>", { desc = "Save all and quit" })

-- Auto-load all config files from lua/config/
local config_path = vim.fn.stdpath("config") .. "/lua/config"
if vim.fn.isdirectory(config_path) == 1 then
	for _, file in ipairs(vim.fn.readdir(config_path)) do
		if file:match("%.lua$") then
			require("config." .. file:gsub("%.lua$", ""))
		end
	end
end

-- Setup lazy.nvim - load all plugin files from lua/plugins/
require("lazy").setup("plugins")

-- Clear old recent files on startup (optional)
-- vim.cmd("silent! :oldfiles | only")
