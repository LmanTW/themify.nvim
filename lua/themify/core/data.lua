--- @alias State_Data vim.NIL|{ colorscheme_id: string, theme: string }
--- @alias Activity_Data vim.NIL|{ last_update: number, colorschemes: table<string, { type: 'remote', themes: table<string, Usage_Data> }|{ type: 'local', usage: Usage_Data }> }
--- @alias Usage_Data { last_active: number, total_minutes: number, today_minutes: number }

local Utilities = require('themify.utilities')

local data_path = vim.fn.stdpath('data')
if type(data_path) == 'table' then data_path = data_path[1] end

local M = {
  --- @type string
  themify_path = vim.fs.joinpath(data_path, 'themify'),
  --- @type string
  colorschemes_path = vim.fs.joinpath(data_path, 'themify', 'colorschemes'),
  --- @type string
  state_data_path = vim.fs.joinpath(data_path, 'themify', 'state.json'),
  --- @type string
  activity_data_path = vim.fs.joinpath(data_path, 'themify', 'activity.json')
}

--- Check the files.
--- @return nil
function M.check_files()
  if not Utilities.path_exist(M.themify_path) then vim.fn.mkdir(M.themify_path) end
  if not Utilities.path_exist(M.colorschemes_path) then vim.fn.mkdir(M.colorschemes_path) end
  if not Utilities.path_exist(M.state_data_path) then M.write_state_data(vim.NIL) end
  if not Utilities.path_exist(M.activity_data_path) then M.write_activity_data(vim.NIL) end
end

--- Read the state data.
--- @return State_Data
function M.read_state_data()
  M.check_files()

  local data = vim.json.decode(Utilities.read_file(M.state_data_path))

  --- Just for backward compatibility, remove this later.
  --- Added: 2024/9/14.

  if data ~= vim.NIL and data.colorscheme_repository ~= nil then
    M.write_state_data({ colorscheme_id = data.colorscheme_repository, theme = data.theme })

    return { colorscheme_id = data.colorscheme_repository, theme = data.theme }
  end

  return data
end

--- Read the activity data.
--- @return Activity_Data
function M.read_activity_data()
  M.check_files()

  return vim.json.decode(Utilities.read_file(M.activity_data_path))
end

--- Write the state data.
--- @param data State_Data
--- @return nil
function M.write_state_data(data)
  local json = vim.json.encode(data)
  Utilities.error(json == nil, {'[Themify] Failed to encode the state data'})

  Utilities.write_file(M.state_data_path, json)
end

--- Write the activity data.
--- @param data Activity_Data
--- @return nil
function M.write_activity_data(data)
  local json = vim.json.encode(data)
  Utilities.error(json == nil, {'[Themify] Failed to encode the activity data'})

  Utilities.write_file(M.activity_data_path, json)
end

--- Read the head of a repository.
--- @param repository_name string
--- @return { branch: string }
function M.read_colorscheme_repository_head (repository_name)
  local repository_head_path = vim.fs.joinpath(M.colorschemes_path, repository_name, '.git', 'HEAD')
  Utilities.error(not Utilities.path_exist(repository_head_path), {'[Themify] Cannot read the head of: "', repository_name, '"'})

  local content = Utilities.read_file(repository_head_path)

  return {
    branch = vim.split(content:match('ref: refs/heads/(.*)'), '\n')[1]
  }
end

return M
