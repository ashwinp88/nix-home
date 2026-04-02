-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua

-- Check for file changes on various events (auto-reload)
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI", "TermClose" }, {
  callback = function()
    if vim.api.nvim_get_mode().mode ~= "c" then
      vim.cmd("checktime")
    end
  end,
})

-- Notify when file changes on disk
vim.api.nvim_create_autocmd("FileChangedShellPost", {
  callback = function(args)
    local filepath = vim.api.nvim_buf_get_name(args.buf)
    if filepath == "" then
      return
    end
    -- File was deleted (e.g. branch switch) — notify once and stop re-checking this buffer
    if vim.fn.filereadable(filepath) == 0 then
      vim.bo[args.buf].autoread = false
      local short = vim.fn.fnamemodify(filepath, ":~:.")
      vim.notify("File deleted from disk: " .. short, vim.log.levels.WARN)
      return
    end
    vim.notify("File changed on disk. Buffer reloaded.", vim.log.levels.INFO)
  end,
})
