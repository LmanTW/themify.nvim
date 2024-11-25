--- @class Colorscheme_Info
--- @field branch string
--- @field before? function
--- @field after? function
--- @field whitelist? string[]
--- @field blacklist? string[]

--- @class Colorscheme_Data
--- @field type 'remote'|'local'
--- @field status 'unknown'|'not_installed'|'installed'|'installing'|'updating'|'failed'
--- @field repository? Repository
--- @field progress number
--- @field info string
--- @field before? function
--- @field after? function
--- @field themes string[]
--- @field whitelist? string[]
--- @field blacklist? string[]
--- @field path string

--- @class Repository
--- @field source string
--- @field author string
--- @field name string
--- @field branch string

local Pipeline = require('themify.core.pipeline')
local Utilities = require('themify.utilities')
local Tasks = require('themify.core.tasks')
local Event = require('themify.core.event')
local Data = require('themify.core.data')

local M = {
  --- @type table<string, Colorscheme_Data>
  colorschemes_data = {},
  --- @type string[]
  colorschemes_id = {},

  --- @type string[]
  loaded_colorschemes = {},
  --- @type table<string, number>
  colorschemes_amount = {}
}

--- Parse the repository.
--- @param repository string
--- @return { source: string, author: string, name: string }
local function parse_repository(repository)
  if repository:sub(1, 8) == 'https://' then
    local chunks = vim.split(repository:sub(9), '/')

    Utilities.error(#chunks > 3 or (chunks[1]:len() == 0 or chunks[2]:len() == 0), {'Themify: Invalid repository name: "', repository, '"'})

    return { source = repository, author = chunks[2], name = chunks[3] }
  else
    local chunks = vim.split(repository, '/')

    Utilities.error(#chunks > 2 or (chunks[1]:len() == 0 or chunks[2]:len() == 0), {'Themify: Invalid repository name: "', repository, '"'})

    return { source = table.concat({'https://github.com', repository}, '/'), author = chunks[1], name = chunks[2] }
  end
end

--- Add a colorscheme to manage.
--- @param colorscheme_source string
--- @param colorscheme_info Colorscheme_Info
--- @return nil
function M.add_colorscheme(colorscheme_source, colorscheme_info)
  local colorscheme_id = colorscheme_source
  local colorscheme_type = colorscheme_source:find('/') and 'remote' or 'local'
  local colorscheme_repository
  local colorscheme_path = colorscheme_id

  if (colorscheme_type == 'remote') then
    local repository = parse_repository(colorscheme_id)

    colorscheme_id = table.concat({repository.author, repository.name}, '/')
    colorscheme_repository = {
      source = repository.source,
      author = repository.author,
      name = repository.name,
      branch = colorscheme_info.branch
    }

    colorscheme_path = table.concat({repository.author, repository.name}, '-')
  end

  Utilities.error(colorscheme_id:len() == 0, {'Themify: Invalid colorscheme source: "', colorscheme_source, '"'})
  Utilities.error(M.colorschemes_data[colorscheme_id] ~= nil, {'Themify: Duplicate colorscheme: "', colorscheme_id, '"'})

  M.colorschemes_id[#M.colorschemes_id + 1] = colorscheme_id
  M.colorschemes_data[colorscheme_id] = {
    type = colorscheme_type,
    status = colorscheme_type == 'remote' and 'unknown' or 'installed',
    repository = colorscheme_repository,
    progress = 0,
    info = '',
    before = colorscheme_info.before,
    after = colorscheme_info.after,
    themes = {},
    whitelist = colorscheme_info.whitelist,
    blacklist = colorscheme_info.blacklist,
    path = vim.fs.joinpath(Data.colorschemes_path, colorscheme_path)
  }
end

--- Load a theme.
--- @param colorscheme_id nil|string
--- @param theme string
--- @return nil
function M.load_theme(colorscheme_id, theme)
  if colorscheme_id == nil then
    -- <colorscheme_id> is not provided when loading a "local" colorscheme.

    colorscheme_id = theme
  end

  local colorscheme_data = M.colorschemes_data[colorscheme_id]

  if colorscheme_data == nil then
    return false
  end

  if colorscheme_data.type == 'remote' then
    if not vim.list_contains(M.loaded_colorschemes, colorscheme_id) then
      vim.o.runtimepath = table.concat({vim.o.runtimepath, ',', colorscheme_data.path})
    end
  end

  if type(colorscheme_data.before) == 'function' then
    pcall(colorscheme_data.before)
  end

  local ok = pcall(vim.cmd.colorscheme, theme)

  if ok then
    if type(colorscheme_data.after) == 'function' then
      pcall(colorscheme_data.after)
    end
  end

  return ok
end

--- Get the ID of the colorscheme using the repository folder name.
--- @param folder_name string
--- @return string|nil
local function get_colorscheme_id(folder_name)
  for colorscheme_id, colorscheme_data in pairs(M.colorschemes_data) do
    if colorscheme_data.repository ~= nil and table.concat({colorscheme_data.repository.author, colorscheme_data.repository.name}, '-') == folder_name then
      return colorscheme_id
    end
  end
end

--- Normalize a branch name.
--- @param branch string
--- @return string
local function normalize_branch(branch)
  return branch == 'master' and 'main' or branch
end

--- Clean unused colorschemes.
--- @return nil
function M.clean_colorschemes()
  local repository_folders = Utilities.scan_directory(Data.colorschemes_path)
  local file_name
  local colorscheme_id

  for i = 1, #repository_folders do
    file_name = repository_folders[i]

    if file_name:len() > 0 and file_name:sub(0, 1) ~= '.' then
      colorscheme_id = get_colorscheme_id(repository_folders[i])

      if colorscheme_id == nil
        -- The colorschemes is not being used.
        or not Utilities.path_exist(table.concat({M.colorschemes_data[colorscheme_id].path, '.git', 'HEAD'}, '/'))
        -- The repository is on a different branch.
        or normalize_branch(M.colorschemes_data[colorscheme_id].repository.branch) ~= normalize_branch(Data.read_colorscheme_repository_head(repository_folders[i]).branch)
      then
        -- Remove the colorscheme in async because it might take a long time.
        Utilities.execute_async(function()
          Utilities.delete_directory(vim.fs.joinpath(Data.colorschemes_path, repository_folders[i]))
        end)
      end
    end
  end
end

--- Check the colorschemes.
function M.check_colorschemes()
  Data.check_data_files()
  M.clean_colorschemes()

  for i = 1, #M.colorschemes_id do
    M.check_colorscheme(M.colorschemes_id[i])
  end
end

--- Check a colorscheme.
--- @param colorscheme_id string
--- @return nil
function M.check_colorscheme(colorscheme_id)
  local colorscheme_data = M.colorschemes_data[colorscheme_id]

  Utilities.error(colorscheme_data == nil, {'Themify: Colorscheme not found: "', colorscheme_id, '"'})

  if colorscheme_data.type == 'remote' and (colorscheme_data.status ~= 'installing' and colorscheme_data.status ~= 'updating') then
    colorscheme_data.status = Utilities.path_exist(colorscheme_data.path) and 'installed' or 'not_installed'
    colorscheme_data.info = ''

    Event.emit('state_update')

    if colorscheme_data.status == 'installed' then
      -- Check all the themes under the colorscheme.

      colorscheme_data.themes = {}

      local themes_path = vim.fs.joinpath(colorscheme_data.path, 'colors')

      if Utilities.path_exist(themes_path) then
        local theme_files = Utilities.scan_directory(themes_path)
        local theme_name
        local theme_type

        for i = 1, #theme_files do
          if theme_files[i]:len() > 0 then
            theme_name = vim.fn.fnamemodify(theme_files[i], ':r')
            theme_type = vim.fn.fnamemodify(theme_files[i], ':e')

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

--- Install the colorschemes.
--- @return nil
function M.install_colorschemes()
  Data.check_data_files()

  for i = 1, #M.colorschemes_id do
    M.install_colorscheme(M.colorschemes_id[i])
  end
end

--- Install a colorscheme.
--- @param colorscheme_id string
--- @return nil
function M.install_colorscheme(colorscheme_id)
  M.check_colorscheme(colorscheme_id)

  local colorscheme_data = M.colorschemes_data[colorscheme_id]

  if colorscheme_data.status == 'not_installed' then
    colorscheme_data.status = 'installing'
    colorscheme_data.progress = 0
    colorscheme_data.info = 'Fetching...'

    Event.emit('update')
    Event.emit('state_update')

    local pipeline = Pipeline:new({
      Tasks.clone(Data.colorschemes_path, colorscheme_data.repository.source, colorscheme_data.repository.branch, table.concat({colorscheme_data.repository.author, colorscheme_data.repository.name}, '-'), function(progress, info)
        colorscheme_data.progress = progress
        colorscheme_data.info = info

        Event.emit('update')
      end),
      Tasks.checkout(colorscheme_data.path, colorscheme_data.repository.branch, function()
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
        M.check_colorscheme(colorscheme_id)
      end
    end)
  end
end

--- Update the colorschemes.
--- @return nil
function M.update_colorschemes()
  for i = 1, #M.colorschemes_id do
    M.update_colorscheme(M.colorschemes_id[i])
  end
end

--- Update a colorscheme.
--- @param colorscheme_id string
--- @return nil
function M.update_colorscheme(colorscheme_id)
  M.check_colorscheme(colorscheme_id)

  local colorscheme_data = M.colorschemes_data[colorscheme_id]

  if colorscheme_data.type == 'remote' and colorscheme_data.status == 'installed' then
    colorscheme_data.status = 'updating'
    colorscheme_data.progress = 0
    colorscheme_data.info = 'Fetching...'

    Event.emit('update')
    Event.emit('state_update')

    M.check_colorscheme_commit(colorscheme_id, function(error, local_commit, remote_commit)
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
            Tasks.reset(colorscheme_data.path, colorscheme_data.repository.branch, function()
              Event.emit('update')

              colorscheme_data.progress = 25
              colorscheme_data.info = 'Reseting...'
            end),
            Tasks.pull(colorscheme_data.path, colorscheme_data.repository.branch, function()
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

--- Check the commit of the colorscheme.
--- @param colorscheme_id string
--- @param callback function
--- @return nil 
function M.check_colorscheme_commit(colorscheme_id, callback)
  local colorscheme_data = M.colorschemes_data[colorscheme_id]
  local local_commit, remote_commit

  local pipeline = Pipeline:new({
    Tasks.fetch(colorscheme_data.path, colorscheme_data.repository.branch),
    Tasks.get_commit(colorscheme_data.path, 'HEAD', function(commit_hash)
      local_commit = commit_hash
    end),
    Tasks.get_commit(colorscheme_data.path, table.concat({'origin', colorscheme_data.repository.branch}, '/'), function(commit_hash)
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

--- Count the amount of the colorscheme.
--- @return nil
function M.count_colorscheme_amount()
  M.colorschemes_amount = {}

  local colorscheme_data
  local colorscheme_status

  for i = 1, #M.colorschemes_id do
    colorscheme_data = M.colorschemes_data[M.colorschemes_id[i]]

    if (colorscheme_data.type == 'remote') then
      colorscheme_status = colorscheme_data.status

      M.colorschemes_amount[colorscheme_status] = M.colorschemes_amount[colorscheme_status] == nil and 1 or M.colorschemes_amount[colorscheme_status] + 1
    end
  end
end

M.count_colorscheme_amount()
Event.listen('state_update', M.count_colorscheme_amount)

return M
