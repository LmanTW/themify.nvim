local M = {}

--- Stringify A Data
--- @param data any
--- @return string
function M.stringify(data)
  if type(data) == 'table' then
    local text = '{ '

    for key, value in pairs(data) do
      text = text .. '[' .. M.stringify(key) ..'] = ' .. M.stringify(value) .. ','
    end 

    return string.sub(text, 0, string.len(text) - 1) .. ' }'
  else
    return type(data) == 'string' and '"' .. data .. '"' or tostring(data)
  end
end

--- Split A Text
--- @param text string
--- @param separator string
--- @return string[]
function M.split(text, separator)
   local chunks = {}

   for chunk in string.gmatch(text, "([^" .. separator .. "]+)") do
      table.insert(chunks, chunk)
   end

   return chunks
 end

 --- Center A Text
 --- @param text string
 --- @param width number
 --- @return string
 function M.center(text, width)
  return table.concat({string.rep(' ', (width - string.len(text)) / 2), text})
 end

--- Get The Size Of A Table
--- @param table table
--- @return number
function M.size(table)
  local size = 0

  for _ in pairs(table) do
    size = size + 1
  end

  return size
end

--- Check If A List Contains A Value (T = Type)
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

--- Check If A Path Exist
--- @param path string
--- @return boolean 
function M.is_path_exist(path)
  local stats = vim.loop.fs_stat(path)

  return stats ~= nil
end

--- Execute A Command
--- @param command string
--- @return any
function M.execute(command)
  local handle = io.popen(command)

  assert(handle ~= nil, table.concat({'Themify: Failed to execute command "', command, '"'}))

  local result = handle:read('*a')
  handle:close()

  return result
end

return M
