return {
	"linrongbin16/gitlinker.nvim",
	cmd = "GitLink",
	opts = {},
	keys = {
		-- Copy GitHub link to current line (current branch)
		{
			"<leader>gy",
			"<cmd>GitLink<cr>",
			mode = { "n", "v" },
			desc = "Copy git link (current branch)",
		},
		-- Copy GitHub link with default branch (main/master)
		{
			"<leader>gY",
			"<cmd>GitLink default_branch<cr>",
			mode = { "n", "v" },
			desc = "Copy git link (default branch)",
		},
		-- Open GitHub link in browser (current branch)
		{
			"<leader>go",
			"<cmd>GitLink!<cr>",
			mode = { "n", "v" },
			desc = "Open git link in browser",
		},
		-- Open GitHub link in browser (default branch)
		{
			"<leader>gO",
			"<cmd>GitLink! default_branch<cr>",
			mode = { "n", "v" },
			desc = "Open git link in browser (default branch)",
		},
		-- Blame view on GitHub
		{
			"<leader>gbb",
			"<cmd>GitLink blame<cr>",
			mode = { "n", "v" },
			desc = "Copy git blame link",
		},
	},
}
