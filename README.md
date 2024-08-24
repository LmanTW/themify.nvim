# Themify
A lightweight colorscheme designed manager for [Neovim](https://neovim.io) written in [Lua](https://www.lua.org). Inspired by [Themery.nvim](https://github.com/zaldih/themery.nvim) and [Lazy.nvim](https://github.com/folke/lazy.nvim).

> [!WARNING]
> Still in early development, the plugin **May Not Work** (For now).

## ✨ Features
* 🎨 Easily install and manage your colorschemes.
* 🔍 Quickly switch between colorschemes with a live preview.
* ⚡️ Optimized startup time with lazy-loaded colorschemes.

## 📦 Installation
Use the package manager of your choice to install Theminify:

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
  'lmantw/themify.nvim',

  config = {}
}
```

## 🛠 Configuration
The configuration for Themify is really easy and stright forward, just call the `setup` function or use the `config` option in your package manager, and add the colorschemes you want to install / manage:

```lua
require("themery").setup({
  -- Your list of colorschemes.

  'folke/tokyonight.nvim',
  'sho-87/kanagawa-paper.nvim',
  {
    'Yazeed1s/minimal.nvim'

    config = function()
      vim.g.minimal_italic_functions = true
      vim.g.minimal_italic_comments = true
    end
  }
})
```

> [!IMPORTANT]
> The colorschemes will not be installed automatically due to performance considerations. Please use the command `:Themify` to open the interface, then press `I` to install all the colorschemes.

<details>
  <summary>Advance Configuration</summary>

  ```lua
    {
      'folke/tokyonight.nvim',

      config = function()
        -- The function run after the colorscheme is loaded.
      end,

      -- A colorscheme can have multiple themes, you can use the option below to only show the themes you want.

      whitelist = {},
      blacklist = {} -- Not implemented yet.
    }
  ```
</details> 
