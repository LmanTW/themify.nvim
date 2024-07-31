local Utilities = require('themify.utilities')

local M = {}

function M.clone(directory, repository)
  local handle
  local stdout = vim.loop.new_pipe(false)
  local stderr = vim.loop.new_pipe(false)

  directory = directory .. '/' .. Utilities.split(repository, '/')[2]

  -- os.execute('mkdir ' .. directory)

  handle = vim.loop.spawn('git', {
    args = {'clone', 'https://github.com/' .. repository, directory, '--progress'},

    stdio = {nil, stdout, stderr},
  }, function(code, signal)
    stdout:close()
    stderr:close()
    handle:close()

    print('Process exited with code:', code, 'and signal:', signal)
  end)

  return handle, stdout, stderr
end

return M
