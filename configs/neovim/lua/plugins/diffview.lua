return {
	"sindrets/diffview.nvim",
	dependencies = { "nvim-lua/plenary.nvim" },
	cmd = {
		"DiffviewOpen",
		"DiffviewClose",
		"DiffviewToggleFiles",
		"DiffviewFocusFiles",
		"DiffviewRefresh",
		"DiffviewFileHistory",
	},
	keys = {
		{
			"<leader>gd",
			"<cmd>DiffviewOpen<cr>",
			desc = "Git Diff (Working Tree)",
			nowait = true,
		},
		{
			"<leader>gl",
			"<cmd>DiffviewFileHistory<cr>",
			desc = "Git Log (Commit History)",
			nowait = true,
		},
		{
			"<leader>gL",
			"<cmd>DiffviewFileHistory %<cr>",
			desc = "Git Log (Current File)",
			nowait = true,
		},
		{
			"<leader>gS",
			"<cmd>DiffviewFileHistory --range=stash<cr>",
			desc = "Git Stash (Browse)",
			nowait = true,
		},
		{
			"<leader>gf",
			"<cmd>DiffviewFileHistory %<cr>",
			desc = "Git Log (Current File)",
			nowait = true,
		},
	},
	opts = {
		enhanced_diff_hl = true,
		view = {
			default = {
				layout = "diff2_horizontal",
			},
			merge_tool = {
				layout = "diff3_horizontal",
			},
		},
		hooks = {
			view_opened = function()
				-- Enable synchronized scrolling in diff views
				vim.cmd("windo set scrollbind cursorbind")
			end,
		},
	},
}
