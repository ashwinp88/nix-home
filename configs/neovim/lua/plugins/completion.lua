return {
  -- nvim-cmp - completion engine
  {
    "hrsh7th/nvim-cmp",
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
      -- Completion sources
      "hrsh7th/cmp-buffer",       -- Buffer words
      "hrsh7th/cmp-path",         -- File system paths
      "hrsh7th/cmp-nvim-lsp",     -- LSP completions
      "hrsh7th/cmp-cmdline",      -- Cmdline completions
      "hrsh7th/cmp-nvim-lua",     -- Neovim Lua API

      -- Snippet engine (required for nvim-cmp)
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",

      -- Additional sources
      "hrsh7th/cmp-nvim-lsp-signature-help",  -- Function signatures
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          -- Tab navigation
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "nvim_lsp_signature_help" },
          { name = "luasnip" },
          { name = "path" },
        }, {
          { name = "buffer", keyword_length = 3 },
        }),
        formatting = {
          format = function(entry, vim_item)
            -- Kind icons
            local kind_icons = {
              Text = "󰉿",
              Method = "󰆧",
              Function = "󰊕",
              Constructor = "",
              Field = "󰜢",
              Variable = "󰀫",
              Class = "󰠱",
              Interface = "",
              Module = "",
              Property = "󰜢",
              Unit = "󰑭",
              Value = "󰎠",
              Enum = "",
              Keyword = "󰌋",
              Snippet = "",
              Color = "󰏘",
              File = "󰈙",
              Reference = "󰈇",
              Folder = "󰉋",
              EnumMember = "",
              Constant = "󰏿",
              Struct = "󰙅",
              Event = "",
              Operator = "󰆕",
              TypeParameter = "",
            }
            vim_item.kind = string.format('%s %s', kind_icons[vim_item.kind], vim_item.kind)
            -- Source
            vim_item.menu = ({
              buffer = "[Buffer]",
              nvim_lsp = "[LSP]",
              luasnip = "[Snippet]",
              nvim_lua = "[Lua]",
              path = "[Path]",
            })[entry.source.name]
            return vim_item
          end,
        },
      })

      -- Setup for specific filetypes
      cmp.setup.filetype("gitcommit", {
        sources = cmp.config.sources({
          { name = "buffer" },
        }),
      })

      -- Cmdline setup for '/' and '?' (search)
      cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "buffer" },
        },
      })

      -- Cmdline setup for ':' (commands)
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "path" },
        }, {
          { name = "cmdline" },
        }),
      })
    end,
  },

  -- LuaSnip - snippet engine
  {
    "L3MON4D3/LuaSnip",
    version = "v2.*",
    build = "make install_jsregexp",
  },
}