return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    local ok, treesitter = pcall(require, "nvim-treesitter")
    if not ok then
      vim.notify("nvim-treesitter not available", vim.log.levels.WARN)
      return
    end

    local parser_languages = {
      "lua",
      "vim",
      "vimdoc",
      "javascript",
      "typescript",
      "yaml",
      "python",
      "markdown",
      "markdown_inline",
    }
    local highlight_filetypes = {
      "lua",
      "vim",
      "help",
      "javascript",
      "typescript",
      "yaml",
      "python",
      "markdown",
    }
    local indent_filetypes = {
      "lua",
      "javascript",
      "typescript",
      "yaml",
      "python",
    }

    treesitter.setup({})

    vim.schedule(function()
      treesitter.install(parser_languages, { summary = true })
    })

    local group = vim.api.nvim_create_augroup("NixHomeTreesitter", { clear = true })

    vim.api.nvim_create_autocmd("FileType", {
      group = group,
      pattern = highlight_filetypes,
      callback = function(args)
        pcall(vim.treesitter.start, args.buf)
      end,
    })

    vim.api.nvim_create_autocmd("FileType", {
      group = group,
      pattern = indent_filetypes,
      callback = function(args)
        vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })
  end,
}
