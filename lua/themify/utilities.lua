local M = {}

--- Check if a list contains a set of values.
--- @generic T
--- @param list T[]
--- @param values T[]
--- @return boolean
function M.contains(list, values)
  for i = 1, #list do
    for i2 = 1, #values do
      if list[i] == values[i2] then
        table.remove(values, i2)

        break
      end
    end

    if (#values < 1) then
      return true
    end
  end

  return false
end

--- Get the index of an element.
--- @generic T
--- @param list T[]
--- @param element T
--- @return number
function M.index(list, element)
  for i = 1, #list do
    if list[i] == element then
      return i
    end
  end

  return -1
end

--- Check if a path exist.
--- @param path string
--- @return boolean 
function M.path_exist(path)
  return vim.uv.fs_stat(path) ~= nil
end

--- Read a file.
--- @param path string
--- @return string
function M.read_file(path)
  local stats = vim.uv.fs_stat(path)
  M.error(stats == nil, {'[Themify] Cannot stat the file: "', path, '"'})

  local file = vim.uv.fs_open(path, 'r', 438)
  M.error(file == nil, {'[Themify] Cannot open the file: "', path, '"'})

  local content = vim.uv.fs_read(file, stats.size, 0)
  M.error(content == nil, {'[Themify] Cannot read the file: "', path, '"'})

  vim.uv.fs_close(file)

  return content
end

--- Write a file.
--- @param path string
--- @param data string
--- @return nil
function M.write_file(path, data)
  local file = vim.uv.fs_open(path, 'w', 438)
  M.error(file == nil, {'[Themify] Cannot open the file: "', path, '"'})

  local _, error = vim.uv.fs_write(file, data)
  M.error(error ~= nil, {'[Themify] Cannot write to the file: "', path, '"'})

  vim.uv.fs_close(file)
end

--- Scan a directory.
--- @param path string
--- @return string[]
function M.scan_directory(path)
  local handle = vim.uv.fs_scandir(path)
  M.error(handle == nil, {'[Themify] Cannot scan the directory: "', path, '"'})

  local files = {}

  while true do
    local name = vim.uv.fs_scandir_next(handle)
    if not name then break end

    table.insert(files, name)
  end

  return files
end

--- Delete a directory.
--- @param path string
--- @return nil
function M.delete_directory(path)
  local files_name = M.scan_directory(path)
  local file_path

  --- Replace with "vim.fs.rm" in the future.

  for i = 1, #files_name do
    file_path = vim.fs.joinpath(path, files_name[i])

    local stat = vim.uv.fs_stat(file_path)
    M.error(stat == nil, {'[Themify] Cannot stat the file: "', file_path, '"'})

    if stat.type == 'directory' then
      M.delete_directory(file_path)
    else
      vim.uv.fs_unlink(file_path)
    end
  end

  vim.uv.fs_rmdir(path)
end

--- Execute a function asynchronously.
--- @param callback function
--- @return nil 
function M.execute_async(callback)
  local async

  async = vim.uv.new_async(function()
    callback()

    M.error(async == nil, {'[Themify] Failed close the async'})
    async:close()
  end)

  M.error(async == nil, {'[Themify] Failed close the async'})
  async:send()
end

--- Throw an error if the condition is true.
--- @param condition boolean
--- @param message string[]
--- @return nil
function M.error(condition, message)
  if condition then
    error(table.concat(message, ''))
  end
end

return M
