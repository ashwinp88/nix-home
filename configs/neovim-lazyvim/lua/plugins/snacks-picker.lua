-- Snacks.nvim keybindings for LazyVim
-- LazyVim already configures snacks, we just add keybindings

return {
	"folke/snacks.nvim",
	keys = {
		-- LSP Navigation with Snacks picker
		{
			"gd",
			function() Snacks.picker.lsp_definitions() end,
			desc = "Goto Definition",
			nowait = true,
		},
		{
			"gr",
			function() Snacks.picker.lsp_references() end,
			desc = "References",
			nowait = true,
		},
		{
			"gD",
			function() Snacks.picker.lsp_declarations() end,
			desc = "Goto Declaration",
			nowait = true,
		},
		{
			"gI",
			function() Snacks.picker.lsp_implementations() end,
			desc = "Goto Implementation",
			nowait = true,
		},
		{
			"gy",
			function() Snacks.picker.lsp_type_definitions() end,
			desc = "Goto T[y]pe Definition",
			nowait = true,
		},

		{
			"<leader>z",
			function() Snacks.zen() end,
			desc = "Toggle Zen Mode",
			nowait = true,
		},
		{
			"<leader>Z",
			function() Snacks.zen.zoom() end,
			desc = "Toggle Zoom",
			nowait = true,
		},
		{
			"<leader>.",
			function() Snacks.scratch() end,
			desc = "Toggle Scratch Buffer",
			nowait = true,
		},
		{
			"<leader>,",
			function() Snacks.scratch.select() end,
			desc = "Select Scratch Buffer",
			nowait = true,
		},
		{
			"<leader>n",
			function() Snacks.notifier.show_history() end,
			desc = "Notification History",
			nowait = true,
		},
		{
			"<leader>bb",
			function() Snacks.picker.buffers() end,
			desc = "Buffer Picker",
			nowait = true,
		},
		{
			"<leader>bd",
			function() Snacks.bufdelete() end,
			desc = "Delete Buffer",
			nowait = true,
		},
		{
			"<leader>gB",
			function() Snacks.git.blame_line() end,
			desc = "Git Blame Line",
			nowait = true,
		},

		-- Top-level pickers
		{
			"<leader><space>",
			function() Snacks.picker.smart() end,
			desc = "Smart Find Files",
			nowait = true,
		},
		{
			"<leader>/",
			function() Snacks.picker.grep() end,
			desc = "Grep",
			nowait = true,
		},
		{
			"<leader>:",
			function() Snacks.picker.command_history() end,
			desc = "Command History",
			nowait = true,
		},

		-- Find submenu
		{
			"<leader>fb",
			function() Snacks.picker.buffers() end,
			desc = "Buffers",
			nowait = true,
		},
		{
			"<leader>fc",
			function()
				Snacks.picker.files({ cwd = vim.fn.stdpath("config") })
			end,
			desc = "Find Config File",
			nowait = true,
		},
		{
			"<leader>ff",
			function() Snacks.picker.files() end,
			desc = "Find Files",
			nowait = true,
		},
		{
			"<leader>fg",
			function() Snacks.picker.git_files() end,
			desc = "Find Git Files",
			nowait = true,
		},
		{
			"<leader>fr",
			function()
				Snacks.picker.recent({ filter = { cwd = true } })
			end,
			desc = "Recent (Project)",
			nowait = true,
		},
		{
			"<leader>fR",
			function() Snacks.picker.recent() end,
			desc = "Recent (Global)",
			nowait = true,
		},
		{
			"<leader>fp",
			function() Snacks.picker.projects() end,
			desc = "Projects",
			nowait = true,
		},

		-- Git submenu
		{
			"<leader>gg",
			function() Snacks.lazygit() end,
			desc = "Lazygit",
			nowait = true,
		},
		{
			"<leader>gb",
			function() Snacks.picker.git_branches() end,
			desc = "Git Branches",
			nowait = true,
		},
		-- Removed <leader>gl and <leader>gL - using diffview.nvim instead
		{
			"<leader>gs",
			function() Snacks.picker.git_status() end,
			desc = "Git Status",
			nowait = true,
		},
		{
			"<leader>gS",
			function() Snacks.picker.git_stash() end,
			desc = "Git Stash",
			nowait = true,
		},
		-- Removed <leader>gd - using diffview.nvim instead
		{
			"<leader>gf",
			function() Snacks.picker.git_log_file() end,
			desc = "Git Log File",
			nowait = true,
		},

		-- Search submenu
		{
			"<leader>sb",
			function() Snacks.picker.lines() end,
			desc = "Buffer Lines",
			nowait = true,
		},
		{
			"<leader>sB",
			function() Snacks.picker.grep_buffers() end,
			desc = "Grep Open Buffers",
			nowait = true,
		},
		{
			"<leader>sw",
			function() Snacks.picker.grep_word() end,
			desc = "Visual selection or word",
			mode = { "n", "x" },
			nowait = true,
		},
		{
			'<leader>s"',
			function() Snacks.picker.registers() end,
			desc = "Registers",
			nowait = true,
		},
		{
			"<leader>s/",
			function() Snacks.picker.search_history() end,
			desc = "Search History",
			nowait = true,
		},
		{
			"<leader>sa",
			function() Snacks.picker.autocmds() end,
			desc = "Autocmds",
			nowait = true,
		},
		{
			"<leader>sc",
			function() Snacks.picker.command_history() end,
			desc = "Command History",
			nowait = true,
		},
		{
			"<leader>sC",
			function() Snacks.picker.commands() end,
			desc = "Commands",
			nowait = true,
		},
		{
			"<leader>sd",
			function() Snacks.picker.diagnostics() end,
			desc = "Diagnostics",
			nowait = true,
		},
		{
			"<leader>sD",
			function() Snacks.picker.diagnostics_buffer() end,
			desc = "Buffer Diagnostics",
			nowait = true,
		},
		{
			"<leader>sh",
			function() Snacks.picker.help() end,
			desc = "Help Pages",
			nowait = true,
		},
		{
			"<leader>sH",
			function() Snacks.picker.highlights() end,
			desc = "Highlights",
			nowait = true,
		},
		{
			"<leader>si",
			function() Snacks.picker.icons() end,
			desc = "Icons",
			nowait = true,
		},
		{
			"<leader>sj",
			function() Snacks.picker.jumps() end,
			desc = "Jumps",
			nowait = true,
		},
		{
			"<leader>sk",
			function() Snacks.picker.keymaps() end,
			desc = "Keymaps",
			nowait = true,
		},
		{
			"<leader>sl",
			function() Snacks.picker.loclist() end,
			desc = "Location List",
			nowait = true,
		},
		{
			"<leader>sm",
			function() Snacks.picker.marks() end,
			desc = "Marks",
			nowait = true,
		},
		{
			"<leader>sM",
			function() Snacks.picker.man() end,
			desc = "Man Pages",
			nowait = true,
		},
		{
			"<leader>sp",
			function() Snacks.picker.lazy() end,
			desc = "Search for Plugin Spec",
			nowait = true,
		},
		{
			"<leader>sq",
			function() Snacks.picker.qflist() end,
			desc = "Quickfix List",
			nowait = true,
		},
		{
			"<leader>sR",
			function() Snacks.picker.resume() end,
			desc = "Resume",
			nowait = true,
		},
		{
			"<leader>su",
			function() Snacks.picker.undo() end,
			desc = "Undo History",
			nowait = true,
		},
		{
			"<leader>ss",
			function() Snacks.picker.lsp_symbols() end,
			desc = "LSP Symbols",
			nowait = true,
		},
		{
			"<leader>sS",
			function() Snacks.picker.lsp_workspace_symbols() end,
			desc = "LSP Workspace Symbols",
			nowait = true,
		},

		-- UI toggles
		{
			"<leader>uC",
			function() Snacks.picker.colorschemes() end,
			desc = "Colorschemes",
			nowait = true,
		},
		{
			"<leader>un",
			function() Snacks.notifier.hide() end,
			desc = "Dismiss All Notifications",
			nowait = true,
		},

		-- Terminal
		{
			"<c-/>",
			function() Snacks.terminal() end,
			desc = "Toggle Terminal",
			nowait = true,
		},
		{
			"<c-_>",
			function() Snacks.terminal() end,
			desc = "which_key_ignore",
			nowait = true,
		},

		-- Word navigation
		{
			"]]",
			function()
				Snacks.words.jump(vim.v.count1)
			end,
			desc = "Next Reference",
			mode = { "n", "t" },
			nowait = true,
		},
		{
			"[[",
			function()
				Snacks.words.jump(-vim.v.count1)
			end,
			desc = "Prev Reference",
			mode = { "n", "t" },
			nowait = true,
		},

		{
			"<leader>N",
			desc = "Neovim News",
			function()
				Snacks.win({
					file = vim.api.nvim_get_runtime_file("doc/news.txt", false)[1],
					width = 0.8,
					height = 0.8,
					wo = { spell = false, wrap = false, signcolumn = "yes", statuscolumn = " ", conceallevel = 3 },
				})
			end,
			nowait = true,
		},
	},
}
