-- Enhanced Grep Plugin Specification
return {
  dir = vim.fn.stdpath("config") .. "/lua/enhanced-grep",
  name = "enhanced-grep",
  lazy = false,

  config = function()
    require("enhanced-grep").setup({
      defaults = {
        ignore_tests = true,
        use_gitignore = true,
        case_sensitive = false,
        fold_by_default = false,
        include = {},
        exclude = {"/test/*", "/spec/*", "*_test.*", "*_spec.*"},
      },
      window = {
        width = 0.8,
        height = 0.8,
      },
    })
  end,

  keys = {
    {
      "<leader>sE",
      function()
        require("enhanced-grep").grep()
      end,
      desc = "Enhanced Grep",
      nowait = true,
    },
    {
      "<leader>sT",
      function()
        require("enhanced-grep").grep_no_tests()
      end,
      desc = "Enhanced Grep (No Tests)",
      nowait = true,
    },
    {
      "<leader>sP",
      function()
        require("enhanced-grep").select_preset()
      end,
      desc = "Enhanced Grep (Preset)",
      nowait = true,
    },
    {
      "<leader>sW",
      function()
        require("enhanced-grep").grep_word()
      end,
      desc = "Enhanced Grep Word",
      nowait = true,
    },
    {
      "<leader>s<leader>",
      function()
        require("enhanced-grep").repeat_last()
      end,
      desc = "Repeat Last Search",
      nowait = true,
    },
  },
}
