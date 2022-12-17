local M = {}

local strtobool = setmetatable({ ["v:true"] = true, ["true"] = true, ["1"] = true }, {
  __index = function()
    return false -- default: false
  end,
})

function M.create()
  -- send string
  vim.api.nvim_create_user_command("TidalSend", function(opts)
    require("tidal").send(opts.args)
  end, { nargs = 1, desc = "Send string", force = false })

  -- start supercollider and superdirt
  vim.api.nvim_create_user_command("TidalStartSuperDirt", function()
    require("tidal").start_superdirt()
  end, { nargs = 0, desc = "Start supercollider and superdirt", force = false })

  -- start tidalcycles
  vim.api.nvim_create_user_command("TidalStart", function(opts)
    require("tidal").start(strtobool[opts.fargs[1]], strtobool[opts.fargs[2]], strtobool[opts.fargs[3]])
  end, { nargs = "*", desc = "Start tidalcycles", force = false })

  -- stop tidalcycles and supercollider
  vim.api.nvim_create_user_command("TidalStop", function(opts)
    require("tidal").stop(strtobool[opts.fargs[1]])
  end, { nargs = "?", desc = "Stop tidalcycles and supercollider", force = false })

  -- stop sc
  vim.api.nvim_create_user_command("TidalStopSc", function()
    require("scnvim").stop()
  end, { nargs = 0, desc = "Stop supercollider", force = false })

  -- send string to supercollider
  vim.api.nvim_create_user_command("TidalSendSc", function(opts)
    require("scnvim").send(opts.args)
  end, { nargs = 1, desc = "Send string to supercollider", force = false })

  -- load samples
  vim.api.nvim_create_user_command("TidalLoadSamples", function(opts)
    require("scnvim").send(string.format([[~dirt.loadSoundFiles("%s");]], opts.args))
  end, { nargs = 1, desc = "Load folder with samples", force = false })
end

return M
