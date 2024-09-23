--- @alias StateData vim.NIL|{ colorscheme_id: string, theme: string }

local Utilities = require('themify.utilities')

local data_path = vim.fn.stdpath('data')
if type(data_path) == 'table' then data_path = data_path[1] end

local M = {
  --- @type string
  themify_path = vim.fs.joinpath(data_path, 'themify'),
  --- @type string
  colorschemes_path = vim.fs.joinpath(data_path, 'themify', 'colorschemes'),
  --- @type string
  state_data_path = vim.fs.joinpath(data_path, 'themify', 'state.json')
}

--- Check Data Files
--- @return nil
function M.check_data_files() 
  if not Utilities.path_exist(M.themify_path) then vim.fn.mkdir(M.themify_path, 'p') end
  if not Utilities.path_exist(M.colorschemes_path) then vim.fn.mkdir(M.colorschemes_path, 'p') end
  if not Utilities.path_exist(M.state_data_path) then
    M.write_state_data(vim.NIL)
  end
end

--- Read The State Data
--- @return StateData
function M.read_state_data()
  M.check_data_files()

  local data = vim.json.decode(Utilities.read_file(M.state_data_path))

  --- Just for backward compatibility, might remove this later.
  --- Added 2024/9/14.

  if data ~= vim.NIL and data.colorscheme_repository ~= nil then
    M.write_state_data({ colorscheme_id = data.colorscheme_repository, theme = data.theme })

    return { colorscheme_id = data.colorscheme_repository, theme = data.theme }
  end

  return data
end

--- Write The State Data
--- @param data StateData
--- @return nil
function M.write_state_data(data)
  local json = vim.json.encode(data)
  Utilities.error(json == nil, {'Themify: Failed to encode the state data'})

  Utilities.write_file(M.state_data_path, json)
end

--- Read The Head Of The Colorscheme Repository
--- @param colorscheme_name string
--- @return { branch: string }
function M.read_colorscheme_repository_head (colorscheme_name)
  local repository_head_path = vim.fs.joinpath(M.colorschemes_path, colorscheme_name, '.git', 'HEAD')

  local content = Utilities.read_file(repository_head_path)

  return {
    branch = vim.split(content:match('ref: refs/heads/(.*)'), '\n')[1]
  }
end

return M
