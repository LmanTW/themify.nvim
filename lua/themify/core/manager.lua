local Process = require('themify.core.process')
local Utilities = require('themify.utilities')
local Data = require('themify.core.data')

local M = {
  colorschemes_info = {},

  tasks = 0
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
function M.add_colorschemes(colorschemes)
  local colorscheme

  for i = 1, #colorschemes do
    colorscheme = colorschemes[i]

    local colorscheme_info = {
      state = nil,
      progress = nil,
      progress_info = nil
    }

    if type(colorscheme) == 'string' then
      colorscheme_info.name = get_colorscheme_name(colorscheme)
      colorscheme_info.repository = colorscheme
    elseif type(colorscheme) == 'table' then
      if type(colorscheme[1]) == 'string' then
        colorscheme_info.name = get_colorscheme_name(colorscheme[1])
        colorscheme_info.repository = colorscheme

        colorscheme_info.config = type(colorscheme.config) == 'function' and colorscheme.config or nil
      end
    end

    if M.colorschemes_info[colorscheme_info.repository] ~= nil then
      error('Themify: Duplicate colorscheme "' .. colorscheme_info.repository .. '"')
    end

    colorscheme_info.path = table.concat({Data.colorschemes_path, colorscheme_info.name}, '/')

    M.colorschemes_info[colorscheme_info.repository] = colorscheme_info
  end
end

-- Check The Colorschemes
function M.check_colorschemes()
  Data.check_data_files()

  for _, colorscheme_info in pairs(M.colorschemes_info) do
    if colorscheme_info.name ~= 'installing' then
      if Data.path_exist(colorscheme_info.path) then
        colorscheme_info.state = 'installed'
      else
        colorscheme_info.state = 'idle'
      end
    end
  end
end

-- Install The Colorschemes
function M.install_colorschemes()
  M.check_colorschemes()

  for _, colorscheme_info in pairs(M.colorschemes_info) do
    if colorscheme_info.state == 'idle' then
      colorscheme_info.state = 'installing'
      colorscheme_info.progress = 0

      M.tasks = M.tasks + 1

      -- Create the colorscheme directory.

      os.execute(table.concat({'mkdir', colorscheme_info.path}, ' '))

      -- Run the git clone command.

      local process
      local error

      process = Process:new(
        'git',
        {'clone', table.concat({'https://github.com/', colorscheme_info.repository}), colorscheme_info.path, '--filter=blob:none', '--progress'},

        function (code)
          M.tasks = M.tasks - 1

          colorscheme_info.state = code == 0 and 'installed' or 'failed'
          colorscheme_info.progress = nil
          colorscheme_info.progress_info = code == 0 and nil or error

          -- Remove the colorscheme directory if the clone failed.

          if code ~= 0 then
            os.execute(table.concat({'rm -R', colorscheme_info.path}, ' '))
          end
        end
      )

      process:on_stderr(function (data)
        if (string.sub(data, 0, 17)) == 'Receiving objects' then
          colorscheme_info.progress = tonumber(string.sub(data, 20, 22):match('^%s*(.-)%s*$'))
          colorscheme_info.progress_info = 'Fetching'
        end

        error = data
      end)
    end
  end
end

return M
