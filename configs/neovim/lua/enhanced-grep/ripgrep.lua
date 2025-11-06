-- Ripgrep wrapper and execution
local patterns = require("enhanced-grep.patterns")
local M = {}

--- Build ripgrep command with options
--- @param search_pattern string Pattern to search for
--- @param opts table Options for ripgrep
--- @return table Command array
function M.build_command(search_pattern, opts)
  local cmd = {"rg"}

  -- Output format
  table.insert(cmd, "--json")
  table.insert(cmd, "--heading")
  table.insert(cmd, "--with-filename")
  table.insert(cmd, "--line-number")
  table.insert(cmd, "--column")

  -- Case sensitivity
  if not opts.case_sensitive then
    table.insert(cmd, "--ignore-case")
  end

  -- Respect .gitignore
  if opts.use_gitignore then
    table.insert(cmd, "--hidden")
  else
    table.insert(cmd, "--no-ignore")
  end

  -- Follow symlinks
  table.insert(cmd, "--follow")

  -- Context lines
  if opts.context_before then
    table.insert(cmd, "-B")
    table.insert(cmd, tostring(opts.context_before))
  end
  if opts.context_after then
    table.insert(cmd, "-A")
    table.insert(cmd, tostring(opts.context_after))
  end

  -- Add include/exclude patterns
  local pattern_args = patterns.to_ripgrep_args(
    opts.include_patterns,
    opts.exclude_patterns
  )
  vim.list_extend(cmd, pattern_args)

  -- Add the search pattern
  table.insert(cmd, search_pattern)

  -- Add search path
  table.insert(cmd, opts.search_path or ".")

  return cmd
end

--- Parse ripgrep JSON output
--- @param line string Single line of JSON output
--- @return table|nil Parsed match data
local function parse_json_line(line)
  local ok, data = pcall(vim.json.decode, line)
  if not ok then
    return nil
  end
  return data
end

--- Group matches by file
--- @param raw_results table Raw ripgrep results
--- @return table Results grouped by file
local function group_by_file(raw_results)
  local grouped = {}
  local file_order = {}

  for _, result in ipairs(raw_results) do
    if result.type == "match" then
      local file = result.data.path.text

      if not grouped[file] then
        grouped[file] = {
          path = file,
          matches = {},
        }
        table.insert(file_order, file)
      end

      table.insert(grouped[file].matches, {
        line_number = result.data.line_number,
        column = result.data.submatches[1] and result.data.submatches[1].start or 0,
        text = result.data.lines.text,
        submatches = result.data.submatches,
      })
    end
  end

  -- Convert to ordered array
  local ordered = {}
  for _, file in ipairs(file_order) do
    table.insert(ordered, grouped[file])
  end

  return ordered
end

--- Execute ripgrep and parse results
--- @param search_pattern string Pattern to search for
--- @param opts table Search options
--- @param callback function Callback with results
function M.search(search_pattern, opts, callback)
  local cmd = M.build_command(search_pattern, opts)
  local raw_results = {}
  local stderr_output = {}

  -- Execute ripgrep
  local handle
  handle = vim.loop.spawn(cmd[1], {
    args = vim.list_slice(cmd, 2),
    stdio = {nil, vim.loop.new_pipe(false), vim.loop.new_pipe(false)},
  }, function(code, signal)
    handle:close()

    -- Process results
    if code == 0 or code == 1 then
      -- Code 1 means no matches found, which is fine
      local grouped = group_by_file(raw_results)
      callback({
        success = true,
        results = grouped,
        total_files = #grouped,
        total_matches = #raw_results,
      })
    else
      callback({
        success = false,
        error = table.concat(stderr_output, "\n"),
        code = code,
      })
    end
  end)

  if not handle then
    callback({
      success = false,
      error = "Failed to spawn ripgrep process",
    })
    return
  end

  -- Read stdout (JSON results)
  local stdout = handle:get_stdio()[2]
  if stdout then
    stdout:read_start(function(err, data)
      if err then
        table.insert(stderr_output, "Error reading stdout: " .. err)
      elseif data then
        -- Process each line of JSON
        for line in data:gmatch("[^\r\n]+") do
          local parsed = parse_json_line(line)
          if parsed then
            table.insert(raw_results, parsed)
          end
        end
      end
    end)
  end

  -- Read stderr (errors)
  local stderr = handle:get_stdio()[3]
  if stderr then
    stderr:read_start(function(err, data)
      if err then
        table.insert(stderr_output, "Error reading stderr: " .. err)
      elseif data then
        table.insert(stderr_output, data)
      end
    end)
  end
end

--- Execute ripgrep synchronously
--- @param search_pattern string Pattern to search for
--- @param opts table Search options
--- @return table Results
function M.search_sync(search_pattern, opts)
  local cmd = M.build_command(search_pattern, opts)
  local cmd_string = table.concat(vim.tbl_map(function(arg)
    if arg:match(" ") then
      return string.format('"%s"', arg)
    end
    return arg
  end, cmd), " ")

  local output = vim.fn.system(cmd_string)
  local exit_code = vim.v.shell_error

  if exit_code ~= 0 and exit_code ~= 1 then
    return {
      success = false,
      error = output,
      code = exit_code,
    }
  end

  -- Parse JSON output
  local raw_results = {}
  for line in output:gmatch("[^\r\n]+") do
    local parsed = parse_json_line(line)
    if parsed then
      table.insert(raw_results, parsed)
    end
  end

  local grouped = group_by_file(raw_results)
  return {
    success = true,
    results = grouped,
    total_files = #grouped,
    total_matches = #raw_results,
  }
end

return M
