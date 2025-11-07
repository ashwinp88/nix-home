-- Unified picker UI for enhanced grep
local state = require("enhanced-grep.state")
local patterns = require("enhanced-grep.patterns")

local M = {}

-- UI state
local ui_state = {
  main_buf = nil,
  main_win = nil,
  input_buf = nil,
  input_win = nil,
  results = {},
  file_map = {},
  match_map = {},
  search_timer = nil,
  current_search = "",
  include_patterns = {},
  exclude_patterns = {},
  on_search_callback = nil,
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
  vim.api.nvim_set_hl(0, "EnhancedGrepPrompt", {link = "Title", default = true})
  vim.api.nvim_set_hl(0, "EnhancedGrepBorder", {link = "FloatBorder", default = true})
end

--- Close the picker
function M.close()
  if ui_state.search_timer then
    vim.fn.timer_stop(ui_state.search_timer)
    ui_state.search_timer = nil
  end

  if ui_state.input_win and vim.api.nvim_win_is_valid(ui_state.input_win) then
    vim.api.nvim_win_close(ui_state.input_win, true)
  end
  if ui_state.main_win and vim.api.nvim_win_is_valid(ui_state.main_win) then
    vim.api.nvim_win_close(ui_state.main_win, true)
  end

  ui_state = {
    main_buf = nil,
    main_win = nil,
    input_buf = nil,
    input_win = nil,
    results = {},
    file_map = {},
    match_map = {},
    search_timer = nil,
    current_search = "",
    include_patterns = {},
    exclude_patterns = {},
    on_search_callback = nil,
  }
end

--- Render header with filters
local function render_header(include_pat, exclude_pat, no_tests)
  local lines = {}
  local test_icon = no_tests and icons.checked or icons.unchecked

  local include_str = patterns.format_patterns(include_pat)
  local exclude_str = patterns.format_patterns(exclude_pat)

  table.insert(lines, string.format("%s No Tests [C-t]  Include: %s [C-i]  Exclude: %s [C-e]  Help: [?]",
    test_icon,
    include_str ~= "" and include_str or "(none)",
    exclude_str ~= "" and exclude_str or "(none)"
  ))
  table.insert(lines, string.rep("─", 100))

  return lines
end

--- Render results in main buffer
function M.render_results(results)
  if not ui_state.main_buf or not vim.api.nvim_buf_is_valid(ui_state.main_buf) then
    return
  end

  ui_state.results = results or {}
  ui_state.file_map = {}
  ui_state.match_map = {}

  local lines = {}
  local highlights = {}

  -- Header with filters
  local current = state.get()
  local header_lines = render_header(
    ui_state.include_patterns,
    ui_state.exclude_patterns,
    current.ignore_tests
  )
  vim.list_extend(lines, header_lines)

  -- Results header
  local total_files = #ui_state.results
  local total_matches = 0
  for _, file_data in ipairs(ui_state.results) do
    total_matches = total_matches + #file_data.matches
  end

  if total_files == 0 then
    table.insert(lines, "")
    table.insert(lines, "No results found")
  else
    table.insert(lines, "")
    table.insert(lines, string.format("Results: %d files, %d matches", total_files, total_matches))
    table.insert(lines, "")

    -- Render each file and its matches
    for _, file_data in ipairs(ui_state.results) do
      local file = file_data.path
      local matches = file_data.matches
      local file_line = #lines + 1
      local is_expanded = state.get_fold_state(file)

      -- File header line
      local fold_icon = is_expanded and icons.expanded or icons.collapsed
      local file_line_text = string.format("%s %s (%d)", fold_icon, file, #matches)
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
    end
  end

  -- Set buffer lines
  vim.api.nvim_buf_set_option(ui_state.main_buf, "modifiable", true)
  vim.api.nvim_buf_set_lines(ui_state.main_buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(ui_state.main_buf, "modifiable", false)

  -- Apply highlights
  local ns_id = vim.api.nvim_create_namespace("enhanced_grep")
  vim.api.nvim_buf_clear_namespace(ui_state.main_buf, ns_id, 0, -1)

  for _, hl in ipairs(highlights) do
    if hl.line >= 0 and hl.line < #lines then
      pcall(vim.api.nvim_buf_add_highlight,
        ui_state.main_buf,
        ns_id,
        hl.hl_group,
        hl.line,
        hl.col_start,
        hl.col_end
      )
    end
  end
end

--- Toggle fold at cursor in main window
function M.toggle_fold()
  if not ui_state.main_buf then
    return
  end

  local cursor = vim.api.nvim_win_get_cursor(ui_state.main_win)
  local line = cursor[1]

  local file_data = ui_state.file_map[line]
  if file_data then
    state.toggle_fold_state(file_data.file)
    M.render_results(ui_state.results)
  end
end

--- Jump to match under cursor
function M.jump_to_match()
  if not ui_state.main_buf then
    return
  end

  local cursor = vim.api.nvim_win_get_cursor(ui_state.main_win)
  local line = cursor[1]

  local match_data = ui_state.match_map[line]
  if match_data then
    M.close()
    vim.cmd("edit " .. vim.fn.fnameescape(match_data.file))
    vim.api.nvim_win_set_cursor(0, {match_data.line_number, match_data.column})
    vim.cmd("normal! zz")
  end
end

--- Expand all folds
function M.expand_all()
  for _, file_data in ipairs(ui_state.results) do
    state.set_fold_state(file_data.path, true)
  end
  M.render_results(ui_state.results)
end

--- Collapse all folds
function M.collapse_all()
  for _, file_data in ipairs(ui_state.results) do
    state.set_fold_state(file_data.path, false)
  end
  M.render_results(ui_state.results)
end

--- Export to quickfix
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
  M.close()
  vim.cmd("copen")
  vim.notify(string.format("Exported %d matches to quickfix", #qf_list), vim.log.levels.INFO)
end

-- Forward declaration for trigger_search
local trigger_search

--- Toggle "No Tests" filter
function M.toggle_no_tests()
  local current = state.get()
  local new_value = not current.ignore_tests
  state.update({ignore_tests = new_value})

  -- Update exclude patterns
  local test_patterns = {
    "/test/*", "/tests/*", "/spec/*", "/__tests__/*",
    "*_test.*", "*_spec.*", "test_*.*", "*.test.*", "*.spec.*"
  }

  if new_value then
    -- Add test patterns to exclusions
    for _, pattern in ipairs(test_patterns) do
      if not vim.tbl_contains(ui_state.exclude_patterns, pattern) then
        table.insert(ui_state.exclude_patterns, pattern)
      end
    end
  else
    -- Remove test patterns from exclusions
    ui_state.exclude_patterns = vim.tbl_filter(function(p)
      return not vim.tbl_contains(test_patterns, p)
    end, ui_state.exclude_patterns)
  end

  -- Re-render and re-search
  M.render_results(ui_state.results)
  if ui_state.current_search ~= "" then
    trigger_search()
  end
end

--- Edit include patterns
function M.edit_include_patterns()
  local current = patterns.format_patterns(ui_state.include_patterns)
  vim.ui.input({
    prompt = "Include patterns (space-separated, e.g. *.lua *.vim): ",
    default = current,
  }, function(input)
    if input then
      ui_state.include_patterns = patterns.parse_patterns(input)
      M.render_results(ui_state.results)
      if ui_state.current_search ~= "" then
        trigger_search()
      end
    end
  end)
end

--- Edit exclude patterns
function M.edit_exclude_patterns()
  local current = patterns.format_patterns(ui_state.exclude_patterns)
  vim.ui.input({
    prompt = "Exclude patterns (space-separated, e.g. /test/* *_spec.*): ",
    default = current,
  }, function(input)
    if input then
      ui_state.exclude_patterns = patterns.parse_patterns(input)
      M.render_results(ui_state.results)
      if ui_state.current_search ~= "" then
        trigger_search()
      end
    end
  end)
end

--- Show help
function M.show_help()
  local help_text = {
    "Enhanced Grep Keybindings:",
    "",
    "Navigation:",
    "  <CR>       - Jump to match under cursor",
    "  <Tab>/za   - Toggle fold for file",
    "  zR         - Expand all folds",
    "  zM         - Collapse all folds",
    "",
    "Editing:",
    "  i          - Edit search pattern",
    "  <C-t>      - Toggle 'No Tests' filter",
    "  <C-i>      - Edit include patterns",
    "  <C-e>      - Edit exclude patterns",
    "",
    "Actions:",
    "  <C-q>      - Send to quickfix list",
    "  q/<Esc>    - Close picker",
    "  ?          - Show this help",
    "",
    "Tips:",
    "  - Type to search live (300ms delay)",
    "  - Use wildcards in patterns (*.rb, /test/*, etc)",
  }

  vim.notify(table.concat(help_text, "\n"), vim.log.levels.INFO, {title = "Enhanced Grep Help"})
end

--- Trigger search from input
trigger_search = function()
  if not ui_state.input_buf or not vim.api.nvim_buf_is_valid(ui_state.input_buf) then
    return
  end

  local lines = vim.api.nvim_buf_get_lines(ui_state.input_buf, 0, 1, false)
  local pattern = (lines[1] or ""):gsub("^%s+", ""):gsub("%s+$", "")  -- Trim whitespace

  if pattern == ui_state.current_search then
    return
  end

  ui_state.current_search = pattern

  if pattern == "" then
    M.render_results({})
    return
  end

  -- Call the search callback
  if ui_state.on_search_callback then
    ui_state.on_search_callback(pattern, {
      include_patterns = ui_state.include_patterns,
      exclude_patterns = ui_state.exclude_patterns,
    })
  end
end

--- Debounced search trigger
local function trigger_search_debounced()
  if ui_state.search_timer then
    vim.fn.timer_stop(ui_state.search_timer)
  end

  ui_state.search_timer = vim.fn.timer_start(300, function()
    vim.schedule(trigger_search)
  end)
end

--- Create the unified picker UI
function M.create_picker(opts)
  opts = opts or {}

  -- Load saved state
  local saved_state = state.get()
  ui_state.include_patterns = opts.include_patterns or saved_state.last_include or {}
  ui_state.exclude_patterns = opts.exclude_patterns or saved_state.last_exclude or {}
  ui_state.on_search_callback = opts.on_search

  -- Calculate dimensions
  local width = opts.width or math.floor(vim.o.columns * 0.8)
  local height = opts.height or math.floor(vim.o.lines * 0.8)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  -- Create input buffer (regular buffer for text change events)
  ui_state.input_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(ui_state.input_buf, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(ui_state.input_buf, "buftype", "")  -- Regular buffer, not prompt
  vim.api.nvim_buf_set_option(ui_state.input_buf, "modifiable", true)
  vim.api.nvim_buf_set_lines(ui_state.input_buf, 0, -1, false, {opts.default_pattern or ""})

  -- No prompt_setprompt for regular buffers

  -- Create input window with search label
  ui_state.input_win = vim.api.nvim_open_win(ui_state.input_buf, true, {
    relative = "editor",
    width = width,
    height = 1,
    row = row,
    col = col,
    style = "minimal",
    border = {"╭", "─", "╮", "│", "┤", "─", "├", "│"},
    title = " Enhanced Grep - Search: ",
    title_pos = "left",
  })

  -- Create main buffer for results
  ui_state.main_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(ui_state.main_buf, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(ui_state.main_buf, "filetype", "enhanced-grep")
  vim.api.nvim_buf_set_option(ui_state.main_buf, "modifiable", false)

  -- Create main window for results
  ui_state.main_win = vim.api.nvim_open_win(ui_state.main_buf, false, {
    relative = "editor",
    width = width,
    height = height - 2,
    row = row + 2,
    col = col,
    style = "minimal",
    border = {"├", "─", "┤", "│", "╯", "─", "╰", "│"},
  })

  vim.api.nvim_win_set_option(ui_state.main_win, "wrap", false)
  vim.api.nvim_win_set_option(ui_state.main_win, "cursorline", true)

  -- Set up input buffer keymaps
  local input_keymaps = {
    {"i", "<CR>", function()
      trigger_search()
      vim.cmd("stopinsert")
      vim.api.nvim_set_current_win(ui_state.main_win)
    end, {desc = "Search"}},
    {"i", "<C-t>", function()
      vim.cmd("stopinsert")
      M.toggle_no_tests()
      vim.cmd("startinsert!")
    end, {desc = "Toggle no tests filter"}},
    {"i", "<C-i>", function()
      vim.cmd("stopinsert")
      M.edit_include_patterns()
    end, {desc = "Edit include patterns"}},
    {"i", "<C-e>", function()
      vim.cmd("stopinsert")
      M.edit_exclude_patterns()
    end, {desc = "Edit exclude patterns"}},
    {"i", "<Esc>", function()
      M.close()
    end, {desc = "Close"}},
    {"i", "<C-c>", function()
      M.close()
    end, {desc = "Close"}},
    {"n", "<Esc>", function()
      M.close()
    end, {desc = "Close"}},
    {"n", "q", function()
      M.close()
    end, {desc = "Close"}},
    {"n", "?", M.show_help, {desc = "Show help"}},
  }

  for _, keymap in ipairs(input_keymaps) do
    vim.keymap.set(keymap[1], keymap[2], keymap[3],
      vim.tbl_extend("force", keymap[4], {buffer = ui_state.input_buf, nowait = true}))
  end

  -- Set up main buffer keymaps
  local main_keymaps = {
    {"n", "<CR>", M.jump_to_match, {desc = "Jump to match"}},
    {"n", "<Tab>", M.toggle_fold, {desc = "Toggle fold"}},
    {"n", "za", M.toggle_fold, {desc = "Toggle fold"}},
    {"n", "zR", M.expand_all, {desc = "Expand all"}},
    {"n", "zM", M.collapse_all, {desc = "Collapse all"}},
    {"n", "i", function()
      vim.api.nvim_set_current_win(ui_state.input_win)
      vim.cmd("startinsert!")
    end, {desc = "Edit search"}},
    {"n", "<C-t>", M.toggle_no_tests, {desc = "Toggle no tests filter"}},
    {"n", "<C-i>", M.edit_include_patterns, {desc = "Edit include patterns"}},
    {"n", "<C-e>", M.edit_exclude_patterns, {desc = "Edit exclude patterns"}},
    {"n", "?", M.show_help, {desc = "Show help"}},
    {"n", "q", M.close, {desc = "Close"}},
    {"n", "<Esc>", M.close, {desc = "Close"}},
    {"n", "<C-q>", M.to_quickfix, {desc = "Send to quickfix"}},
  }

  for _, keymap in ipairs(main_keymaps) do
    vim.keymap.set(keymap[1], keymap[2], keymap[3],
      vim.tbl_extend("force", keymap[4], {buffer = ui_state.main_buf, nowait = true}))
  end

  -- Set up autocmd for live search
  vim.api.nvim_create_autocmd({"TextChanged", "TextChangedI"}, {
    buffer = ui_state.input_buf,
    callback = trigger_search_debounced,
  })

  -- Render initial empty state
  M.render_results({})

  -- Start in insert mode
  vim.cmd("startinsert!")

  return ui_state.input_buf, ui_state.main_buf
end

-- Setup highlights on load
setup_highlights()

return M
