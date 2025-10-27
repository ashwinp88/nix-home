-- Colorscheme configuration with dynamic selection from environment variable

-- Get colorscheme from environment variable (set by Nix)
local scheme = vim.env.NVIM_COLORSCHEME or "catppuccin"

return {
  -- Catppuccin
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = scheme ~= "catppuccin",
    priority = 1000,
    opts = {
      flavour = "mocha",
    },
    config = function(_, opts)
      require("catppuccin").setup(opts)
      if scheme == "catppuccin" then
        vim.cmd.colorscheme("catppuccin")
      end
    end,
  },

  -- TokyoNight
  {
    "folke/tokyonight.nvim",
    lazy = scheme ~= "tokyonight",
    priority = 1000,
    opts = {},
    config = function(_, opts)
      require("tokyonight").setup(opts)
      if scheme == "tokyonight" then
        vim.cmd.colorscheme("tokyonight")
      end
    end,
  },

  -- Gruvbox
  {
    "ellisonleao/gruvbox.nvim",
    lazy = scheme ~= "gruvbox",
    priority = 1000,
    opts = {},
    config = function(_, opts)
      require("gruvbox").setup(opts)
      if scheme == "gruvbox" then
        vim.cmd.colorscheme("gruvbox")
      end
    end,
  },

  -- Nord
  {
    "shaunsingh/nord.nvim",
    lazy = scheme ~= "nord",
    priority = 1000,
    config = function()
      if scheme == "nord" then
        vim.cmd.colorscheme("nord")
      end
    end,
  },

  -- Configure LazyVim to load the selected colorscheme
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = scheme,
    },
  },
}
