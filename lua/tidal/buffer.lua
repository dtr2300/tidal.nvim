local M = {}

-- strip comments, whitespace at the end
---@param s string
---@return string
function M.strip(s)
  s = s:gsub("%-%-.*$", ""):gsub("%s+$", "")
  return s
end

-- collect lines by searching forward or backward in the paragraph
---@param lines table<number, string>
---@param row number
---@param step number
---@return table<number, string>, number
function M.getlines(lines, row, step)
  repeat
    local line = vim.fn.getline(row + step)
    local cline = line:gsub("^%s+", "")
    if cline ~= "" then
      line = M.strip(line)
      if line ~= "" then
        table.insert(lines, step > 0 and #lines + 1 or 1, line)
      end
      row = row + step
    end
  until cline == ""
  return lines, row
end

-- flash range of lines in current buffer
---@param start_row number
---@param end_row number
function M.flash(start_row, end_row)
  local ns = vim.api.nvim_create_namespace "tidal_flash"
  vim.highlight.range(
    0,
    ns,
    require("tidal").config.highlight,
    { start_row - 1, 0 },
    { end_row - 1, 100000 },
    { inclusive = true }
  )
  vim.defer_fn(function()
    vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
  end, 200)
end

return M
