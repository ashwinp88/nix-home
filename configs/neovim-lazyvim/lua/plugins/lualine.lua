-- Lualine configuration override

return {
  "nvim-lualine/lualine.nvim",
  opts = function()
    -- Get colorscheme from environment variable
    local colorscheme = vim.env.NVIM_COLORSCHEME or "catppuccin"

    return {
      options = {
        theme = colorscheme,  -- Dynamic theme
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        globalstatus = true,
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = { "filename" },
        lualine_x = {
          "encoding",
          "fileformat",
          "filetype",
        },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    }
  end,
}
