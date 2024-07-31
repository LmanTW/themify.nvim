local Process = require('themify.core.process')
local Utilities = require('themify.utilities')

local M = {
  data_path = vim.fn.stdpath('data') .. '/themify',

  colorschemes_info = {},

  installing = 0
}

-- Get The Colorscheme Name
local function get_colorscheme_name (repository)
  local chunks, size = Utilities.split(repository, '/')

  if size ~= 2 then
    error('Themify: Invalid repository name "' .. repository .. '"')
  end

  return chunks[2]
end

-- Add Colorschemes
function M.add(colorschemes)
  for _, colorscheme in ipairs(colorschemes) do
    if type(colorscheme) == 'string' then
      table.insert(M.colorschemes_info, {
        state = nil,
        progress = nil,

        name = get_colorscheme_name(colorscheme),
        repository = colorscheme,

        config = nil
      })
    elseif type(colorscheme) == 'table' then
      if type(colorscheme[1]) == 'string' then
        table.insert(M.colorschemes_info, {
          state = nil,
          progress = nil,

          name = type(colorscheme.name) == 'string' and colorscheme.name or get_colorscheme_name(colorscheme[1]),

          repository = colorschemes[1],

          config = type(colorscheme.config) == 'function' and colorscheme.config or nil
        })
      end
    end
  end
end

-- Check If A Path Exist
local function path_exist(path)
  local stats = vim.loop.fs_stat(path)

  return stats ~= nil
end

-- Check Colorschemes
function M.check()
  if not path_exist(M.data_path .. '/colorschemes') then
    os.execute('mkdir ' .. M.data_path .. '/colorschemes')
  end

  for _, colorscheme_info in pairs(M.colorschemes_info) do
    local repository_name = Utilities.split(colorscheme_info.repository, '/')[2]

    if path_exist(M.data_path .. '/colorschemes/' .. repository_name) then
      colorscheme_info.state = 'installed'
    else
      colorscheme_info.state = 'idle'
    end
  end
end

-- Install
function M.install()
  M.check()

  for _, colorscheme_info in pairs(M.colorschemes_info) do
    if colorscheme_info.state == 'idle' then
      local repository_name = Utilities.split(colorscheme_info.repository, '/')[2]

      if not path_exist(M.data_path .. '/colorschemes/' .. repository_name) then
        os.execute('mkdir ' .. M.data_path .. '/colorschemes/' .. repository_name)
      end

      M.installing = M.installing + 1

      colorscheme_info.state = 'installing'

      local process = Process:new('git', {'clone', 'https://github.com/' .. colorscheme_info.repository, M.data_path .. '/colorschemes/' .. repository_name, '--progress'}, function(code, signal)

      end)

      process.stderr:read_start(function(_, data)
        colorscheme_info.progress = data
      end)
    end
  end
end

return M
