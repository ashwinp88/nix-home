-- Redesigned unified picker UI for enhanced grep with preview pane
local state = require("enhanced-grep.state")
local patterns = require("enhanced-grep.patterns")

local M = {}

-- UI state
local ui_state = {
  -- Main results window
  main_buf = nil,
  main_win = nil,
  -- Three input windows
  input_buf = nil,
  input_win = nil,
  include_buf = nil,
  include_win = nil,
  exclude_buf = nil,
  exclude_win = nil,
  -- Options and preview windows
  options_buf = nil,
  options_win = nil,
  preview_buf = nil,
  preview_win = nil,
  -- State tracking
  results = {},
  file_map = {},
  match_map = {},
  search_timer = nil,
  current_search = "",
  current_include = "",
  current_exclude = "",
  include_patterns = {},
  exclude_patterns = {},
  on_search_callback = nil,
  current_preview_file = nil,
  current_focused_input = nil,
  -- Options state
  ruby_only = false,
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
  vim.api.nvim_set_hl(0, "EnhancedGrepPreviewHighlight", {link = "CursorLine", default = true})
  vim.api.nvim_set_hl(0, "EnhancedGrepActiveInput", {link = "CursorLine", default = true})
  vim.api.nvim_set_hl(0, "EnhancedGrepInactiveInput", {link = "Normal", default = true})
  vim.api.nvim_set_hl(0, "EnhancedGrepSeparator", {link = "Comment", default = true})
end

-- Forward declarations
local trigger_search
local render_options

--- Close the picker
function M.close()
  if ui_state.search_timer then
    vim.fn.timer_stop(ui_state.search_timer)
    ui_state.search_timer = nil
  end

  -- Clean up autocmd group
  pcall(vim.api.nvim_del_augroup_by_name, "EnhancedGrepFocus")

  -- Close all windows
  local windows = {
    ui_state.input_win,
    ui_state.include_win,
    ui_state.exclude_win,
    ui_state.options_win,
    ui_state.main_win,
    ui_state.preview_win,
  }

  for _, win in ipairs(windows) do
    if win and vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end

  -- Reset state
  ui_state = {
    main_buf = nil,
    main_win = nil,
    input_buf = nil,
    input_win = nil,
    include_buf = nil,
    include_win = nil,
    exclude_buf = nil,
    exclude_win = nil,
    options_buf = nil,
    options_win = nil,
    preview_buf = nil,
    preview_win = nil,
    results = {},
    file_map = {},
    match_map = {},
    search_timer = nil,
    current_search = "",
    current_include = "",
    current_exclude = "",
    include_patterns = {},
    exclude_patterns = {},
    on_search_callback = nil,
    current_preview_file = nil,
    current_focused_input = nil,
    ruby_only = false,
  }
end

--- Update preview pane with file content
--- @param file string|nil File path
--- @param line_number number|nil Line to highlight
local function update_preview(file, line_number)
  if not ui_state.preview_buf or not vim.api.nvim_buf_is_valid(ui_state.preview_buf) then
    return
  end

  if not file or file == "" then
    vim.api.nvim_buf_set_option(ui_state.preview_buf, "modifiable", true)
    vim.api.nvim_buf_set_lines(ui_state.preview_buf, 0, -1, false, {"No preview available"})
    vim.api.nvim_buf_set_option(ui_state.preview_buf, "modifiable", false)
    return
  end

  ui_state.current_preview_file = file

  -- Read file contents
  local ok, lines = pcall(vim.fn.readfile, file)
  if not ok or not lines then
    vim.api.nvim_buf_set_option(ui_state.preview_buf, "modifiable", true)
    vim.api.nvim_buf_set_lines(ui_state.preview_buf, 0, -1, false, {"Error reading file: " .. file})
    vim.api.nvim_buf_set_option(ui_state.preview_buf, "modifiable", false)
    return
  end

  -- Set file contents
  vim.api.nvim_buf_set_option(ui_state.preview_buf, "modifiable", true)
  vim.api.nvim_buf_set_lines(ui_state.preview_buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(ui_state.preview_buf, "modifiable", false)

  -- Set filetype for syntax highlighting
  local ft = vim.filetype.match({filename = file})
  if ft then
    vim.api.nvim_buf_set_option(ui_state.preview_buf, "filetype", ft)
  end

  -- Highlight and scroll to line
  if line_number and ui_state.preview_win and vim.api.nvim_win_is_valid(ui_state.preview_win) then
    -- Center on the line
    pcall(vim.api.nvim_win_set_cursor, ui_state.preview_win, {line_number, 0})
    vim.api.nvim_win_call(ui_state.preview_win, function()
      vim.cmd("normal! zz")
    end)

    -- Add highlight for the line
    local ns_id = vim.api.nvim_create_namespace("enhanced_grep_preview")
    vim.api.nvim_buf_clear_namespace(ui_state.preview_buf, ns_id, 0, -1)
    vim.api.nvim_buf_add_highlight(ui_state.preview_buf, ns_id, "EnhancedGrepPreviewHighlight", line_number - 1, 0, -1)
  end
end

--- Update preview based on cursor position
function M.update_preview_from_cursor()
  if not ui_state.main_buf or not ui_state.main_win then
    return
  end

  -- Validate window is still valid
  if not vim.api.nvim_win_is_valid(ui_state.main_win) then
    return
  end

  local ok, cursor = pcall(vim.api.nvim_win_get_cursor, ui_state.main_win)
  if not ok then
    return
  end

  local line = cursor[1]

  -- Check if cursor is on a match line
  local match_data = ui_state.match_map[line]
  if match_data then
    update_preview(match_data.file, match_data.line_number)
    return
  end

  -- Check if cursor is on a file line
  local file_data = ui_state.file_map[line]
  if file_data then
    update_preview(file_data.file, nil)
    return
  end
end

--- Render results in main buffer with default expanded view
function M.render_results(results)
  if not ui_state.main_buf or not vim.api.nvim_buf_is_valid(ui_state.main_buf) then
    return
  end

  ui_state.results = results or {}
  ui_state.file_map = {}
  ui_state.match_map = {}

  local lines = {}
  local highlights = {}

  -- Results header
  local total_files = #ui_state.results
  local total_matches = 0
  for _, file_data in ipairs(ui_state.results) do
    total_matches = total_matches + #file_data.matches
  end

  if total_files == 0 then
    table.insert(lines, "No results found")
    table.insert(lines, "")
    table.insert(lines, "Try adjusting your search pattern or filters")
  else
    table.insert(lines, string.format("Results: %d files, %d matches", total_files, total_matches))
    table.insert(lines, "")

    -- Render each file and its matches
    for _, file_data in ipairs(ui_state.results) do
      local file = file_data.path
      local matches = file_data.matches
      local file_line = #lines + 1

      -- Default to collapsed (false) if no saved state exists
      local saved_fold_state = state.get_fold_state(file)
      local is_expanded = saved_fold_state == true  -- Default false if nil

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

          -- Truncate long lines
          if #match_text > 80 then
            match_text = match_text:sub(1, 77) .. "..."
          end

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

--- Update input field highlights based on focus
local function update_input_highlights()
  local current_win = vim.api.nvim_get_current_win()

  -- Update window highlights based on focus
  if ui_state.input_win and vim.api.nvim_win_is_valid(ui_state.input_win) then
    local hl = current_win == ui_state.input_win and "EnhancedGrepActiveInput" or "EnhancedGrepInactiveInput"
    -- Include FloatBorder and FloatTitle to preserve title rendering
    vim.api.nvim_win_set_option(ui_state.input_win, "winhl",
      "Normal:" .. hl .. ",FloatBorder:FloatBorder,FloatTitle:FloatTitle")
  end

  if ui_state.include_win and vim.api.nvim_win_is_valid(ui_state.include_win) then
    local hl = current_win == ui_state.include_win and "EnhancedGrepActiveInput" or "EnhancedGrepInactiveInput"
    vim.api.nvim_win_set_option(ui_state.include_win, "winhl",
      "Normal:" .. hl .. ",FloatBorder:FloatBorder,FloatTitle:FloatTitle")
  end

  if ui_state.exclude_win and vim.api.nvim_win_is_valid(ui_state.exclude_win) then
    local hl = current_win == ui_state.exclude_win and "EnhancedGrepActiveInput" or "EnhancedGrepInactiveInput"
    vim.api.nvim_win_set_option(ui_state.exclude_win, "winhl",
      "Normal:" .. hl .. ",FloatBorder:FloatBorder,FloatTitle:FloatTitle")
  end
end

--- Move to next input field
function M.next_input()
  local current_win = vim.api.nvim_get_current_win()

  if current_win == ui_state.input_win then
    vim.api.nvim_set_current_win(ui_state.include_win)
    vim.cmd("startinsert!")
  elseif current_win == ui_state.include_win then
    vim.api.nvim_set_current_win(ui_state.exclude_win)
    vim.cmd("startinsert!")
  elseif current_win == ui_state.exclude_win then
    vim.api.nvim_set_current_win(ui_state.main_win)
  else
    vim.api.nvim_set_current_win(ui_state.input_win)
    vim.cmd("startinsert!")
  end

  update_input_highlights()
  vim.schedule(function() vim.cmd("redraw") end)
end

--- Move to previous input field
function M.prev_input()
  local current_win = vim.api.nvim_get_current_win()

  if current_win == ui_state.exclude_win then
    vim.api.nvim_set_current_win(ui_state.include_win)
    vim.cmd("startinsert!")
  elseif current_win == ui_state.include_win then
    vim.api.nvim_set_current_win(ui_state.input_win)
    vim.cmd("startinsert!")
  elseif current_win == ui_state.input_win then
    vim.api.nvim_set_current_win(ui_state.exclude_win)
    vim.cmd("startinsert!")
  else
    vim.api.nvim_set_current_win(ui_state.input_win)
    vim.cmd("startinsert!")
  end

  update_input_highlights()
  vim.schedule(function() vim.cmd("redraw") end)
end

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

  -- Update exclude input buffer
  if ui_state.exclude_buf and vim.api.nvim_buf_is_valid(ui_state.exclude_buf) then
    local exclude_str = patterns.format_patterns(ui_state.exclude_patterns)
    vim.api.nvim_buf_set_lines(ui_state.exclude_buf, 0, -1, false, {exclude_str})
  end

  render_options()
  if ui_state.current_search ~= "" then
    trigger_search()
  end
end

--- Toggle Ruby only filter
function M.toggle_ruby_only()
  ui_state.ruby_only = not ui_state.ruby_only

  if ui_state.ruby_only then
    -- Add *.rb to include patterns if not present
    if not vim.tbl_contains(ui_state.include_patterns, "*.rb") then
      table.insert(ui_state.include_patterns, "*.rb")
    end
  else
    -- Remove *.rb from include patterns
    ui_state.include_patterns = vim.tbl_filter(function(p)
      return p ~= "*.rb"
    end, ui_state.include_patterns)
  end

  -- Update include input buffer
  if ui_state.include_buf and vim.api.nvim_buf_is_valid(ui_state.include_buf) then
    local include_str = patterns.format_patterns(ui_state.include_patterns)
    vim.api.nvim_buf_set_lines(ui_state.include_buf, 0, -1, false, {include_str})
  end

  render_options()
  if ui_state.current_search ~= "" then
    trigger_search()
  end
end

--- Toggle case sensitivity
function M.toggle_case_sensitive()
  local current = state.get()
  state.update({case_sensitive = not current.case_sensitive})
  render_options()
  if ui_state.current_search ~= "" then
    trigger_search()
  end
end

--- Render options line
render_options = function()
  if not ui_state.options_buf or not vim.api.nvim_buf_is_valid(ui_state.options_buf) then
    return
  end

  local current = state.get()
  local no_tests_icon = current.ignore_tests and icons.checked or icons.unchecked
  local ruby_only_icon = ui_state.ruby_only and icons.checked or icons.unchecked
  local case_icon = current.case_sensitive and icons.checked or icons.unchecked

  local line = string.format(
    " %s No Tests (F1)   %s Ruby Only (F2)   %s Case Sensitive (F3)   Help (?)",
    no_tests_icon,
    ruby_only_icon,
    case_icon
  )

  vim.api.nvim_buf_set_option(ui_state.options_buf, "modifiable", true)
  vim.api.nvim_buf_set_lines(ui_state.options_buf, 0, -1, false, {line})
  vim.api.nvim_buf_set_option(ui_state.options_buf, "modifiable", false)
end

--- Show help
function M.show_help()
  local help_text = {
    "Enhanced Grep Keybindings:",
    "",
    "Input Navigation:",
    "  <Tab>/<C-n>    - Next input field",
    "  <S-Tab>/<C-p>  - Previous input field",
    "  <CR>           - Execute search and focus results",
    "",
    "Results Navigation:",
    "  <CR>           - Jump to match under cursor",
    "  <Right>/<Left> - Expand/collapse fold for file",
    "  za             - Toggle fold",
    "  zR             - Expand all folds",
    "  zM             - Collapse all folds",
    "  i              - Return to search input",
    "",
    "Quick Options:",
    "  F1             - Toggle 'No Tests' filter",
    "  F2             - Toggle 'Ruby Only' filter",
    "  F3             - Toggle case sensitivity",
    "",
    "Actions:",
    "  <C-q>          - Send to quickfix list",
    "  q/<Esc>        - Close picker",
    "  ?              - Show this help",
    "",
    "Tips:",
    "  - All inputs support live search (300ms delay)",
    "  - Use wildcards: *.rb, /test/*, **/*.lua",
    "  - Preview updates as you navigate results",
    "  - Files are collapsed by default (press Right arrow to expand)",
    "  - F1-F3 work in both insert and normal mode",
  }

  vim.notify(table.concat(help_text, "\n"), vim.log.levels.INFO, {title = "Enhanced Grep Help"})
end

--- Trigger search from inputs
trigger_search = function()
  if not ui_state.input_buf or not vim.api.nvim_buf_is_valid(ui_state.input_buf) then
    return
  end

  -- Save previous values for comparison
  local prev_search = ui_state.current_search
  local prev_include = ui_state.current_include
  local prev_exclude = ui_state.current_exclude

  -- Get search pattern
  local pattern_lines = vim.api.nvim_buf_get_lines(ui_state.input_buf, 0, 1, false)
  local pattern = (pattern_lines[1] or ""):gsub("^%s+", ""):gsub("%s+$", "")

  -- Get include patterns
  local include_str = ""
  if ui_state.include_buf and vim.api.nvim_buf_is_valid(ui_state.include_buf) then
    local include_lines = vim.api.nvim_buf_get_lines(ui_state.include_buf, 0, 1, false)
    include_str = (include_lines[1] or ""):gsub("^%s+", ""):gsub("%s+$", "")
  end

  -- Get exclude patterns
  local exclude_str = ""
  if ui_state.exclude_buf and vim.api.nvim_buf_is_valid(ui_state.exclude_buf) then
    local exclude_lines = vim.api.nvim_buf_get_lines(ui_state.exclude_buf, 0, 1, false)
    exclude_str = (exclude_lines[1] or ""):gsub("^%s+", ""):gsub("%s+$", "")
  end

  -- Check if anything changed
  if pattern == prev_search and include_str == prev_include and exclude_str == prev_exclude then
    return
  end

  -- Update state with new values
  ui_state.current_search = pattern
  ui_state.current_include = include_str
  ui_state.current_exclude = exclude_str
  ui_state.include_patterns = patterns.parse_patterns(include_str)
  ui_state.exclude_patterns = patterns.parse_patterns(exclude_str)

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

--- Set up keymaps for input buffers
local function setup_input_keymaps(buf)
  local keymaps = {
    {"i", "<Tab>", M.next_input, {desc = "Next input"}},
    {"i", "<S-Tab>", M.prev_input, {desc = "Previous input"}},
    {"i", "<C-n>", M.next_input, {desc = "Next input"}},
    {"i", "<C-p>", M.prev_input, {desc = "Previous input"}},
    {"i", "<CR>", function()
      trigger_search()
      vim.cmd("stopinsert")
      vim.api.nvim_set_current_win(ui_state.main_win)
      update_input_highlights()
      vim.schedule(function() vim.cmd("redraw") end)
    end, {desc = "Search and focus results"}},
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
    {"n", "<F1>", M.toggle_no_tests, {desc = "Toggle no tests"}},
    {"i", "<F1>", M.toggle_no_tests, {desc = "Toggle no tests"}},
    {"n", "<F2>", M.toggle_ruby_only, {desc = "Toggle Ruby only"}},
    {"i", "<F2>", M.toggle_ruby_only, {desc = "Toggle Ruby only"}},
    {"n", "<F3>", M.toggle_case_sensitive, {desc = "Toggle case sensitive"}},
    {"i", "<F3>", M.toggle_case_sensitive, {desc = "Toggle case sensitive"}},
  }

  for _, keymap in ipairs(keymaps) do
    vim.keymap.set(keymap[1], keymap[2], keymap[3],
      vim.tbl_extend("force", keymap[4], {buffer = buf, nowait = true}))
  end
end

--- Create the unified picker UI with preview pane
function M.create_picker(opts)
  opts = opts or {}

  -- Load saved state
  local saved_state = state.get()
  ui_state.include_patterns = opts.include_patterns or saved_state.last_include or {}
  ui_state.exclude_patterns = opts.exclude_patterns or saved_state.last_exclude or {}
  ui_state.on_search_callback = opts.on_search

  -- Calculate dimensions
  local total_width = opts.width or math.floor(vim.o.columns * 0.9)
  local total_height = opts.height or math.floor(vim.o.lines * 0.9)
  local row = math.floor((vim.o.lines - total_height) / 2)
  local col = math.floor((vim.o.columns - total_width) / 2)

  -- Layout calculations
  local input_section_height = 8  -- 4 windows * 2 (height + border) = 8
  local results_height = total_height - input_section_height
  local results_width = math.floor(total_width * 0.5)
  local preview_width = total_width - results_width - 1  -- -1 for border

  -- Create search pattern buffer
  ui_state.input_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(ui_state.input_buf, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(ui_state.input_buf, "buftype", "")
  vim.api.nvim_buf_set_option(ui_state.input_buf, "modifiable", true)
  vim.api.nvim_buf_set_lines(ui_state.input_buf, 0, -1, false, {opts.default_pattern or ""})

  -- Create include pattern buffer
  ui_state.include_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(ui_state.include_buf, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(ui_state.include_buf, "buftype", "")
  vim.api.nvim_buf_set_option(ui_state.include_buf, "modifiable", true)
  vim.api.nvim_buf_set_lines(ui_state.include_buf, 0, -1, false, {patterns.format_patterns(ui_state.include_patterns)})

  -- Create exclude pattern buffer
  ui_state.exclude_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(ui_state.exclude_buf, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(ui_state.exclude_buf, "buftype", "")
  vim.api.nvim_buf_set_option(ui_state.exclude_buf, "modifiable", true)
  vim.api.nvim_buf_set_lines(ui_state.exclude_buf, 0, -1, false, {patterns.format_patterns(ui_state.exclude_patterns)})

  -- Create options buffer
  ui_state.options_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(ui_state.options_buf, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(ui_state.options_buf, "modifiable", false)

  -- Create main results buffer
  ui_state.main_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(ui_state.main_buf, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(ui_state.main_buf, "filetype", "enhanced-grep")
  vim.api.nvim_buf_set_option(ui_state.main_buf, "modifiable", false)

  -- Create preview buffer
  ui_state.preview_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(ui_state.preview_buf, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(ui_state.preview_buf, "modifiable", false)

  -- Create input windows with proper borders
  -- Search Pattern window
  ui_state.input_win = vim.api.nvim_open_win(ui_state.input_buf, true, {
    relative = "editor",
    width = total_width,
    height = 1,
    row = row,
    col = col,
    style = "minimal",
    border = {"╭", "─", "╮", "│", "╯", "─", "╰", "│"},
    title = " Search Pattern ",
    title_pos = "left",
  })

  -- Include pattern window
  ui_state.include_win = vim.api.nvim_open_win(ui_state.include_buf, false, {
    relative = "editor",
    width = total_width,
    height = 1,
    row = row + 2,  -- +2 for border of previous window
    col = col,
    style = "minimal",
    border = {"╭", "─", "╮", "│", "╯", "─", "╰", "│"},
    title = " Include Patterns ",
    title_pos = "left",
  })

  -- Exclude pattern window
  ui_state.exclude_win = vim.api.nvim_open_win(ui_state.exclude_buf, false, {
    relative = "editor",
    width = total_width,
    height = 1,
    row = row + 4,  -- +2 for each previous window with border
    col = col,
    style = "minimal",
    border = {"╭", "─", "╮", "│", "╯", "─", "╰", "│"},
    title = " Exclude Patterns ",
    title_pos = "left",
  })

  -- Options window
  ui_state.options_win = vim.api.nvim_open_win(ui_state.options_buf, false, {
    relative = "editor",
    width = total_width,
    height = 1,
    row = row + 6,  -- +2 for each previous window with border
    col = col,
    style = "minimal",
    border = {"╭", "─", "╮", "│", "╯", "─", "╰", "│"},
  })

  -- Create results window (left side, below input section)
  ui_state.main_win = vim.api.nvim_open_win(ui_state.main_buf, false, {
    relative = "editor",
    width = results_width,
    height = results_height,
    row = row + input_section_height,
    col = col,
    style = "minimal",
    border = {"╭", "─", "┬", "│", "╰", "─", "┴", "│"},
    title = " Results ",
    title_pos = "center",
  })

  -- Create preview window (right side, below input section)
  ui_state.preview_win = vim.api.nvim_open_win(ui_state.preview_buf, false, {
    relative = "editor",
    width = preview_width,
    height = results_height,
    row = row + input_section_height,
    col = col + results_width + 1,
    style = "minimal",
    border = {"┬", "─", "╮", "│", "┴", "─", "╯", "│"},
    title = " Preview ",
    title_pos = "center",
  })

  -- Set window options
  vim.api.nvim_win_set_option(ui_state.main_win, "wrap", false)
  vim.api.nvim_win_set_option(ui_state.main_win, "cursorline", true)
  vim.api.nvim_win_set_option(ui_state.preview_win, "wrap", false)
  vim.api.nvim_win_set_option(ui_state.preview_win, "number", true)

  -- Set initial highlight for active input (preserve border and title)
  vim.api.nvim_win_set_option(ui_state.input_win, "winhl",
    "Normal:EnhancedGrepActiveInput,FloatBorder:FloatBorder,FloatTitle:FloatTitle")
  vim.api.nvim_win_set_option(ui_state.include_win, "winhl",
    "Normal:EnhancedGrepInactiveInput,FloatBorder:FloatBorder,FloatTitle:FloatTitle")
  vim.api.nvim_win_set_option(ui_state.exclude_win, "winhl",
    "Normal:EnhancedGrepInactiveInput,FloatBorder:FloatBorder,FloatTitle:FloatTitle")

  -- Set up keymaps for all input buffers
  setup_input_keymaps(ui_state.input_buf)
  setup_input_keymaps(ui_state.include_buf)
  setup_input_keymaps(ui_state.exclude_buf)

  -- Set up main buffer keymaps
  local main_keymaps = {
    {"n", "<CR>", M.jump_to_match, {desc = "Jump to match"}},
    {"n", "<Right>", M.toggle_fold, {desc = "Expand/collapse fold"}},
    {"n", "<Left>", M.toggle_fold, {desc = "Expand/collapse fold"}},
    {"n", "za", M.toggle_fold, {desc = "Toggle fold"}},
    {"n", "zR", M.expand_all, {desc = "Expand all"}},
    {"n", "zM", M.collapse_all, {desc = "Collapse all"}},
    {"n", "i", function()
      vim.api.nvim_set_current_win(ui_state.input_win)
      vim.cmd("startinsert!")
      update_input_highlights()
      vim.schedule(function() vim.cmd("redraw") end)
    end, {desc = "Edit search"}},
    {"n", "<F1>", M.toggle_no_tests, {desc = "Toggle no tests filter"}},
    {"n", "<F2>", M.toggle_ruby_only, {desc = "Toggle Ruby only"}},
    {"n", "<F3>", M.toggle_case_sensitive, {desc = "Toggle case sensitive"}},
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

  vim.api.nvim_create_autocmd({"TextChanged", "TextChangedI"}, {
    buffer = ui_state.include_buf,
    callback = trigger_search_debounced,
  })

  vim.api.nvim_create_autocmd({"TextChanged", "TextChangedI"}, {
    buffer = ui_state.exclude_buf,
    callback = trigger_search_debounced,
  })

  -- Set up autocmd for preview updates
  vim.api.nvim_create_autocmd({"CursorMoved"}, {
    buffer = ui_state.main_buf,
    callback = function()
      vim.schedule(M.update_preview_from_cursor)
    end,
  })

  -- Set up autocmd for focus changes to update highlights
  local focus_group = vim.api.nvim_create_augroup("EnhancedGrepFocus", { clear = true })
  vim.api.nvim_create_autocmd({"WinEnter", "BufEnter"}, {
    group = focus_group,
    callback = function()
      if ui_state.input_win then
        update_input_highlights()
      end
    end,
  })

  -- Render initial state
  render_options()
  M.render_results({})
  update_preview(nil, nil)
  update_input_highlights()

  -- Start in insert mode
  vim.cmd("startinsert!")

  return ui_state.input_buf, ui_state.main_buf
end

-- Setup highlights on load
setup_highlights()

return M