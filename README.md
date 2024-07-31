# Themify
A colorscheme manager for [Neovim](https://neovim.io) written in [Lua](https://www.lua.org), inspired by [Themery.nvim](https://github.com/zaldih/themery.nvim) and [Lazy.nvim](https://github.com/folke/lazy.nvim).

> [!NOTE]
> Still in early development, the plugin **Will Not Work** (For now).

## Features
* 🎨 Easily install and manage your colorschemes.
* 🔍 Quickly switch between colorschemes with a live preview.
* ⚡️ Optimized startup time with lazy-loaded colorschemes.

## Installation
Choose the package manager of your choice to install Theminify:

* [Lazy.nvim](https://github.com/folke/lazy.nvim)
```lua
{
  'lmantw/themify.nvim',
    
  lazy = false,
  priority = 999,

  config = {}
}
```

* [Packer](https://github.com/wbthomason/packer.nvim)
```lua
use {
  'wbthomason/packer.nvim',

  config = {}
}
```

## Configuration
The configuration is really easier and stright forward, just call the setup function and add the colorschemes you want.

```lua
require("themery").setup({
  -- Your list of colorschemes.

  'Yazeed1s/minimal.nvim',

  {
    'folke/tokyonight.nvim',

    config = function()
      -- ...
    end
  }
})
```

> [!IMPORTANT]
> The colorschemes will not be installed automatically due to startup time considerations. Please use the command `:Themify` to open the interface, then press `I` to install all the colorschemes.
