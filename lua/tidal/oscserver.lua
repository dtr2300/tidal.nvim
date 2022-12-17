local M = {}

local osc = nil

-- map: midi note -> tidal string/list of strings or lua function
M.oscmap = {
  [36] = [[d1 $ s "cpu*4"]],
  [40] = "hush",
  [41] = function()
    vim.api.nvim_feedkeys("{", "t", false)
  end,
  [42] = function()
    vim.api.nvim_feedkeys("}", "t", false)
  end,
  [43] = function()
    require("tidal").send_buf()
  end,
}

-- is the server running?
---@return boolean
function M.is_running()
  return osc ~= nil
end

-- start nvim osc server
function M.start()
  osc = require("osc").new {
    transport = "udp",
    recvAddr = require("tidal").config.osc.addr,
    recvPort = require("tidal").config.osc.port,
  }

  osc:add_handler("/note", function(data)
    local cmd = require("tidal.oscserver").oscmap[tonumber(data.message[1])]
    if cmd ~= nil then
      vim.schedule(function()
        if type(cmd) == "function" then
          cmd()
        else
          require("tidal").send(cmd)
        end
      end)
    end
  end)

  osc:open()
end

-- stop nvim osc server
function M.stop()
  osc:close()
  osc = nil
end

return M
