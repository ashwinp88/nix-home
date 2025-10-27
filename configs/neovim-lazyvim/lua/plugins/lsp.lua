-- LSP Configuration
-- Disable Mason for Ruby/Sorbet (managed via Nix + shadowenv)
-- Let Mason handle all other LSPs

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Disable auto-configuration for Ruby/Sorbet
        -- Your custom ruby-lsp.lua (from Shopify overlay) handles these
        ruby_lsp = {
          enabled = false,  -- Don't auto-configure
        },
        sorbet = {
          enabled = false,  -- Don't auto-configure
        },
        -- All other LSPs will be handled by Mason automatically
      },
    },
  },
}
