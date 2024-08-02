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

    local info = {
      state = nil,
      progress = nil,
      progress_info = nil
    }

    if type(colorscheme) == 'string' then
      info.name = get_colorscheme_name(colorscheme)
      info.repository = colorscheme
      info.branch = 'main'
    elseif type(colorscheme) == 'table' then
      if type(colorscheme[1]) == 'string' then
        info.name = get_colorscheme_name(colorscheme[1])
        info.repository = colorscheme[1]
        info.branch = type(colorscheme.branch) == 'string' and colorscheme.branch or 'master'

        info.config = type(colorscheme.config) == 'function' and colorscheme.config or nil
      end
    end

    if M.colorschemes_info[info.repository] ~= nil then
      error('Themify: Duplicate colorscheme "' .. info.repository .. '"')
    end

    info.path = table.concat({Data.colorschemes_path, info.name}, '/')

    M.colorschemes_info[info.name] = info
  end
end

-- Clean The Colorscheme Data
local function clean_colorscheme_data(data)
  for colorscheme_name in pairs(data.colorschemes) do
    if data.colorschemes[colorscheme_name] == nil then
      data.colorschemes[colorscheme_name] = nil
    end
  end

  return data
end

-- Check The Colorschemes
function M.check_colorschemes()
  Data.check_data_files()

  local data = Data.read_data()

  local colorschemes = Utilities.split(Utilities.execute(table.concat({'ls', Data.colorschemes_path}, ' ')), '\n')

  -- Remove unused colorschemes.

  local name

  for i = 1, #colorschemes do
    name = colorschemes[i]

    if M.colorschemes_info[name] == nil -- The colorschemes is not being used.
      or data.colorschemes[name] == nil -- The colorscheme is not in the data file.
      or M.colorschemes_info[name].branch ~= data.colorschemes[name].branch -- The colorscheme is a different branch.
      or #Utilities.split(Utilities.execute(table.concat({'ls', table.concat({Data.colorschemes_path, name}, '/')}, ' ')), '\n') < 2 -- The clone is not complete.
    then
      local path = table.concat({Data.colorschemes_path, name}, '/')

      os.execute(table.concat({'chmod -R +w', path}, ' '))
      os.execute(table.concat({'rm -r', path}, ' '))
    end
  end

  -- Check the state of the colorschemes.

  for _, info in pairs(M.colorschemes_info) do
    if info.state ~= 'installing' then
      info.state = Data.path_exist(info.path) and 'installed' or 'not_installed'

      if info.state == 'installed' then
        info.themes = Utilities.split(Utilities.execute(table.concat({'ls', table.concat({info.path, 'colors'}, '/')}, ' ')), '\n')

        for i = 1, #info.themes do
          info.themes[i] = Utilities.split(info.themes[i], '.')[1]
        end
      end
    end
  end

  return data
end

-- Install The Colorschemes
function M.install_colorschemes()
  M.check_colorschemes()

  for _, colorscheme_info in pairs(M.colorschemes_info) do
    if colorscheme_info.state == 'not_installed' then
      M.tasks = M.tasks + 1

      M.install_colorscheme(colorscheme_info, function(success)
        if success then
          local data = clean_colorscheme_data(Data.read_data())

          data.colorschemes[colorscheme_info.name] = { branch = colorscheme_info.branch }

          for name in pairs(data.colorschemes) do
            if M.colorschemes_info[name] == nil then
              data.colorschemes[name] = nil
            end
          end

          Data.write_data(data)
        end

        M.tasks = M.tasks - 1
      end)
    end
  end
end

-- Install A Colorscheme
function M.install_colorscheme(info, callback)
  info.state = 'installing'
  info.progress = 0
  info.progress_info = 'Fetching'

  -- Create the colorscheme directory.

  os.execute(table.concat({'mkdir', info.path}, ' '))

  -- Run the git clone command.

  local process
  local error

  process = Process:new(
    'git',
    {'clone', table.concat({'https://github.com/', info.repository}), info.path, '-b', info.branch, '--filter=blob:none', '--progress'},

    function (code)
      info.state = code == 0 and 'installed' or 'install_failed'
      info.progress = nil
      info.progress_info = code == 0 and nil or Utilities.split(error, '\n')[1]

      -- Remove the colorscheme directory if the clone failed.

      if code == 0 then
        info.themes = Utilities.split(Utilities.execute(table.concat({'ls', table.concat({info.path, 'colors'}, '/')}, ' ')), '\n')
      else
        os.execute(table.concat({'rm -R', info.path}, ' '))
      end

      callback(code == 0)
    end
  )

  process:on_stderr(function (data)
    if (string.sub(data, 0, 24) == 'Counting objects') then
      info.progress_info = 'Counting Objects'
    elseif string.sub(data, 0, 27) == 'Compressing objects' then
      info.progress_info = 'Compressing Objects'
    elseif (string.sub(data, 0, 17)) == 'Receiving objects' then
      info.progress = tonumber(string.sub(data, 20, 22):match('^%s*(.-)%s*$'))
      info.progress_info = 'Receiving Objects'
    elseif (string.sub(data, 0, 16) == 'Resolving deltas') then
      info.progress_info = 'Resolving deltas'
    end

    error = data
  end)
end

return M
