local Utilities = require('themify.utilities')
local Config = require('themify.config')
local Git = require('themify.core.git')

local M = {}

local data_path = vim.fn.stdpath('data') .. '/themify'
local data = {}

local themes_info = {}

-- Check The Data Files
function M.check()
  Utilities.check_path(data_path, function()
    os.execute('mkdir ' .. data_path)
  end)

  Utilities.check_path(data_path .. '/themes', function()
    os.execute('mkdir ' .. data_path .. '/themes')
  end)

  Utilities.check_path(data_path .. '/data.json', function()
    Utilities.write_file(data_path .. '/data.json', '{}')
  end)
end

-- Load The Data And Themes Info
function M.load(config)
  local file = io.open(data_path .. '/data.json', 'r')

  if file == nil then
    print('Themify: Cannot Load The Data')

    return
  end

  local json = file:read('*all')

  data = vim.json.decode(json)

  for _, theme_name in pairs(Config.normalize_theme_list(config.themes)) do
    if os.execute("[ -e '" .. data_path .. '/themes/' .. theme_name .. "' ]") == 0 then
      themes_info[theme_name] = { state = "installed" }
    else
      themes_info[theme_name] = { state = "not_installed" }
    end
  end
end

-- Get Themes Info
function M.get_themes_info()
  return themes_info
end

-- Ensure The Themes Are Installed 
function M.ensure_installed(themes)
  for _, theme in pairs(themes) do
    Utilities.check_path(data_path .. '/themes/' .. theme, function ()
      local handle, stdout, stderr = Git.clone(data_path .. '/themes', theme)

      stdout:read_start(function(error, log)
        assert(not error, error)

        if data then print(log) end
      end)

      stderr:read_start(function(error, log)
        assert(not error, error)

        if data then print(log) end
      end)
    end)
  end
end

return M
