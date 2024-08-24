local Utilities = require('themify.utilities')
local Data = require('themify.core.data')

local M = {
  colorscheme_path = nil,
  theme = nil,

  --- @type string[]
  loaded_colorschemes = {}
}

--- Load The State
function M.load_state()
  local lock_data = Data.read_lock_data()

  if lock_data.state ~= nil then
    M.load_theme(lock_data.state.colorscheme_path, lock_data.state.theme)
  end
end

--- Load A Theme
--- @class Colorscheme
--- @param theme string
function M.load_theme(colorscheme_path, theme)
  if not Utilities.contains(vim.api.nvim_list_runtime_paths(), {colorscheme_path}) then
    vim.o.runtimepath = table.concat({vim.o.runtimepath, ',', colorscheme_path})
  end

  vim.cmd.colorscheme(theme)
end

return M
