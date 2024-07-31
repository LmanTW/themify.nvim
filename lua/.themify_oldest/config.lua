local Utilities = require('themify.utilities')

local M = {}

M.default_config = {
  themes = {}
}

-- Check The Type Of A Data
local function check_data (name, intended_type, data)
  if type(data) ~= intended_type then
    error('"' .. name.. '" Must Be The Type "' .. intended_type .. '"')
  end
end

-- Check The Configuration
function M.check(config)
  check_data('config.themes', 'table', config.themes)

  for index, theme in pairs(config.themes) do
    check_data('config.themes.' .. index, 'string', theme)
  end
end

-- Normalize Theme List
function M.normalize_theme_list(themes)
  local normalized_theme_list = {}

  for _, theme in pairs(themes) do
    table.insert(normalized_theme_list, Utilities.split(theme, '/')[2])
  end

  return normalized_theme_list
end

return M
