--- @class Colorscheme_Info
--- @field branch string
--- @field before? function
--- @field after? function
--- @field whitelist? string[]
--- @field blacklist? string[]

--- @class Colorscheme_Data
--- @field type 'github'|'local'
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

--- Get The Name Of The Colorscheme
--- @param repository string
--- @return { type: 'github'|'local', name: string }
local function get_colorscheme_name(repository)
  local chunks = vim.split(repository, '/')

  Utilities.error(#chunks > 2, {'Themify: Invalid colorscheme name: "', repository, '"'})

  return #chunks == 1 and { type = 'local', name = chunks[1] } or { type = 'github', name = chunks[2] }
end

--- Add A Colorscheme To Manage
--- @param colorscheme_id string
--- @param colorscheme_info Colorscheme_Info
--- @return nil
function M.add_colorscheme(colorscheme_id, colorscheme_info)
  Utilities.error(M.colorschemes_data[colorscheme_id] ~= nil, {'Themify: Duplicate colorscheme: "', colorscheme_id, '"'})

  local colorscheme_name = get_colorscheme_name(colorscheme_id)

  M.colorschemes_id[#M.colorschemes_id + 1] = colorscheme_id
  M.colorschemes_data[colorscheme_id] = {
    type = colorscheme_name.type,
    name = colorscheme_name.name,
    status = 'unknown',
    progress = 0,
    info = '',
    branch = colorscheme_info.branch,
    before = colorscheme_info.before,
    after = colorscheme_info.after,
    themes = {},
    whitelist = colorscheme_info.whitelist,
    blacklist = colorscheme_info.blacklist,
    path = vim.fs.joinpath(Data.colorschemes_path, colorscheme_name.name)
  }
end

--- Load A Theme
--- @param colorscheme_id string
--- @param theme string
--- @return nil
function M.load_theme(colorscheme_id, theme)
  Utilities.error(M.colorschemes_data[colorscheme_id] == nil, {'Themify: Colorscheme not found: "', colorscheme_id, '"'})

  local colorscheme_data = M.colorschemes_data[colorscheme_id]

  if colorscheme_data.type == 'github' then
    if not vim.list_contains(M.loaded_colorschemes, colorscheme_id) then
      vim.o.runtimepath = table.concat({vim.o.runtimepath, ',', colorscheme_data.path})
    end
  end

  if type(colorscheme_data.before) == 'function' then
    colorscheme_data.before()
  end

  local ok = pcall(vim.cmd.colorscheme, theme)

  if ok then
    if type(colorscheme_data.after) == 'function' then
      colorscheme_data.after()
    end
  end

  return ok
end

--- Get The Repository Of The Colorscheme
--- @param colorscheme_name string
--- @return string|nil
local function get_colorscheme_id(colorscheme_name)
  for colorscheme_id, colorscheme_data in pairs(M.colorschemes_data) do
    if colorscheme_data.name == colorscheme_name then
      return colorscheme_id
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
        or normalize_branch(M.colorschemes_data[colorscheme_id].branch) ~= normalize_branch(Data.read_colorscheme_repository_head(repository_folders[i]).branch)
        -- The repository is on a different branch.
      then
        -- Remove the colorscheme in async because it might take a long time.
        Utilities.execute_async(function()
          Utilities.delete_directory(vim.fs.joinpath(Data.colorschemes_path, repository_folders[i]))
        end)
      end
    end
  end
end

--- The The Colorschemes
function M.check_colorschemes()
  Data.check_data_files()
  M.clean_colorschemes()

  for i = 1, #M.colorschemes_id do
    M.check_colorscheme(M.colorschemes_id[i])
  end
end

--- Check A Colorscheme
--- @param colorscheme_id string
--- @return nil
function M.check_colorscheme(colorscheme_id)
  local colorscheme_data = M.colorschemes_data[colorscheme_id]

  Utilities.error(colorscheme_data == nil, {'Themify: Colorscheme not found: "', colorscheme_id, '"'})

  if colorscheme_data.type == 'github' then
    if (colorscheme_data.status ~= 'installing' and colorscheme_data.status ~= 'updating') then
      colorscheme_data.status = Utilities.path_exist(colorscheme_data.path) and 'installed' or 'not_installed'
      colorscheme_data.info = ''

      Event.emit('state_update')

      if colorscheme_data.status == 'installed' then
        -- Check the themes under the colorscheme.

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
      else
        colorscheme_data.status = 'installed'
      end
    end
  end
end

--- Install The Colorschemes
--- @return nil
function M.install_colorschemes()
  Data.check_data_files()

  for i = 1, #M.colorschemes_id do
    M.install_colorscheme(M.colorschemes_id[i])
  end
end

--- Install A Colorscheme
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
      Tasks.clone(Data.colorschemes_path, colorscheme_id, colorscheme_data.branch, function(progress, info)
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
        M.check_colorscheme(colorscheme_id)
      end
    end)
  end
end

--- Update The Colorscheme
--- @return nil
function M.update_colorschemes()
  for i = 1, #M.colorschemes_id do
    M.update_colorscheme(M.colorschemes_id[i])
  end
end

--- Update A Colorscheme
--- @param colorscheme_id string
--- @return nil
function M.update_colorscheme(colorscheme_id)
  M.check_colorscheme(colorscheme_id)

  local colorscheme_data = M.colorschemes_data[colorscheme_id]

  if colorscheme_data.status == 'installed' then
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
--- @param colorscheme_id string
--- @param callback function
--- @return nil 
function M.check_colorscheme_commit(colorscheme_id, callback)
  local colorscheme_data = M.colorschemes_data[colorscheme_id]
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

  for i = 1, #M.colorschemes_id do
    status = M.colorschemes_data[M.colorschemes_id[i]].status

    M.colorschemes_amount[status] = M.colorschemes_amount[status] == nil and 1 or M.colorschemes_amount[status] + 1
  end
end

M.count_colorscheme_amount()
Event.listen('state_update', M.count_colorscheme_amount)

return M
