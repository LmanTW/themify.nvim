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
colorschemes
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

# Event

> [!NOTE]
> The corresponding module is `themify.core.event`.

## listen()

```
--- Listen to an event.
--- @param event string
--- @param callback function
--- @return nil
Themify.Event.listen(<event>, <callback>)
```

### List of all the events

| Event                     | Description                                   | Arguments        |
| ---                       | ---                                           | ---              |
| colorscheme-state-updated | When the state of the colorscheme is updated. | (colorscheme_id) |
| colorscheme-installed     | When a colorscheme is installed.              | (colorscheme_id) |
| colorscheme-updated       | When a colorscheme is updated.                | (colorscheme_id) |
| interface-open            | When an interface is opened.                  | (window)         |
| interface-close           | When an interface is closed.                  | ()               |
| interface-update          | When an interface is being updated.           | ()
