# Themify

![A screenshot of Themify](./documents/assets/screenshot.jpg)

A lightweight colorscheme manager and switcher inspired by [Themery.nvim](https://github.com/zaldih/themery.nvim) and [Lazy.nvim](https://github.com/folke/lazy.nvim).

- 🎨 Easily install and manage your colorschemes!
- 🔍 Switch between colorschemes with a live preview!
- ⚡️ Optimized startup time with lazy-loaded colorschemes!

> [!NOTE]
> Planning on a rewrite to introduce a job-based system and a more flexible UI system.

## 📦 Installation

> [!WARNING]
> Requirements: `Neovim >= 0.10`, `Git`

Use the package manager of your choice to install Themify:

- [Lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  'lmantw/themify.nvim',
    
  lazy = false,
  priority = 999,

  config = {}
}
```

- [Packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'lmantw/themify.nvim',

  config = {}
}
```

<details>
  <summary>Manual Installation</summary>

  ```lua
  local themify_path = vim.fs.joinpath(vim.fn.stdpath('data'), 'themify')
  
  if not vim.loop.fs_stat(themify_path) then
    vim.fn.system({
      'git', 'clone',
      'https://github.com/LmanTW/themify.nvim.git',
      themify_path,
    })
  end
  
  vim.opt.rtp:prepend(themify_path)

  require('themify').setup()
  ```
</details>

## 🛠 Configuration

To configure Themify, call the `setup` function (or use the `config` option in your package manager) and add the colorschemes you want to install/manage:

```lua
require('themify').setup({
  -- Your list of colorschemes.

  'folke/tokyonight.nvim',
  'sho-87/kanagawa-paper.nvim',
  {
    'comfysage/evergarden',

    branch = 'mega'
  },

  -- Built-in colorschemes are also supported.
  -- (Also works with any colorschemes that are installed via other plugin manager, just make sure the colorscheme is loaded before Themify is loaded.)
  'default'
})
```

> [!IMPORTANT]
> The colorschemes will not be installed automatically, please use the `:Themify` command to open the menu then press `I` to install all the colorschemes.

<details>
  <summary>Advance Configuration</summary>

  ```lua
  require('themify').setup({
    async = false,
    -- Enabling this would load the colorscheme asynchronously, which might improve your startup time.

    activity = false,
    -- Enabling this would track your colorscheme usage activity.

    {
      'folke/tokyonight.nvim',

      branch = 'main',

      before = function(theme)
        -- The function run before the colorscheme is loaded.
      end,
      after = function(theme)
        -- The function run after the colorscheme is loaded.
      end,

      -- A colorscheme can have multiple themes, you can use the options below to only show the themes you want.
      whitelist = {'tokyonight-night', 'tokyonight-day'},
      blacklist = {}
    },

    -- The loader loads the colorscheme on startup, you can use the option below to replace it with a custom one.
    loader = function()
      -- Custom loader logic...
    end
  })
  ```
</details>

## 📚 Snippets

You can extend the functionality of Themify by using short snippets of code. You can find snippets in the [Snippet Library](./documents/snippet.md) or write your own using the [Publci API](./documents/api.md) Themify provides.

> [!TIP]
> You can also request or add snippets to the [Snippet Library](./documents/snippet.md) by opening an issue!

## 📎 Other

- [API Reference](./documents/api.md)
- [Highlight Groups](./documents/highlight.md)

<a href="https://star-history.com/#LmanTW/themify.nvim&Date">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=LmanTW/themify.nvim&type=Date&theme=dark"/>
    <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=LmanTW/themify.nvim&type=Date"/>
    <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=LmanTW/themify.nvim&type=Date"/>
  </picture>
</a>
