--- @class LockData
--- @field state nil|{ colorscheme: string, theme: string }
--- @field colorschemes table<string, { branch: string, commit: string }>

local Utilities = require('themify.utilities')

local M = {
  --- @type string
  themify_path = table.concat({vim.fn.stdpath('data'), 'themify'}, '/'),

  --- @type string
  colorschemes_path = table.concat({vim.fn.stdpath('data'), 'themify/colorschemes'}, '/'),

  --- @type string
  lock_data_path = table.concat({vim.fn.stdpath('data'), 'themify/lock.json'}, '/')
}

--- Check Data Files
--- @return nil
function M.check_data_files()
  if not Utilities.is_path_exist(M.themify_path) then
    os.execute(table.concat({'mkdir', M.themify_path}, ' '))
  end

  if not Utilities.is_path_exist(M.colorschemes_path) then
    os.execute(table.concat({'mkdir', M.colorschemes_path}, ' '))
  end

  if not Utilities.is_path_exist(M.lock_data_path) then
    M.write_lock_data({ state = nil, colorschemes = {} })
  end
end

--- Get The Lock Data
--- @return LockData 
function M.read_lock_data()
  M.check_data_files()

  local file = io.open(M.lock_data_path, 'r')

  assert(file ~= nil, table.concat({'Themify: Cannot read the file "', M.lock_data_path, '"'}))

  local json = file:read('*a')
  io.close(file)

  return vim.json.decode(json)
end

--- Write The Lock Data
--- @param data LockData 
--- @return nil
function M.write_lock_data(data)
  local file = io.open(M.lock_data_path, 'w')

  assert(file ~= nil, table.concat({'Themify: Cannot write the file "', M.lock_data_path, '"'}))

  file:write(vim.json.encode(data))
  file:close()
end

return M
