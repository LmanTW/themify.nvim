# 📚 Snippet Library

A library of snippets you can use to extend the functionality of Themify.

- [Randomized Theme](#randomized-theme)
- [Lualine Colorscheme Usage](#lualine-colorscheme-usage)

## Randomized Theme

```lua
local Themify = require('themify.api')

--- Choose your randomize function.
math.randomseed(os.time())               --- Based on startup.
math.randomseed(tonumber(os.date('%m'))) --- Based on month.
math.randomseed(tonumber(os.date('%d'))) --- Based on day.

local colorscheme_id = Themify.Manager.colorschemes[math.random(#Themify.Manager.colorschemes)]
local colorscheme_data = Themify.Manager.get(colorscheme_id)

Themify.set_current(colorscheme_id, colorscheme_data.themes[math.random(#colorscheme_data.themes)])
```

## Lualine Colorscheme Usage

```lua
local Themify = require('themify.api')

local colorscheme = Themify.get_current()
local usage = Themify.Activity.get(colorscheme.colorscheme_id, colorscheme.theme)

--- Update the current colorscheme and usage data when a colorscheme is loaded (switch colorscheme).
Themify.Event.listen('colorscheme-loaded', function(colorscheme_id, theme)
  colorscheme = { colorscheme_id = colorscheme_id, theme = theme }
  usage = Themify.Activity.get(colorscheme_id, theme)
end)

--- Update the usage data when the activity is updated.
Themify.Event.listen('activity-update', function()
  usage = Themify.Activity.get(colorscheme.colorscheme_id, colorscheme.theme)
end)

--- Render the component.
function colorscheme_usage()
  if usage == nil then
    return ''
  else
    return table.concat({usage.today_minutes, ' Minute(s)'})
  end
end

--- Other status line plugins should work similarly to this. 
require('lualine').setup({
  sections = {
    lualine_a = {colorscheme_usage}
  }
})
```
