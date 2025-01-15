# 🔌 API Reference

Themify provides a public API that allows developers to integrate and interact with Themify using a simplified interface. If you want to do more advanced integration consider using the internal API.

## Example

```lua
local Themify = require('themify.api')
```

## Content

- [get_current()](#get_current)
- [set_current()](#set_current)
- [Manager](#manager)
  - [colorschemes](#colorschemes)
  - [get()](#get)
  - [add()](#add)
  - [clean()](#clean)
  - [install()](#install)
  - [update()](#update)
- [Activity](#activity)
  - [get()](#get-1)
- [Event](#event)
  - [listen()](#listen)

# Themify

```lua
local Themify = require('themify.api')
```

## get_current()

```lua
--- Get the current colorscheme.
--- @return vim.NIL|{ colorscheme_id: nil|string, theme: string }
Themify.get_current()
```

## set_current()

```lua
--- Set the current colorscheme.
--- @param colorscheme_id nil|string
--- @param theme string
--- @return nil
Themify.set_current(<colorscheme_id>, <theme>)

--- Example
Themify.set_current('folke/tokyonight.nvim', 'tokyonight-night')
Themify.set_current(nil, 'default')
```

# Manager

> [!NOTE]
> The corresponding module is `themify.core.manager`.

## colorschemes

```lua
--- A list of id of the colorschemes in order.
--- @type string[]
Themify.Manager.colorschemes
```

## get()

```lua
--- Get a colorscheme.
--- @param colorscheme_id string
--- @return Colorscheme_Data
Themify.Manager.get(<colorscheme_id>)

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

--- Example
Themify.Manager.get('folke/tokyonight.nvim')
```

## add()

```lua
--- Add a colorscheme to manage.
--- @param colorscheme_source string
--- @param colorscheme_info Colorscheme_Info
--- @return nil
Themify.Manager.add(<colorscheme_source>, <colorscheme_info>)

--- @class Colorscheme_Info
--- @field branch? string
--- @field before? function
--- @field after? function
--- @field whitelist? string[]
--- @field blacklist? string[]

--- Example
Themify.Manager.add('folke/tokyonight.nvim', {
  whitelist = {'tokyonight-night', 'tokyonight-day'}
})
```

## clean()

```lua
--- Clean unused colorschemes.
--- @return nil
Themify.Manager.clean()
```

## install()

```lua
--- Install the colorschemes.
--- @return nil
Themify.Manager.install()
```

## update()

```lua
--- Update the colorschemes.
--- @return nil
Themify.Manager.update()
```

# Activity

> [!NOTE]
> The corresponding module is `themify.core.activity`.

```lua
--- Get the activity of a skin.
--- @param colorscheme nil|string
--- @param theme string
--- @return nil|{ last_active: number, total_minutes: number, today_minutes: number }
Themify.Activity.get(<colorscheme>, <theme>)

--- Example
Themify.Activity.get('folke/tokyonight.nvim', 'tokyonight-night')
Themify.Activity.get(nil, 'default')
```

# Event

> [!NOTE]
> The corresponding module is `themify.core.event`.

## listen()

```lua
--- Listen to an event.
--- @param event string
--- @param callback function
--- @return nil
Themify.Event.listen(<event>, <callback>)
```

### List of all the events

| Event                     | Description                                   | Arguments        |
| ---                       | ---                                           | ---              |
| colorscheme-state-updated | When the state of a colorscheme is updated.   | (colorscheme_id) |
| colorscheme-installed     | When a colorscheme is installed.              | (colorscheme_id) |
| colorscheme-updated       | When a colorscheme is updated.                | (colorscheme_id) |
| activity-update           | When the activity is updated.                 | ()               |
| interface-open            | When an interface is opened.                  | (window)         |
| interface-close           | When an interface is closed.                  | ()               |
| interface-update          | When the interfaces are being updated.        | ()               |
