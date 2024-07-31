local M = {
  data_path = table.concat({vim.fn.stdpath('data'), 'themify'}, '/'),
  colorschemes_path = table.concat({vim.fn.stdpath('data'), 'themify/colorschemes'}, '/'),
  state_path = table.concat({vim.fn.stdpath('data'), 'themify/state.json'}, '/')
}

-- Join Paths
function M.join_paths(...)
  return table.concat({ ... }, '/')
end

-- Check If A Path Exist
function M.path_exist(path)
  local stats = vim.loop.fs_stat(path)

  return stats ~= nil
end

-- Check The Data Files
function M.check_data_files()
  if not M.path_exist(M.colorschemes_path) then
    os.execute(table.concat({'mkdir', M.colorschemes_path}, ' '))
  end

--  if not M.path_exist(M.join_paths(M.data_path, 'state.json')) then
--    local file = io.open(M.join_paths(M.data_path, 'state.json'), 'w')
--
--    if (file == nil) then
--      error('Themify: Cannot write to file "' .. M.join_paths(M.data_path, 'state.json') .. '"')
--    end
--
--    file:write('{}')
--
--    io.close(file)
--  end
end

-- Get The Data
function M.get_state()
  if M.path_exist(M.state_path) then
    local file = io.open(M.state_path)

    if (file == nil) then
      error('Themify: Cannot read the file "' .. M.state_path .. '"')
    end

    local json = file:read('*a')

    io.close(file)

    return vim.json.decode(json)
  end
end

return M
