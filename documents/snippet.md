# 📚 Snippet Library

- [Randomized Theme](#Randomize-theme)

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
