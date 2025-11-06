-- UI rendering and interaction for enhanced grep
local state = require("enhanced-grep.state")
local patterns = require("enhanced-grep.patterns")

local M = {}

-- UI state
local ui_state = {
  bufnr = nil,
  winnr = nil,
  results = {},
  file_map = {}, -- line number -> file data
  match_map = {}, -- line number -> match data
}

-- Icons
local icons = {
  expanded = "▼",
  collapsed = "▶",
  match = "  ",
  checked = "☑",
  unchecked = "☐",
}

-- Highlight groups
local function setup_highlights()
  vim.api.nvim_set_hl(0, "EnhancedGrepFile", {link = "Directory", default = true})
  vim.api.nvim_set_hl(0, "EnhancedGrepMatch", {link = "String", default = true})
  vim.api.nvim_set_hl(0, "EnhancedGrepLineNr", {link = "LineNr", default = true})
  vim.api.nvim_set_hl(0, "EnhancedGrepIcon", {link = "Special", default = true})
  vim.api.nvim_set_hl(0, "EnhancedGrepCount", {link = "Number", default = true})
  vim.api.nvim_set_hl(0, "EnhancedGrepCheckbox", {link = "Boolean", default = true})
end

--- Render results in buffer
--- @param bufnr number Buffer number
--- @param results table Search results
--- @param opts table Display options
function M.render_results(bufnr, results, opts)
  ui_state.results = results
  ui_state.bufnr = bufnr
  ui_state.file_map = {}
  ui_state.match_map = {}

  local lines = {}
  local highlights = {}

  -- Header
  local total_files = #results
  local total_matches = 0
  for _, file_data in ipairs(results) do
    total_matches = total_matches + #file_data.matches
  end

  table.insert(lines, string.format("Results (%d files, %d matches)", total_files, total_matches))
  table.insert(lines, "")

  -- Render each file and its matches
  for _, file_data in ipairs(results) do
    local file = file_data.path
    local matches = file_data.matches
    local file_line = #lines + 1
    local is_expanded = state.get_fold_state(file)

    -- File header line
    local fold_icon = is_expanded and icons.expanded or icons.collapsed
    local file_line_text = string.format("%s %s (%d matches)", fold_icon, file, #matches)
    table.insert(lines, file_line_text)

    -- Store file info for navigation
    ui_state.file_map[file_line] = {
      file = file,
      expanded = is_expanded,
      match_count = #matches,
    }

    -- Add highlight for file line
    table.insert(highlights, {
      line = file_line - 1,
      col_start = 0,
      col_end = 2,
      hl_group = "EnhancedGrepIcon",
    })
    table.insert(highlights, {
      line = file_line - 1,
      col_start = 2,
      col_end = #file_line_text,
      hl_group = "EnhancedGrepFile",
    })

    -- Render matches if expanded
    if is_expanded then
      for _, match in ipairs(matches) do
        local match_line = #lines + 1
        local match_text = string.format("%sL%d: %s",
          icons.match,
          match.line_number,
          match.text:gsub("^%s+", ""):gsub("%s+$", "")
        )
        table.insert(lines, match_text)

        -- Store match info for navigation
        ui_state.match_map[match_line] = {
          file = file,
          line_number = match.line_number,
          column = match.column,
        }

        -- Add highlights for match line
        local line_nr_start = #icons.match
        local line_nr_end = line_nr_start + #("L" .. match.line_number .. ": ")
        table.insert(highlights, {
          line = match_line - 1,
          col_start = line_nr_start,
          col_end = line_nr_end,
          hl_group = "EnhancedGrepLineNr",
        })
      end
    end

    -- Add blank line between files
    table.insert(lines, "")
  end

  -- Set buffer lines
  vim.api.nvim_buf_set_option(bufnr, "modifiable", true)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(bufnr, "modifiable", false)

  -- Apply highlights
  local ns_id = vim.api.nvim_create_namespace("enhanced_grep")
  vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)

  for _, hl in ipairs(highlights) do
    if hl.line >= 0 and hl.line < #lines then
      vim.api.nvim_buf_add_highlight(
        bufnr,
        ns_id,
        hl.hl_group,
        hl.line,
        hl.col_start,
        hl.col_end
      )
    end
  end
