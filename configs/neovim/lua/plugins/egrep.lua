-- egrep.nvim Plugin Specification
return {
  dir = "/Users/ashwin/Code/egrep.nvim",
  name = "egrep.nvim",
  lazy = false,
  dependencies = {
    "MunifTanjim/nui.nvim",
    "nvim-tree/nvim-web-devicons", -- optional, for file icons
  },

  config = function()
    require("egrep").setup({
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
      "<leader>/",
      function()
        require("egrep").grep()
      end,
      desc = "Enhanced Grep",
      nowait = true,
    },
    {
      "<leader>sT",
      function()
        require("egrep").grep_no_tests()
      end,
      desc = "Enhanced Grep (No Tests)",
      nowait = true,
    },
    {
      "<leader>sP",
      function()
        require("egrep").select_preset()
      end,
      desc = "Enhanced Grep (Preset)",
      nowait = true,
    },
    {
      "<leader>sW",
      function()
        require("egrep").grep_word()
      end,
      desc = "Enhanced Grep Word",
      nowait = true,
    },
    {
      "<leader>s<leader>",
      function()
        require("egrep").repeat_last()
      end,
      desc = "Repeat Last Search",
      nowait = true,
    },
  },
}
