local M = {
  themify_path = table.concat({vim.fn.stdpath('data'), 'themify'}, '/'),
  colorschemes_path = table.concat({vim.fn.stdpath('data'), 'themify/colorschemes'}, '/'),
  data_path = table.concat({vim.fn.stdpath('data'), 'themify/data.json'}, '/')
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
  if not M.path_exist(M.themify_path) then
    os.execute(table.concat({'mkdir', M.themify_path}, ' '))
  end

  if not M.path_exist(M.colorschemes_path) then
    os.execute(table.concat({'mkdir', M.colorschemes_path}, ' '))
  end

  if not M.path_exist(M.data_path) then
    M.write_data({ state = nil, colorschemes = {} })
  end
end

-- Get The Data
function M.read_data()
  if M.path_exist(M.data_path) then
    local file = io.open(M.data_path, 'r')

    if (file == nil) then
      error('Themify: Cannot read the file "' .. M.data_path .. '"')
    end

    local json = file:read('*a')

    io.close(file)

    return vim.json.decode(json)
  end
end

-- Write Data
function M.write_data(data)
  local file = io.open(M.data_path, 'w')

  if (file == nil) then
    error('Themify: Cannot write the file "' .. M.data_path .. '"')
  end

  file:write(vim.json.encode(data))

  file:close()
end

return M
