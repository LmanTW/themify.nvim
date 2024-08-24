# Themify
A lightweight colorscheme manager for [Neovim](https://neovim.io) written in [Lua](https://www.lua.org). Inspired by [Themery.nvim](https://github.com/zaldih/themery.nvim) and [Lazy.nvim](https://github.com/folke/lazy.nvim).

> [!WANRING]
> Still in early development, the plugin **Will Not Work** (For now).

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
The configuration is really easy and stright forward, just call the setup function and add the colorschemes you want to install / manage:

```lua
require("themery").setup({
  -- Your list of colorschemes.

  'Yazeed1s/minimal.nvim',
  'folke/tokyonight.nvim'
})
```

> [!IMPORTANT]
> The colorschemes will not be installed automatically due to performance considerations. Please use the command `:Themify` to open the interface, then press `I` to install all the colorschemes.

<details>
    <summary>Advance Configuration</summary>

    You can use advance
</details> 
