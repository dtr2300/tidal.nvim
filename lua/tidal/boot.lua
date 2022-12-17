local M = {}

---@param name string
---@return string|nil
local function read_file(name)
  local f = io.open(name, "rb")
  local content
  if f ~= nil then
    content = f:read "*all"
    f:close()
  end
  return content
end

---@return string|nil
local function get_plugin_path()
  local dirs = vim.api.nvim_list_runtime_paths()
  for i = 1, #dirs do
    if string.find(dirs[i], "tidal.nvim") then
      return dirs[i]:gsub("\\", "/")
    end
  end
  return nil
end

M.plugin_path = get_plugin_path()
if M.plugin_path == nil then
  vim.notify("can't find plugin path", 4, { title = "tidal.nvim" })
end

---@param name string
---@return string|nil
function M.get_file(name)
  local key_name = name:gsub("%.", "_")
  local content

  if require("tidal").config.boot[key_name] == nil then
    -- use internal file
    if M.plugin_path ~= nil then
      local filename = M.plugin_path .. "/boot/" .. name
      content = read_file(filename)
    end
  else
    -- use user file
    local filename = require("tidal").config.boot[key_name]
    if filename ~= nil then
      content = read_file(filename)
    end
  end

  if content == nil then
    vim.notify("missing file " .. name, 4, { title = "tidal.nvim" })
  end
  return content
end

M.start_midi_scd_params = [[
(
~tidal_midi_in = %s;
~nvim_midi_in = %s;
~tidal_midi_out = %s;
)
]]

return M
