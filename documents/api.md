# 🛠 API Documentation

Themify exposes an API that allows developers to easialy interact with thThemify.

- [Themify](#themify)
  - [colorschemes_data](#colorschemes_data)
  - [colorschemes_repository](#colorschemes_repository)
  - [add_colorscheme(colorscheme_source, colorscheme_info)](#add_colorschemecolorscheme_source-colorscheme_info)
  - [load_theme(colorscheme_id, theme)](#load_themecolorscheme_id-theme)
  - [clean_colorschemes()](#clean_colorschemes)
  - [check_colorschemes()](#check_colorschemes)
  - [check_colorscheme(colorscheme_id)](#check_colorschemecolorscheme_id)
  - [install_colorschemes()](#install_colorschemes)
  - [install_colorscheme(colorscheme_id)](#install_colorschemecolorscheme_id)
  - [update_colorschemes()](#update_colorschemes)
  - [update_colorscheme(colorscheme_repository)](#update_colorschemecolorscheme_repository)
  - [listen(event, callback)](#listenevent-callback)
  - [read_state_data()](#read_state_data)
  - [write_state_data(data)](#write_state_datadata)
- [Types](#types)
  - [Colorscheme_Info](#colorscheme_info)
  - [Colorscheme_Data](#colorscheme_data)
  - [Repository](#repository)
  - [State_Data](#state_data)

# Themify

```lua
local Themify = require('themify.api')
```

## colorschemes_data

```lua
--- A table of colorscheme data.
Themify.colorschemes_data
```

- `table<string, Colorscheme_Data>`

## colorscheme_id

```lua
--- A list of the id of the colorschemes in order.
Themify.colorscheme_id
```

- `string[]`

## add_colorscheme(colorscheme_source, colorscheme_info)

```lua
--- Add a colorscheme to manage.
Themify.add_colorscheme(<colorscheme_source>, <colorscheme_info>)
```

- `colorscheme_source: string` | The source the colorscheme. `Example: 'folke/tokyonight.nvim' or 'default'`
- `colorscheme_info: Colorscheme_Info` | The info of the colorscheme.

## load_theme(colorscheme_id, theme)

```lua
--- Load a theme.
Themify.load_theme(<colorscheme_id>, <theme>)
```

- `colorscheme_id: string` | The id of the colorscheme. `Example: 'folke/tokyonight.nvim' or 'default'`
- `theme: string` | The theme. `Example: tokyonight-night

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

## check_colorscheme(colorscheme_id)

```lua
--- Check a colorscheme. (Update the state, themes of the colorscheme)
Themify.check_colorscheme(<colorscheme_id>)
```

- `colorscheme_id: string` | The id of the colorscheme. `Example: 'folke/tokyonight.nvim' or 'default'`

## install_colorschemes()

```lua
--- Install the colorschemes.
Themify.install_colorschemes()
```

## install_colorscheme(colorscheme_id)

```lua
--- Install a colorscheme.
Themify.install_colorscheme(<colorscheme_id>)
```

- `colorscheme_id: string` | The id of the colorscheme. `Example: 'folke/tokyonight.nvim' or 'default'`

## update_colorschemes()

```lua
--- Update the colorschemes.
Themify.update_colorschemes()
```

## update_colorscheme(colorscheme_repository)

```lua
--- Update a colorscheme.
Themify.update_colorscheme(<colorscheme_repository>)
```
- `colorscheme_repository: string` | The repository of the colorscheme. `Example: 'folke/tokyonight.nvim' or 'default'`

## listen(event, callback)

```lua
--- Listen to an event.
Themify.listen(<event>, <callback>)
```

- `event: string` | The name of the event.
- `calblack: string` | The callback of the listener.

### Events

- `window_update` | When the window is being updated.
- `state_update` | When the state of any colorscheme is being updated.
- `theme_load` | When a theme is being loaded.

## read_state_data()

```lua
--- Read the state data.
Themify.read_state_data()
```

> Return `<State_Data>`

## write_state_data(data)

```lua
--- Write the state data.
Themify.write_state_data(<data>)
```

- `data: State_Data` | The state data.

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
--- @field type 'remote'|'local'
--- @field status 'unknown'|'not_installed'|'installed'|'installing'|'updating'|'failed'
--- @field repository? Repository
--- @field progress number
--- @field info string
--- @field before? function
--- @field after? function
--- @field themes string[]
--- @field whitelist? string[]
--- @field blacklist? string[]
--- @field path string
```

## Repository

```lua
--- @class Repository
--- @field source string
--- @field author string
--- @field name string
--- @field branch string
```

## State_Data

```lua
--- @alias State_Data vim.NIL|{ colorscheme_id: string, theme: string }
```
