return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  config = function()
    require("neo-tree").setup({
      close_if_last_window = false, -- Don't quit when Neo-tree is the last window
      popup_border_style = "rounded",
      source_selector = {
        winbar = true,
        statusline = false,
        sources = {
          { source = "filesystem", display_name = " 󰉓 Files " },
          { source = "buffers", display_name = " 󰈚 Buffers " },
          { source = "git_status", display_name = " 󰊢 Git " },
          { source = "document_symbols", display_name = "  Symbols " },
        },
        content_layout = "center",
        tabs_layout = "equal",
      },
      window = {
        position = "left",
        width = 30,
        mappings = {
          ["<Left>"] = "close_node",
          ["<Right>"] = "open",
          ["h"] = "none",
          ["l"] = "none",
          ["<space>"] = "none",
          ["<"] = "prev_source",
          [">"] = "next_source",
        },
      },
      filesystem = {
        follow_current_file = {
          enabled = true,  -- Highlight and follow the currently active buffer
        },
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignored = false,
        },
      },
      document_symbols = {
        follow_cursor = true,
        kinds = {
          File = { icon = "󰈙", hl = "Tag" },
          Namespace = { icon = "󰌗", hl = "Include" },
          Package = { icon = "󰏖", hl = "Label" },
          Class = { icon = "󰌗", hl = "Include" },
          Property = { icon = "󰆧", hl = "@property" },
          Enum = { icon = "󰒻", hl = "@number" },
          Function = { icon = "󰊕", hl = "Function" },
          String = { icon = "󰀬", hl = "String" },
          Number = { icon = "󰎠", hl = "Number" },
          Array = { icon = "󰅪", hl = "Type" },
          Object = { icon = "󰅩", hl = "Type" },
          Key = { icon = "󰌋", hl = "" },
          Struct = { icon = "󰌗", hl = "Type" },
          Operator = { icon = "󰆕", hl = "Operator" },
          TypeParameter = { icon = "󰊄", hl = "Type" },
          StaticMethod = { icon = "󰠄 ", hl = "Function" },
        },
      },
    })
    -- Neo-tree keybindings
    vim.keymap.set("n", "<leader>e", "<cmd>Neotree toggle<cr>", { desc = "Toggle file explorer" })
    vim.keymap.set("n", "<leader>E", "<cmd>Neotree focus<cr>", { desc = "Focus file explorer" })
    vim.keymap.set("n", "<leader>be", "<cmd>Neotree buffers<cr>", { desc = "Buffer explorer" })
    vim.keymap.set("n", "<leader>ge", "<cmd>Neotree git_status<cr>", { desc = "Git explorer" })
  end,
}