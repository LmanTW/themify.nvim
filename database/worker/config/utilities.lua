local M = {}

--- Check If A Path Exist
--- @param path string
--- @return boolean 
function M.path_exist(path)
  return vim.loop.fs_stat(path) ~= nil
end

--- Read A File
--- @param path string
--- @return string
function M.read_file(path)
  local stats = vim.loop.fs_stat(path)
  M.error(stats == nil, {'Themify: Cannot stat the file: "', path, '"'})

  local file = vim.loop.fs_open(path, 'r', 438)
  M.error(file == nil, {'Themify: Cannot open the file: "', path, '"'})

  local content = vim.loop.fs_read(file, stats.size, 0)
  M.error(content == nil, {'Themify: Cannot read the file: "', path, '"'})

  vim.loop.fs_close(file)

  return content
end

--- Write A File
--- @param path string
--- @param data string
--- @return nil
function M.write_file(path, data)
  local file = vim.loop.fs_open(path, 'w', 438)
  M.error(file == nil, {'Themify: Cannot open the file: "', path, '"'})

  local _, error = vim.loop.fs_write(file, data)
  M.error(error ~= nil, {'Themify: Cannot write to the file: "', path, '"'})

  vim.loop.fs_close(file)
end

--- Scan A Directory
--- @param path string
--- @return string[]
function M.scan_directory(path)
  local handle = vim.loop.fs_scandir(path)
  M.error(handle == nil, {'Themify: Cannot scan the directory: "', path, '"'})

  local files = {}

  while true do
    local name = vim.loop.fs_scandir_next(handle)
    if not name then break end

    table.insert(files, name)
  end

  return files
end

--- Throw An Error If The Condition Is Met
--- @param condition boolean
--- @param message string[]
--- @return nil
function M.error(condition, message)
  if condition then
    error(table.concat(message, ''))
  end
end

return M
