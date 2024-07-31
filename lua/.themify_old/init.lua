local Colorschemes = require('themify.core.colorschemes')

local M = {}

-- Setup Themify
function M.setup(colorschemes)
  if colorschemes ~= nil then
    if type(colorschemes) ~= 'table' then
      print('Themify: "colorschemes" must be a "table"')

      return
    end

    Colorschemes.add(colorschemes)

    -- Use the lua command so the interface don't need to get loaded when the plugin first loads.
    vim.cmd('command! Themify lua require("themify.commands").open()')
  end
end

return M
