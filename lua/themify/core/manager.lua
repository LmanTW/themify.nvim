--- @class Colorscheme_Info
--- @field branch string
--- @field before? function
--- @field after? function
--- @field whitelist? string[]
--- @field blacklist? string[]

--- @class Colorscheme_Data
--- @field name string
--- @field status 'unknown'|'not_installed'|'installed'|'installing'|'updating'|'failed'
--- @field progress number
--- @field info string
--- @field branch string
--- @field before? function
--- @field after? function
--- @field themes string[]
--- @field whitelist? string[]
--- @field blacklist? string[]
--- @field path string

local Pipeline = require('themify.core.pipeline')
local Process = require('themify.core.process')
local Utilities = require('themify.utilities')
local Tasks = require('themify.core.tasks')
local Event = require('themify.core.event')
local Data = require('themify.core.data')

local M = {
  --- @type table<string, Colorscheme_Data>
  colorschemes_data = {},
  --- @type string[]
  colorschemes_repository = {},

  --- @type string[]
  loaded_colorschemes = {},

  --- @type table<string, number>
  colorschemes_amount = {}
}

--- Get The Name Of The Colorscheme 
--- @param repository string
--- @return string
local function get_colorscheme_name(repository)
  local chunks = vim.split(repository, '/')

  Utilities.error(#chunks ~= 2, {'Themify: Invalid repository name: "', repository, '"'})

  return chunks[2]
end

--- Add A Colorscheme To Manage
--- @param colorscheme_repository string
--- @param colorscheme_info Colorscheme_Info
--- @return nil
function M.add_colorscheme(colorscheme_repository, colorscheme_info)
  Utilities.error(M.colorschemes_data[colorscheme_repository] ~= nil, {'Themify: Duplicate colorscheme: "', colorscheme_repository, '"'})

  local colorscheme_name = get_colorscheme_name(colorscheme_repository)

  M.colorschemes_repository[#M.colorschemes_repository + 1] = colorscheme_repository
  M.colorschemes_data[colorscheme_repository] = {
    name = colorscheme_name,
    status = 'unknown',
    progress = 0,
    info = '',
    branch = colorscheme_info.branch,
    before = colorscheme_info.before,
    after = colorscheme_info.after,
    themes = {},
    whitelist = colorscheme_info.whitelist,
    blacklist = colorscheme_info.blacklist,
    path = table.concat({Data.colorschemes_path, colorscheme_name}, '/')
  }
end

--- Load A Theme
--- @param colorscheme_repository string
--- @param theme string
--- @return nil
function M.load_theme(colorscheme_repository, theme)
  Utilities.error(M.colorschemes_data[colorscheme_repository] == nil, {'Themify: Colorscheme not found: "', colorscheme_repository, '"'})

  local colorscheme_data = M.colorschemes_data[colorscheme_repository]

  if not vim.list_contains(M.loaded_colorschemes, colorscheme_repository) then
    vim.o.runtimepath = table.concat({vim.o.runtimepath, ',', colorscheme_data.path})
  end

  if colorscheme_data.before ~= nil then
    colorscheme_data.before()
  end

  local ok = pcall(vim.cmd.colorscheme, theme)

  if ok then
    if colorscheme_data.after ~= nil then
      colorscheme_data.after()
    end
  end

  return ok
end

--- Get The Repository Of The Colorscheme
--- @param colorscheme_name string
--- @return string|nil
local function get_colorscheme_repository(colorscheme_name)
  for colorscheme_repository, colorscheme_data in pairs(M.colorschemes_data) do
    if colorscheme_data.name == colorscheme_name then
      return colorscheme_repository
    end
  end
end

--- Normalize Branch Name
--- @param branch string
--- @return string
local function normalize_branch(branch)
  return branch == 'master' and 'main' or branch
end

--- Clean Unused Colorschemes
--- @return nil
function M.clean_colorschemes()
  local repository_folders = vim.split(Process.execute(table.concat({'ls', Data.colorschemes_path}, ' ')), '\n')
  local colorscheme_repository

  for i = 1, #repository_folders do
    if repository_folders[i]:len() > 0 then
      colorscheme_repository = get_colorscheme_repository(repository_folders[i])

      if colorscheme_repository == nil
        -- The colorschemes is not being used.
        or not Utilities.path_exist(table.concat({M.colorschemes_data[colorscheme_repository].path, '.git', 'HEAD'}, '/'))
        or normalize_branch(M.colorschemes_data[colorscheme_repository].branch) ~= normalize_branch(Data.read_colorscheme_repository_head(repository_folders[i]).branch)
        -- The repository is on a different branch.
      then
        local colorscheme_path = table.concat({Data.colorschemes_path, repository_folders[i]}, '/')

        os.execute(table.concat({'chmod -R +w', colorscheme_path}, ' '))
        os.execute(table.concat({'rm -rf', colorscheme_path}, ' '))
      end
    end
  end
end

--- The The Colorschemes
function M.check_colorschemes()
  Data.check_data_files()
  M.clean_colorschemes()

  for i = 1, #M.colorschemes_repository do
    M.check_colorscheme(M.colorschemes_repository[i])
  end
end

--- Check A Colorscheme
--- @param colorscheme_repository string
--- @return nil
function M.check_colorscheme(colorscheme_repository)
  local colorscheme_data = M.colorschemes_data[colorscheme_repository]

  Utilities.error(colorscheme_data == nil, {'Themify: Colorscheme not found: "', colorscheme_repository, '"'})

  if colorscheme_data.status ~= 'installing' and colorscheme_data.status ~= 'updating' then
    colorscheme_data.status = Utilities.path_exist(colorscheme_data.path) and 'installed' or 'not_installed' 

    Event.emit('state_update')

    if colorscheme_data.status == 'installed' then
      -- Check the themes under the colorscheme.

      colorscheme_data.themes = {}

      local themes_path = table.concat({colorscheme_data.path, 'colors'}, '/')

      if Utilities.path_exist(themes_path) then
        local theme_files = vim.split(Process.execute(table.concat({'ls', themes_path}, ' ')), '\n')
        local theme_name
        local theme_type

        for i = 1, #theme_files do
          if theme_files[i]:len() > 0 then
            theme_name = string.match(theme_files[i], '([^%.]*)')
            theme_type = string.match(theme_files[i], '%.(.*)')

            if theme_type == 'lua' or theme_type == 'vim' then
              if (colorscheme_data.whitelist == nil or vim.list_contains(colorscheme_data.whitelist, theme_name))
                and (colorscheme_data.blacklist == nil or not vim.list_contains(colorscheme_data.blacklist, theme_name))
              then
                colorscheme_data.themes[#colorscheme_data.themes + 1] = theme_name
              end
            end
          end
        end
      end
    end
  end
end

--- Install The Colorschemes
--- @return nil
function M.install_colorschemes()
  Data.check_data_files()

  for i = 1, #M.colorschemes_repository do
    M.install_colorscheme(M.colorschemes_repository[i])
  end
end

--- Install A Colorscheme
--- @param colorscheme_repository string
--- @return nil
function M.install_colorscheme(colorscheme_repository)
  M.check_colorscheme(colorscheme_repository)

  local colorscheme_data = M.colorschemes_data[colorscheme_repository]

  if colorscheme_data.status == 'not_installed' then
    colorscheme_data.status = 'installing'
    colorscheme_data.progress = 0
    colorscheme_data.info = 'Fetching...'

    Event.emit('update')
    Event.emit('state_update')

    local pipeline = Pipeline:new({
      Tasks.clone(Data.colorschemes_path, colorscheme_repository, colorscheme_data.branch, function(progress, info)
        colorscheme_data.progress = progress
        colorscheme_data.info = info

        Event.emit('update')
      end),
      Tasks.checkout(colorscheme_data.path, colorscheme_data.branch, function()
        colorscheme_data.progress = 100
        colorscheme_data.info = 'Checking Out...'

        Event.emit('update')
      end)
    })

    pipeline:start(function(code, _, stderr)
      colorscheme_data.status = code == 0 and 'installed' or 'failed'
      colorscheme_data.progress = 0
      colorscheme_data.info = code == 0 and '' or vim.split(stderr, '\n')[1]

      Event.emit('update')
      Event.emit('state_update')

      if code == 0 then
        M.check_colorscheme(colorscheme_repository)
      end
    end)
  end
end

--- Update The Colorscheme
--- @return nil
function M.update_colorschemes()
  for i = 1, #M.colorschemes_repository do
    M.update_colorscheme(M.colorschemes_repository[i])
  end
end

--- Update A Colorscheme
--- @param colorscheme_repository string
--- @return nil
function M.update_colorscheme(colorscheme_repository)
  M.check_colorscheme(colorscheme_repository)

  local colorscheme_data = M.colorschemes_data[colorscheme_repository]

  if colorscheme_data.status == 'installed' then
    colorscheme_data.status = 'updating'
    colorscheme_data.progress = 0
    colorscheme_data.info = 'Fetching...'

    Event.emit('update')
    Event.emit('state_update')

    M.check_colorscheme_commit(colorscheme_repository, function(error, local_commit, remote_commit)
      Event.emit('update')

      if error ~= nil then
        colorscheme_data.status = 'failed'
        colorscheme_data.progress = 0
        colorscheme_data.info = error

        Event.emit('state_update')
      else
        if local_commit == remote_commit then
          colorscheme_data.status = 'installed'
          colorscheme_data.progress = 0
          colorscheme_data.info = 'Up To Date'

          Event.emit('state_update')
        else
          local pipeline = Pipeline:new({
            Tasks.reset(colorscheme_data.path, colorscheme_data.branch, function()
              Event.emit('update')

              colorscheme_data.progress = 25
              colorscheme_data.info = 'Reseting...'
            end),
            Tasks.pull(colorscheme_data.path, colorscheme_data.branch, function()
              Event.emit('update')

              colorscheme_data.progress = 50
              colorscheme_data.info = 'Pulling..'
            end)
          })

          pipeline:start(function(code, _, stderr)
            colorscheme_data.status = code == 0 and 'installed' or 'failed'
            colorscheme_data.progress = 0

            if code == 0 then 
              colorscheme_data.info = table.concat({'Updated ', local_commit:sub(0, 7), ' -> ', remote_commit:sub(0, 7)})
            else
              colorscheme_data.info = vim.split(stderr, '\n')[1]
            end

            Event.emit('state_update')
            Event.emit('update')
          end)
        end
      end
    end)
  end
end

--- Check The Commit Of The Colorscheme
--- @param colorscheme_repository string
--- @param callback function
--- @return nil 
function M.check_colorscheme_commit(colorscheme_repository, callback)
  local colorscheme_data = M.colorschemes_data[colorscheme_repository]
  local local_commit, remote_commit

  local pipeline = Pipeline:new({
    Tasks.fetch(colorscheme_data.path, colorscheme_data.branch),
    Tasks.get_commit(colorscheme_data.path, 'HEAD', function(commit_hash)
      local_commit = commit_hash
    end),
    Tasks.get_commit(colorscheme_data.path, table.concat({'origin', colorscheme_data.branch}, '/'), function(commit_hash)
      remote_commit = commit_hash
    end)
  })

  pipeline:start(function(code, _, stderr)
    if code == 0 then
      return callback(nil, local_commit, remote_commit)
    else
      return callback(vim.split(stderr, '\n')[1])
    end
  end)
end

--- Count Colorscheme Amount
--- @return nil
function M.count_colorscheme_amount()
  M.colorschemes_amount = {}
  local status

  for i = 1, #M.colorschemes_repository do
    status = M.colorschemes_data[M.colorschemes_repository[i]].status

    M.colorschemes_amount[status] = M.colorschemes_amount[status] == nil and 1 or M.colorschemes_amount[status] + 1
  end
end

M.count_colorscheme_amount()
Event.listen('state_update', M.count_colorscheme_amount)

return M
