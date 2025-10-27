-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua

-- Check for file changes on various events (auto-reload)
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI", "CursorMoved", "TermClose" }, {
  callback = function()
    if vim.api.nvim_get_mode().mode ~= "c" then
      vim.cmd("checktime")
    end
  end,
})

-- Notify when file changes on disk
vim.api.nvim_create_autocmd("FileChangedShellPost", {
  callback = function()
    vim.notify("File changed on disk. Buffer reloaded.", vim.log.levels.INFO)
  end,
})
