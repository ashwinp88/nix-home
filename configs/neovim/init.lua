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

-- Setup lazy.nvim with reproducible lockfile
-- Nix provides a read-only reference lockfile, we copy it to a writable location
local config_dir = vim.fn.stdpath("config")
local data_dir = vim.fn.stdpath("data")
local nix_lockfile = config_dir .. "/lazy-lock.nix.json"  -- Nix-managed reference
local lockfile = data_dir .. "/lazy-lock.json"  -- Writable copy

-- Copy nix lockfile to writable location if it exists and local one doesn't
if vim.fn.filereadable(nix_lockfile) == 1 and vim.fn.filereadable(lockfile) == 0 then
  vim.fn.system({ "cp", nix_lockfile, lockfile })
  vim.fn.system({ "chmod", "644", lockfile })
end

require("lazy").setup("plugins", {
  lockfile = lockfile,
  install = { missing = true },
})

-- Clear old recent files on startup (optional)
-- vim.cmd("silent! :oldfiles | only")