end

--- Toggle fold at cursor
function M.toggle_fold()
  if not ui_state.bufnr then
    return
  end

  local cursor = vim.api.nvim_win_get_cursor(0)
  local line = cursor[1]

  local file_data = ui_state.file_map[line]
  if file_data then
    state.toggle_fold_state(file_data.file)
    -- Re-render to show/hide matches
    M.render_results(ui_state.bufnr, ui_state.results, {})
  end
end

--- Jump to match under cursor
function M.jump_to_match()
  if not ui_state.bufnr then
    return
  end

  local cursor = vim.api.nvim_win_get_cursor(0)
  local line = cursor[1]

  local match_data = ui_state.match_map[line]
  if match_data then
    -- Close the grep window
    if ui_state.winnr and vim.api.nvim_win_is_valid(ui_state.winnr) then
      vim.api.nvim_win_close(ui_state.winnr, false)
    end

    -- Open the file and jump to match
    vim.cmd("edit " .. vim.fn.fnameescape(match_data.file))
    vim.api.nvim_win_set_cursor(0, {match_data.line_number, match_data.column})

    -- Center the line
    vim.cmd("normal! zz")
  end
end

--- Expand all folds
function M.expand_all()
  for _, file_data in ipairs(ui_state.results) do
    state.set_fold_state(file_data.path, true)
  end
  M.render_results(ui_state.bufnr, ui_state.results, {})
end

--- Collapse all folds
function M.collapse_all()
  for _, file_data in ipairs(ui_state.results) do
    state.set_fold_state(file_data.path, false)
  end
  M.render_results(ui_state.bufnr, ui_state.results, {})
end

--- Export results to quickfix
function M.to_quickfix()
  local qf_list = {}

  for _, file_data in ipairs(ui_state.results) do
    for _, match in ipairs(file_data.matches) do
      table.insert(qf_list, {
        filename = file_data.path,
        lnum = match.line_number,
        col = match.column + 1,
        text = match.text,
      })
    end
  end

  vim.fn.setqflist(qf_list, "r")
  vim.cmd("copen")
  vim.notify(string.format("Exported %d matches to quickfix", #qf_list), vim.log.levels.INFO)
end

--- Create floating window for results
--- @param results table Search results
--- @param opts table Window options
--- @return number Buffer number
function M.create_results_window(results, opts)
  opts = opts or {}

  -- Create buffer
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(bufnr, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(bufnr, "filetype", "enhanced-grep")

  -- Calculate window size
  local width = opts.width or math.floor(vim.o.columns * 0.8)
  local height = opts.height or math.floor(vim.o.lines * 0.8)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  -- Create window
  local winnr = vim.api.nvim_open_win(bufnr, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
    title = " Enhanced Grep ",
    title_pos = "center",
  })

  ui_state.winnr = winnr

  -- Set window options
  vim.api.nvim_win_set_option(winnr, "wrap", false)
  vim.api.nvim_win_set_option(winnr, "cursorline", true)

  -- Set up buffer keymaps
  local keymaps = {
    {"n", "<CR>", M.jump_to_match, {desc = "Jump to match"}},
    {"n", "<Tab>", M.toggle_fold, {desc = "Toggle fold"}},
    {"n", "za", M.toggle_fold, {desc = "Toggle fold"}},
    {"n", "zR", M.expand_all, {desc = "Expand all"}},
    {"n", "zM", M.collapse_all, {desc = "Collapse all"}},
    {"n", "q", function()
      vim.api.nvim_win_close(winnr, false)
    end, {desc = "Close window"}},
    {"n", "<Esc>", function()
      vim.api.nvim_win_close(winnr, false)
    end, {desc = "Close window"}},
    {"n", "<C-q>", M.to_quickfix, {desc = "Send to quickfix"}},
  }

  for _, keymap in ipairs(keymaps) do
    vim.keymap.set(keymap[1], keymap[2], keymap[3], vim.tbl_extend("force", keymap[4], {buffer = bufnr}))
  end

  -- Render results
  M.render_results(bufnr, results, opts)

  -- Move cursor to first match
  vim.api.nvim_win_set_cursor(winnr, {3, 0})

  return bufnr
end

-- Setup highlights on load
setup_highlights()

return M
