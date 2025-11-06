-- Enhanced Grep - Main entry point
local ripgrep = require("enhanced-grep.ripgrep")
local ui = require("enhanced-grep.ui")
local state = require("enhanced-grep.state")
local presets = require("enhanced-grep.presets")
local patterns = require("enhanced-grep.patterns")

local M = {}

-- Plugin configuration
M.config = {
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
}

--- Setup plugin with user configuration
--- @param user_config table|nil User configuration
function M.setup(user_config)
  M.config = vim.tbl_deep_extend("force", M.config, user_config or {})

  -- Update default state with config
  local current_state = state.get()
  state.update(vim.tbl_extend("force", current_state, M.config.defaults))

  -- Create user commands
  vim.api.nvim_create_user_command("EnhancedGrep", function(opts)
    M.grep(opts.args)
  end, {
    nargs = "?",
    desc = "Enhanced grep search",
    complete = function()
      return {}
    end,
  })

  vim.api.nvim_create_user_command("EnhancedGrepNoTests", function(opts)
    M.grep_no_tests(opts.args)
  end, {
    nargs = "?",
    desc = "Enhanced grep search (exclude tests)",
  })

  vim.api.nvim_create_user_command("EnhancedGrepPreset", function(opts)
    M.grep_with_preset(opts.fargs[1], opts.fargs[2])
  end, {
    nargs = "+",
    desc = "Enhanced grep with preset",
    complete = function(arg_lead, cmdline, cursor_pos)
      local args = vim.split(cmdline, "%s+")
      if #args == 2 then
        -- Complete preset names
        local preset_keys = presets.get_ordered_keys()
        return vim.tbl_filter(function(key)
          return key:match("^" .. vim.pesc(arg_lead))
        end, preset_keys)
      end
      return {}
    end,
  })
end

--- Build search options from state
--- @param overrides table|nil Option overrides
--- @return table Search options
local function build_search_opts(overrides)
  local current = state.get()
  local opts = {
    case_sensitive = current.case_sensitive,
    use_gitignore = current.use_gitignore,
    include_patterns = current.last_include or {},
    exclude_patterns = current.last_exclude or {},
    search_path = current.search_path or ".",
    context_before = current.context_before or 0,
    context_after = current.context_after or 0,
  }

  if overrides then
    opts = vim.tbl_extend("force", opts, overrides)
  end

  return opts
end

--- Prompt user for search pattern and options
--- @param callback function Callback with pattern and options
local function prompt_search(callback, default_pattern)
  -- Input prompt for search pattern
  vim.ui.input({
    prompt = "Search pattern: ",
    default = default_pattern or state.get().last_search or "",
  }, function(pattern)
    if not pattern or pattern == "" then
      return
    end

    -- Input for include patterns
    vim.ui.input({
      prompt = "Include patterns (space-separated): ",
      default = patterns.format_patterns(state.get().last_include or {}),
    }, function(include_str)
      -- Input for exclude patterns
      vim.ui.input({
        prompt = "Exclude patterns (space-separated): ",
        default = patterns.format_patterns(state.get().last_exclude or {}),
      }, function(exclude_str)
        local include_pats = patterns.parse_patterns(include_str or "")
        local exclude_pats = patterns.parse_patterns(exclude_str or "")

        -- Update state
        state.update({
          last_search = pattern,
          last_include = include_pats,
          last_exclude = exclude_pats,
        })

        callback(pattern, {
          include_patterns = include_pats,
          exclude_patterns = exclude_pats,
        })
      end)
    end)
  end)
end

--- Execute search and display results
--- @param pattern string Search pattern
--- @param opts table Search options
local function execute_search(pattern, opts)
  -- Show loading message
  vim.notify("Searching for: " .. pattern, vim.log.levels.INFO)

  -- Build search options
  local search_opts = build_search_opts(opts)

  -- Execute search
  ripgrep.search(pattern, search_opts, function(result)
    vim.schedule(function()
      if not result.success then
        vim.notify("Search failed: " .. (result.error or "Unknown error"), vim.log.levels.ERROR)
        return
      end

      if #result.results == 0 then
        vim.notify("No matches found", vim.log.levels.WARN)
        return
      end

      -- Add to history
      state.add_to_history(pattern, search_opts.include_patterns, search_opts.exclude_patterns)

      -- Display results in floating window
      ui.create_results_window(result.results, {
        width = math.floor(vim.o.columns * M.config.window.width),
        height = math.floor(vim.o.lines * M.config.window.height),
      })
    end)
  end)
end

--- Main grep function with interactive prompts
--- @param pattern string|nil Optional pattern to search for
function M.grep(pattern)
  if pattern and pattern ~= "" then
    -- Direct search with pattern
    execute_search(pattern, {})
  else
    -- Interactive mode
    prompt_search(function(pat, opts)
      execute_search(pat, opts)
    end)
  end
end

--- Grep excluding test files
--- @param pattern string|nil Optional pattern to search for
function M.grep_no_tests(pattern)
  local test_excludes = {
    "/test/*",
    "/tests/*",
    "/spec/*",
    "/__tests__/*",
    "*_test.*",
    "*_spec.*",
    "test_*.*",
    "*.test.*",
    "*.spec.*",
  }

  if pattern and pattern ~= "" then
    execute_search(pattern, {exclude_patterns = test_excludes})
  else
    prompt_search(function(pat, opts)
      -- Merge with test excludes
      local exclude_pats = vim.list_extend(vim.deepcopy(test_excludes), opts.exclude_patterns or {})
      opts.exclude_patterns = exclude_pats
      execute_search(pat, opts)
    end)
  end
end

--- Grep with a preset
--- @param preset_key string Preset key
--- @param pattern string|nil Optional pattern to search for
function M.grep_with_preset(preset_key, pattern)
  local preset = presets.get(preset_key)
  if not preset then
    vim.notify("Preset not found: " .. preset_key, vim.log.levels.ERROR)
    return
  end

  local opts = {
    include_patterns = preset.include,
    exclude_patterns = preset.exclude,
  }

  if pattern and pattern ~= "" then
    execute_search(pattern, opts)
  else
    prompt_search(function(pat, _)
      execute_search(pat, opts)
    end, "")
  end
end

--- Grep for word under cursor
function M.grep_word()
  local word = vim.fn.expand("<cword>")
  if word == "" then
    vim.notify("No word under cursor", vim.log.levels.WARN)
    return
  end

  M.grep(word)
end

--- Grep for word under cursor (no tests)
function M.grep_word_no_tests()
  local word = vim.fn.expand("<cword>")
  if word == "" then
    vim.notify("No word under cursor", vim.log.levels.WARN)
    return
  end

  M.grep_no_tests(word)
end

--- Repeat last search
function M.repeat_last()
  local last = state.get().last_search
  if not last or last == "" then
    vim.notify("No previous search", vim.log.levels.WARN)
    return
  end

  execute_search(last, {})
end

--- Select from preset list
function M.select_preset()
  local all_presets = presets.get_all()
  local preset_keys = presets.get_ordered_keys()

  local items = {}
  for _, key in ipairs(preset_keys) do
    local preset = all_presets[key]
    if preset then
      table.insert(items, {
        key = key,
        display = string.format("%s - %s", preset.name, preset.description or ""),
      })
    end
  end

  vim.ui.select(items, {
    prompt = "Select preset:",
    format_item = function(item)
      return item.display
    end,
  }, function(choice)
    if choice then
      M.grep_with_preset(choice.key)
    end
  end)
end

return M
