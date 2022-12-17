local M = {}

local terminal_id = 1
local job_id = nil

---@param user_config? table
function M.setup(user_config)
  M.config = require("tidal.config").merge(user_config)
  terminal_id = M.config.terminal_id
  if M.config.plenary then
    require("plenary.filetype").add_file "tidal"
  end
  if M.config.commands then
    require("tidal.commands").create()
  end
end

-- send a string or list of strings
---@param obj string|table<number,string>
function M.send(obj)
  if job_id == nil then
    return
  end
  vim.validate {
    obj = { obj, { "string", "table" }, false },
  }

  if type(obj) == "string" then
    obj = vim.split(obj, "\n")
  end

  if obj[#obj] ~= "" then
    table.insert(obj, "")
  end

  vim.fn.chansend(job_id, obj)
end

-- send a line or paragraph in the current buffer
-- * trailing comments and whitespace are removed
-- * multiple lines are wrapped in :{ :}
---@param send_paragraph? boolean
function M.send_buf(send_paragraph)
  if job_id == nil then
    return
  end
  vim.validate {
    send_paragraph = { send_paragraph, "boolean", true },
  }
  send_paragraph = send_paragraph == nil or send_paragraph

  -- get the first line
  local start_row, _ = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.fn.getline(start_row)
  if line:gsub("^%s+", "") == "" then
    return
  end
  line = require("tidal.buffer").strip(line)
  local lines = line ~= "" and { line } or {}
  local end_row = start_row

  -- get rest of the paragraph
  if send_paragraph then
    lines, start_row = require("tidal.buffer").getlines(lines, start_row, -1)
    lines, end_row = require("tidal.buffer").getlines(lines, end_row, 1)
  end

  -- anything left?
  if #lines == 0 then
    return
  end

  -- wrap
  if #lines > 1 then
    table.insert(lines, 1, ":{")
    table.insert(lines, ":}")
  end

  -- send
  M.send(lines)

  -- flash
  vim.schedule(function()
    require("tidal.buffer").flash(start_row, end_row)
  end)
end

-- start supercollider and superdirt
function M.start_superdirt()
  local start_superdirt_scd = require("tidal.boot").get_file "start_superdirt.scd"
  if start_superdirt_scd ~= nil then
    if not require("scnvim").is_running() then
      require("scnvim").start()
    end
    require("scnvim").send(start_superdirt_scd)
  end
end

-- start tidalcycles (superdirt must be running)
---@param tidal_midi_in? boolean
---@param nvim_midi_in? boolean
---@param tidal_midi_out? boolean
function M.start(tidal_midi_in, nvim_midi_in, tidal_midi_out)
  vim.validate {
    tidal_midi_in = { tidal_midi_in, "boolean", true },
    nvim_midi_in = { nvim_midi_in, "boolean", true },
    tidal_midi_out = { tidal_midi_out, "boolean", true },
  }
  tidal_midi_in = tidal_midi_in or false
  nvim_midi_in = nvim_midi_in or false
  tidal_midi_out = tidal_midi_out or false

  if job_id == nil then
    local boot_ghci = require("tidal.boot").get_file "boot.ghci"
    if boot_ghci == nil then
      return
    end

    require("toggleterm").exec("ghci", terminal_id, 10, nil, "horizontal", false, true)
    local term = require("toggleterm.terminal").get(terminal_id)
    if term ~= nil then
      job_id = term.job_id

      M.send(boot_ghci)

      vim.cmd.stopinsert { bang = true }
      vim.cmd.normal { "G", bang = true }
      vim.cmd.wincmd "p"

      if nvim_midi_in then
        if require("tidal.oscserver").is_running() then
          vim.notify("osc server is already running", 3, { title = "tidal.nvim" })
        else
          require("tidal.oscserver").start()
        end
      end

      if tidal_midi_in or nvim_midi_in or tidal_midi_out then
        local start_midi_scd = require("tidal.boot").get_file "start_midi.scd"
        if start_midi_scd == nil then
          return
        end
        local params = string.format(
          require("tidal.boot").start_midi_scd_params,
          tostring(tidal_midi_in),
          tostring(nvim_midi_in),
          tostring(tidal_midi_out)
        )
        require("scnvim").send(params)
        require("scnvim").send(start_midi_scd)
      end
    end
  end
end

-- stop tidalcycles and supercollider
---@param stop_sclang? boolean
function M.stop(stop_sclang)
  vim.validate {
    stop_sclang = { stop_sclang, "boolean", true },
  }
  stop_sclang = stop_sclang == nil or stop_sclang

  if job_id ~= nil then
    if require("tidal.oscserver").is_running() then
      require("scnvim").send "~stopMidiToOsc.value;"
      require("tidal.oscserver").stop()
    end

    job_id = nil
    require("toggleterm").exec(":quit", terminal_id, nil, nil, nil, false, true)
    vim.defer_fn(function()
      require("toggleterm").exec("exit", terminal_id, nil, nil, nil, false, true)
    end, 50)

    if stop_sclang and require("scnvim").is_running() then
      require("scnvim").stop()
    end
  end
end

return M
