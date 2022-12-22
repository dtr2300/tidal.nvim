local M = {}

local default_config = {
  boot = {
    -- nil means use internal file
    boot_ghci = nil, -- filename used for starting tidalcycles
    start_superdirt_scd = nil, -- filename used for starting supercollider and superdirt
    start_midi_scd = nil, -- filename used for starting midi in / out
  },
  commands = true, -- create vim commands
  highlight = "TidalEval", -- highlight group used for flashing
  osc = {
    addr = "127.0.0.1", -- nvim osc server address
    port = 9000, -- nvim osc server port
  },
  plenary = false, -- add filetype to plenary (for telescope.nvim)
  terminal = {
    id = 1, -- toggleterm terminal id
    direction = "horizontal", -- layout of the terminal
    size = 10, -- width or height of the terminal
  },
}

---@param user_config? table
---@return table
function M.merge(user_config)
  user_config = user_config or {}
  return vim.tbl_deep_extend("keep", user_config, default_config)
end

return M
