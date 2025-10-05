-- Lua LSP configuration
-- Use modern vim.lsp.config API (nvim 0.11+)

-- Only configure once
if not vim.g.lua_lsp_configured then
	vim.g.lua_lsp_configured = true

	vim.lsp.config("lua_ls", {
		cmd = { "lua-language-server" },
		filetypes = { "lua" },
		root_markers = { ".luarc.json", ".luarc.jsonc", ".luacheckrc", ".stylua.toml", "stylua.toml", ".git" },
		settings = {
			Lua = {
				runtime = {
					version = "LuaJIT",
				},
				diagnostics = {
					globals = { "vim" },
				},
				workspace = {
					library = vim.api.nvim_get_runtime_file("", true),
					checkThirdParty = false,
				},
				telemetry = {
					enable = false,
				},
				format = {
					enable = true,
					defaultConfig = {
						indent_style = "space",
						indent_size = "2",
					},
				},
			},
		},
	})

	-- Auto-enable for lua files
	vim.lsp.enable("lua_ls")
end
