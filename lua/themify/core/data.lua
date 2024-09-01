--- @alias StateData nil|{ colorscheme_repository: string, theme: string }

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
    M.write_state_data(nil)
  end
end

--- Get The State Data
--- @return StateData
function M.read_state_data()
  M.check_data_files()

  return vim.json.decode(Utilities.read_file(M.state_data_path))
end

--- Write The State Data
--- @param data StateData
--- @return nil
function M.write_state_data(data)
  Utilities.write_file(M.state_data_path, vim.json.encode(data))
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
