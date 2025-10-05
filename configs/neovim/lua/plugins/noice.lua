return {
	"folke/noice.nvim",
	event = "VeryLazy",
	dependencies = {
		"MunifTanjim/nui.nvim",
	},
	opts = {
		-- Use Snacks for notifications
		lsp = {
			-- Override markdown rendering so that **cmp** and other plugins use **Treesitter**
			override = {
				["vim.lsp.util.convert_input_to_markdown_lines"] = true,
				["vim.lsp.util.stylize_markdown"] = true,
				["cmp.entry.get_documentation"] = true,
			},
			-- Show LSP progress (will work alongside lsp-progress.nvim)
			progress = {
				enabled = true,
				format = "lsp_progress",
				format_done = "lsp_progress_done",
				throttle = 1000 / 30, -- frequency to update lsp progress message
				view = "mini",
			},
			-- Hover disabled - use built-in vim.lsp.buf.hover with native multi-client support
			hover = {
				enabled = false,
			},
			signature = {
				enabled = true,
				auto_open = {
					enabled = true,
					trigger = true,
					luasnip = true,
					throttle = 50,
				},
			},
		},
		-- Presets for easier configuration
		presets = {
			bottom_search = true, -- Use classic bottom search
			command_palette = true, -- Position cmdline and popupmenu together
			long_message_to_split = true, -- Long messages sent to split
			inc_rename = false, -- Enables input dialog for inc-rename.nvim
			lsp_doc_border = true, -- Add border to hover docs and signature help
		},
		-- Cmdline configuration
		cmdline = {
			enabled = true,
			view = "cmdline_popup", -- Floating popup
			format = {
				cmdline = { icon = " " },
				search_down = { icon = " " },
				search_up = { icon = " " },
				filter = { icon = " " },
				lua = { icon = " " },
				help = { icon = " " },
			},
		},
		-- Messages configuration
		messages = {
			enabled = true,
			view = "notify", -- Use notify for messages
			view_error = "notify", -- Use notify for errors
			view_warn = "notify", -- Use notify for warnings
			view_history = "messages", -- View for :messages
			view_search = "virtualtext", -- View for search count messages
		},
		-- Popupmenu (completion menu)
		popupmenu = {
			enabled = true,
			backend = "nui", -- Use nui for popup menu
		},
		-- Routes for specific message handling
		routes = {
			{
				filter = {
					event = "msg_show",
					kind = "",
					find = "written",
				},
				opts = { skip = true }, -- Skip "written" messages
			},
		},
		-- Notify integration (uses Snacks notifier)
		notify = {
			enabled = true,
			view = "notify",
		},
		-- Views configuration
		views = {
			cmdline_popup = {
				position = {
					row = "40%",
					col = "50%",
				},
				size = {
					width = 60,
					height = "auto",
				},
				border = {
					style = "rounded",
					padding = { 0, 1 },
				},
				win_options = {
					winhighlight = {
						Normal = "Normal",
						FloatBorder = "DiagnosticInfo",
					},
				},
			},
			popupmenu = {
				relative = "editor",
				position = {
					row = "45%",
					col = "50%",
				},
				size = {
					width = 60,
					height = 10,
				},
				border = {
					style = "rounded",
					padding = { 0, 1 },
				},
				win_options = {
					winhighlight = {
						Normal = "Normal",
						FloatBorder = "DiagnosticInfo",
					},
				},
			},
		},
	},
}