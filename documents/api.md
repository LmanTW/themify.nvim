# API Documentation

Themify exposes an API that allows developers to interact with the Themify core.

* [Themify](#themify)
  * [colorschemes_data](#colorschemes_data)
  * [colorschemes_repository](#colorschemes_repository)
* [add_colorscheme()](#add_colorscheme)
  * [load_theme()](#load_theme)
  * [clean_colorschemes()](#clean_colorschemes)
  * [check_colorschemes()](#check_colorschemes)
  * [check_colorscheme()](#check_colorscheme)
  * [install_colorschemes()](#install_colorschemes)
  * [install_colorscheme()](#install_colorscheme)
  * [update_colorschemes()](#update_colorschemes)
  * [update_colorscheme()](#update_colorscheme)
  * [listen()](#listen)
* [Types](#types)
  * [Colorscheme_Info](#colorscheme_info)
  * [Colorscheme_Data](#colorscheme_data)

# Themify

```lua
local Themify = require('themify')
```

## colorschemes_data

```lua
--- A table of colorscheme data.
Themify.colorschemes_data
```

* `table<string, Colorscheme_Data>`

## colorscheme_repository

```lua
--- A list of the repositories of the colorschemes in order.
Themify.colorscheme_repository
```

* `string[]`

## add_colorscheme()

```lua
--- Add a colorscheme to manage.
Themify.add_colorscheme(<colorscheme_id>, <colorscheme_info>)
```

* `colorscheme_id: string` | The id the colorscheme. `Example: 'folke/tokyonight.nvim' or 'default'`
* `colorscheme_info: Colorscheme_Info` | The info of the colorscheme.

## load_theme()

```lua
--- Load a theme.
Themify.load_theme(<colorscheme_id>, <theme>)
```

* `colorscheme_id: string` | The id of the colorscheme. `Example: 'folke/tokyonight.nvim' or 'default'`
* `theme: string` | The theme. `Example: tokyonight-night

## clean_colorschemes()

```lua
--- Clean unused colorschemes.
Themify.clean_colorschemes()
```

## check_colorschemes()

```lua
--- Check the colorschemes (update the state, themes of the colorschemes).
Themify.check_colorschemes()
```

## check_colorscheme()

```lua
--- Check a colorscheme (update the state, themes of the colorscheme).
Themify.check_colorscheme(<colorscheme_id>)
```

* `colorscheme_id: string` | The id of the colorscheme. `Example: 'folke/tokyonight.nvim' or 'default'`

## install_colorschemes()

```lua
--- Install the colorschemes.
Themify.install_colorschemes()
```

## install_colorscheme()

```lua
--- Install a colorscheme.
Themify.install_colorscheme(<colorscheme_id>)
```

* `colorscheme_id: string` | The id of the colorscheme. `Example: 'folke/tokyonight.nvim' or 'default'`

## update_colorschemes()

```lua
--- Update the colorschemes.
Themify.update_colorschemes()
```

## update_colorscheme()

```lua
--- Update a colorscheme.
Themify.update_colorscheme(<colorscheme_repository>)
```
* `colorscheme_repository: string` | The repository of the colorscheme. `Example: 'folke/tokyonight.nvim' or 'default'`

## listen()

```lua
--- Listen to an event.
Themify.listen(<event>, <callback>)
```

* `event: string` | The name of the event.
* `calblack: string` | The callback of the listener.

### Events

* `update` | When something is updated that requires an interface update.
* `state_update` | When the state of any of the colorscheme is updated.

# Types

Some type annotations for Themify.

## Colorscheme_Info

```lua
--- @class Colorscheme_Info
--- @field branch string
--- @field before? function
--- @field after? function
--- @field whitelist? string[]
--- @field blacklist? string[]
```

## Colorscheme_Data

```lua
--- @class Colorscheme_Data
--- @field type 'github'|'local'
--- @field name string
--- @field status 'unknown'|'not_installed'|'installed'|'installing'|'updating'|'failed'
--- @field progress number
--- @field info string
--- @field branch string
--- @field before? function
--- @field after? function
--- @field themes string[]
--- @field whitelist? string[]
--- @field blacklist? string[]
--- @field path string
```
