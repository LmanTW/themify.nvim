--- @class Colorscheme_Info
--- @field repository string
--- @field branch string
--- @field config? function
--- @field whitelist? string[]

--- @class Colorscheme_Data
--- @field name string
--- @field status 'unknown'|'not_installed'|'installed'|'installing'|'updating'|'failed'
--- @field progress number 
--- @field info string
--- @field repository string
--- @field branch string
--- @field config? function
--- @field path string
--- @field themes string[]
--- @field whitelist? string[]

local Process = require('themify.core.process')
local Utilities = require('themify.utilities')
local Event = require('themify.core.event')
local Data = require('themify.core.data')

local M = {
  --- @type table<string, Colorscheme_Data>
  colorschemes_data = {}
}

--- Get The Name Of The Colorscheme 
--- @param repository string
--- @return string
local function get_colorscheme_name (repository)
  local chunks = Utilities.split(repository, '/')

  assert(#chunks == 2, table.concat({'Themify: Invalid repository name "', repository, '"'}))

  return chunks[2]
end

--- Get Colorscheme Repository
--- @param colorscheme_name string
--- @return string|nil
local function get_colorscheme_repository (colorscheme_name)
  for colorscheme_repository, colorscheme_data in pairs(M.colorschemes_data) do
    if colorscheme_data.name == colorscheme_name then
      return colorscheme_repository
    end
  end
end

--- Add A Colorscheme To Manage
--- @param colorscheme_info Colorscheme_Info
--- @return nil
function M.add_colorscheme(colorscheme_info)
  local colorscheme_name = get_colorscheme_name(colorscheme_info.repository)

  M.colorschemes_data[colorscheme_info.repository] = {
    name = colorscheme_name,
    status = 'unknown',

    progress = 0,
    info = '',

    repository = colorscheme_info.repository,
    branch = colorscheme_info.branch,
    config = colorscheme_info.config,

    path = table.concat({Data.colorschemes_path, colorscheme_name}, '/'),
    themes = {},
    whitelist = colorscheme_info.whitelist
  }
end

--- Clean Unused Colorschemes
--- @return nil
function M.clean_colorschemes()
  local lock_data = Data.read_lock_data()

  local colorschemes = Utilities.split(Utilities.execute(table.concat({'ls', Data.colorschemes_path}, ' ')), '\n')
  local colorscheme_repository

  for i = 1, #colorschemes do
    colorscheme_repository = get_colorscheme_repository(colorschemes[i])

    if colorscheme_repository == nil -- The colorschemes is not being used.
      or lock_data.colorschemes[colorscheme_repository] == nil -- The colorscheme is not in the lock file.
      or M.colorschemes_data[colorscheme_repository].branch ~= lock_data.colorschemes[colorscheme_repository].branch -- The repository is a different branch.
      or #Utilities.split(Utilities.execute(table.concat({'ls', table.concat({Data.colorschemes_path, get_colorscheme_name(colorscheme_repository)}, '/')}, ' ')), '\n') < 2 -- The clone is not complete.
    then
      local path = table.concat({Data.colorschemes_path, colorschemes[i]}, '/')

      os.execute(table.concat({'chmod -R +w', path}, ' '))
      os.execute(table.concat({'rm -r', path}, ' '))

      lock_data.colorschemes[colorschemes[i]] = nil
    end
  end

  Data.write_lock_data(lock_data)
end

--- Check The Colorschemes
--- @return nil
function M.check_colorschemes()
  M.clean_colorschemes()

  for colorscheme_repository in pairs(M.colorschemes_data) do
    M.check_colorscheme(colorscheme_repository)
  end
end

--- Check A Colorscheme
--- @param colorscheme_repository string
--- @return nil
function M.check_colorscheme(colorscheme_repository)
  local colorscheme_data = M.colorschemes_data[colorscheme_repository]

  if colorscheme_data.status ~= 'installing' then
    colorscheme_data.status = Utilities.is_path_exist(colorscheme_data.path) and 'installed' or 'not_installed'

    if colorscheme_data.status == 'installed' then
      local theme_files = Utilities.split(Utilities.execute(table.concat({'ls', table.concat({colorscheme_data.path, 'colors'}, '/')}, ' ')), '\n')
      local name

      colorscheme_data.themes = {}

      for i = 1, #theme_files do
        name = Utilities.split(theme_files[i], '.')[1]

        if colorscheme_data.whitelist == nil or Utilities.contains(colorscheme_data.whitelist, {name}) then
          colorscheme_data.themes[i] = name
        end
      end
    end
  end
end

--- Install The Colorschemes
--- @return nil
function M.install_colorschemes()
  M.check_colorschemes()

  for colorscheme_repository, colorscheme_data in pairs(M.colorschemes_data) do
    if colorscheme_data.status == 'not_installed' then
      Event.call('update')

      colorscheme_data.status = 'installing'
      colorscheme_data.progress = 0
      colorscheme_data.info = 'Fetching...'

      local output

      local process = Process:new(
        Data.colorschemes_path, 'git',
        {'clone', table.concat({'https://github.com/', colorscheme_data.repository}), '-b', colorscheme_data.branch, '--filter=blob:none', '--progress'},
        function(code)
          Event.call('update')

          colorscheme_data.status = code == 0 and 'installed' or 'failed'
          colorscheme_data.progress = 0
          colorscheme_data.info = code == 0 and '' or Utilities.split(output, '\n')[1]

          if code == 0 then
            Process.execute(colorscheme_data.path, 'git', {'rev-parse', 'HEAD'}, function(_, stdout)
              local data = Data.read_lock_data()

              data.colorschemes[colorscheme_data.repository] = { branch = colorscheme_data.branch, commit = Utilities.split(stdout, '\n')[1] }

              Data.write_lock_data(data)
            end)

            M.check_colorscheme(colorscheme_repository)
          end
        end
      )

      process:on_stderr(function(data)
        M.last_update_timestamp = os.time()

        if (string.sub(data, 0, 24) == 'Counting objects') then
          colorscheme_data.info = 'Counting Objects...'
        elseif string.sub(data, 0, 27) == 'Compressing objects' then
          colorscheme_data.info = 'Compressing Objects...'
        elseif (string.sub(data, 0, 17)) == 'Receiving objects' then
          colorscheme_data.progress = tonumber(string.sub(data, 20, 22):match('^%s*(.-)%s*$')) or 0
          colorscheme_data.info = 'Receiving Objects...'
        elseif (string.sub(data, 0, 16) == 'Resolving deltas') then
          colorscheme_data.info = 'Resolving Deltas...'
        end

        output = data
      end)
    end
  end
end

--- Update The Colorschemes
--- @return nil
function M.update_colorschemes()
  M.check_colorschemes()

  for colorscheme_repository, colorscheme_data in pairs(M.colorschemes_data) do
    if colorscheme_data.status == 'installed' then
      Event.call('update')

      colorscheme_data.status = 'updating'
      colorscheme_data.progress = 0
      colorscheme_data.info = 'Fetching...'

      Process.execute(colorscheme_data.path, 'git', {'fetch', 'origin'}, function(code, _, stderr)
        Event.call('update')

        if code ~= 0 then
          colorscheme_data.status = 'failed'
          colorscheme_data.progress = 0
          colorscheme_data.info = Utilities.split(stderr, '\n')[1]
        else
          local lock_data = Data.read_lock_data()
          local commit = Utilities.split(Utilities.execute(table.concat({'cd', colorscheme_data.path, '&&', 'git rev-parse', table.concat({'origin', '/', colorscheme_data.branch})}, ' ')), '\n')[1]

          colorscheme_data.progress = 25
          colorscheme_data.info = 'Checking Out...'

          Process.execute(colorscheme_data.path, 'git', {'checkout', '--', '.'}, function()
            if commit == lock_data.colorschemes[colorscheme_repository].commit then
              colorscheme_data.status = 'installed'
              colorscheme_data.progress = 0
              colorscheme_data.info = 'Up To Date'
            else
              colorscheme_data.progress = 50
              colorscheme_data.info = 'Pulling...'

              local output

              local process = Process:new(
                colorscheme_data.path, 'git',
                {'pull', 'origin', colorscheme_data.branch, '--progress'},
                function (code2)
                  Event.call('update')

                  colorscheme_data.status = code2 == 0 and 'installed' or 'failed'
                  colorscheme_data.progress = 0
                  colorscheme_data.info = code2 == 0 and '' or Utilities.split(output, '\n')[1]

                  lock_data = Data.read_lock_data()

                  lock_data.colorschemes[colorscheme_repository].commit = commit

                  Data.write_lock_data(lock_data)
                end
              )

              process:on_stdout(function(data)
                output = data
              end)
            end
          end)
        end
      end)
    end
  end
end

return M
