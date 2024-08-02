local Manager = require('themify.core.manager')
local Data = require('themify.core.data')

local M = {}

local loaded_colorschemes = {}

-- Load A Colorscheme
function M.load_colorscheme(name, theme)
  if loaded_colorschemes[name] == nil then
    -- Check the colorscheme and theme exists.

    local colorscheme_info = Manager.colorschemes_info[name]

    if colorscheme_info == nil or not Data.path_exist(table.concat({colorscheme_info.path, 'colors', table.concat({theme, 'lua'}, '.')}, '/')) then
      return false
    end

    -- Load the colorscheme.

    vim.o.runtimepath = table.concat({vim.o.runtimepath, colorscheme_info.path}, ',')

    if colorscheme_info.config ~= nil then
      colorscheme_info.config()
    end

    loaded_colorschemes[name] = true
  end

  vim.cmd(table.concat({'colorscheme', theme}, ' '))

  return true
end

return M
