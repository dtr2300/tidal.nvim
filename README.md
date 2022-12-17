# tidal.nvim

[Neovim](https://neovim.io/) plugin for [TidalCycles](https://tidalcycles.org/). Extracted from my config, WIP

## Install

Required plugins:

- [scnvim](https://github.com/davidgranstrom/scnvim)
- [osc.nvim](https://github.com/davidgranstrom/osc.nvim)
- [toggleterm.nvim](https://github.com/akinsho/toggleterm.nvim)

### With [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use { 
    "dtr2300/tidal.nvim",
    requires = {
        "davidgranstrom/scnvim",
        "davidgranstrom/osc.nvim",
        "akinsho/toggleterm.nvim",
    },
    config = function()
        require("tidal").setup {
            -- user configuration
        }
    end,
}
```
