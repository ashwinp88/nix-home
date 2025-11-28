-- Use OSC52 clipboard integration when running inside remote shells/tmux.
local function need_osc52()
  -- macOS has native clipboard support (pbcopy/pbpaste) that works in tmux
  if jit.os == "OSX" then
    return false
  end

  if os.getenv("SSH_TTY") or os.getenv("SSH_CONNECTION") then
    return true
  end
  -- Running under tmux without a GUI display is also a good signal
  if os.getenv("TMUX") and (os.getenv("DISPLAY") == nil or os.getenv("DISPLAY") == "") then
    return true
  end
  return false
end

if not need_osc52() then
  return
end

local ok, osc52 = pcall(require, "vim.ui.clipboard.osc52")
if not ok then
  return
end

vim.g.clipboard = {
  name = "osc52",
  copy = {
    ["+"] = osc52.copy("+"),
    ["*"] = osc52.copy("*"),
  },
  paste = {
    ["+"] = osc52.paste("+"),
    ["*"] = osc52.paste("*"),
  },
}
