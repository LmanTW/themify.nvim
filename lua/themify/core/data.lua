--- @alias StateData nil|{ colorscheme_repository: string, theme: string }

local Utilities = require('themify.utilities')

local M = {
  --- @type string
  themify_path = table.concat({vim.fn.stdpath('data'), 'themify'}, '/'),
  --- @type string
  colorschemes_path = table.concat({vim.fn.stdpath('data'), 'themify/colorschemes'}, '/'),
  --- @type string
  state_data_path = table.concat({vim.fn.stdpath('data'), 'themify/state.json'}, '/')
}

--- Check Data Files
--- @return nil
function M.check_data_files()
  if not Utilities.path_exist(M.themify_path) then os.execute(table.concat({'mkdir', M.themify_path}, ' ')) end
  if not Utilities.path_exist(M.colorschemes_path) then os.execute(table.concat({'mkdir', M.colorschemes_path}, ' ')) end
  if not Utilities.path_exist(M.state_data_path) then
    M.write_state_data(nil)
  end
end

--- Get The State Data
--- @return StateData
function M.read_state_data()
  M.check_data_files()

  local file = io.open(M.state_data_path, 'r')
  assert(file ~= nil, table.concat({'Themify: Cannot read the state data "', M.state_data_path, '"'}))

  local json = file:read('*a')
  io.close(file)

  return vim.json.decode(json)
end

--- Write The State Data
--- @param data StateData
--- @return nil
function M.write_state_data(data)
  local file = io.open(M.state_data_path, 'w')
  assert(file ~= nil, table.concat({'Themify: Cannot write the state data "', M.state_data_path, '"'}))

  file:write(vim.json.encode(data))
  file:close()
end

--- Read The Head Of The Colorscheme Repository
--- @param colorscheme_name string
--- @return { branch: string }
function M.read_colorscheme_repository_head (colorscheme_name)
  local repository_head_path = table.concat({M.colorschemes_path, colorscheme_name, '.git', 'HEAD'}, '/')

  local file = io.open(repository_head_path, 'r')
  assert(file ~= nil, table.concat({'Themify: Cannot read the repository head "', repository_head_path, '"'}))

  local content = file:read('*a')

  return {
    branch = vim.split(content:match('ref: refs/heads/(.*)'), '\n')[1]
  }
end

return M
