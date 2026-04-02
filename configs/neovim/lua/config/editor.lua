-- Editor Settings and Behavior

-- Basic editor settings
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.laststatus = 3  -- Global statusline (stretches across all windows)

-- Auto-reload files when changed externally
vim.opt.autoread = true

-- Check for file changes on various events
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI", "TermClose" }, {
	callback = function()
		if vim.api.nvim_get_mode().mode ~= "c" then
			vim.cmd("checktime")
		end
	end,
})

-- Notify when file changes on disk
vim.api.nvim_create_autocmd("FileChangedShellPost", {
	callback = function(args)
		local filepath = vim.api.nvim_buf_get_name(args.buf)
		if filepath == "" then
			return
		end
		-- File was deleted (e.g. branch switch) — notify once and stop re-checking this buffer
		if vim.fn.filereadable(filepath) == 0 then
			vim.bo[args.buf].autoread = false
			local short = vim.fn.fnamemodify(filepath, ":~:.")
			vim.notify("File deleted from disk: " .. short, vim.log.levels.WARN)
			return
		end
		vim.notify("File changed on disk. Buffer reloaded.", vim.log.levels.INFO)
	end,
})

-- Clipboard settings
vim.opt.clipboard = "unnamedplus"  -- Use system clipboard

-- Limit recent files stored
vim.opt.shada = "'50,<50,s10,h"  -- Store max 50 files in oldfiles

-- Diagnostic configuration
vim.diagnostic.config({
	virtual_text = {
		spacing = 4,
		source = "if_many",
		prefix = "●",
		-- Show diagnostic message inline
		format = function(diagnostic)
			return string.format("%s", diagnostic.message)
		end,
	},
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = " ",
			[vim.diagnostic.severity.WARN] = " ",
			[vim.diagnostic.severity.HINT] = " ",
			[vim.diagnostic.severity.INFO] = " ",
		},
	},
	underline = true,     -- Underline problematic code
	update_in_insert = false,  -- Don't update diagnostics while typing
	severity_sort = true,  -- Sort by severity
	float = {
		border = "rounded",
		source = "always",  -- Show source of diagnostic (e.g., "rubocop")
		header = "",
		prefix = "",
	},
})

-- Folding settings (using treesitter)
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldcolumn = "1"       -- Show fold column
vim.opt.foldlevel = 99         -- Open all folds by default
vim.opt.foldlevelstart = 99    -- Open all folds when opening a file
vim.opt.foldenable = true      -- Enable folding
vim.opt.foldtext = ""          -- Use treesitter for fold text (neovim 0.10+)

-- Save file with Ctrl-S
vim.keymap.set({ "n", "i", "v" }, "<C-s>", "<cmd>write<cr>", { desc = "Save File" })