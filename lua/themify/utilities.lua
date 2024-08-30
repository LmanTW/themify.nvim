local M = {}

--- Stringify A Data
--- @param data any
--- @return string
function M.stringify(data)
  if type(data) == 'table' then
    local text = '{ '

    for key, value in pairs(data) do
      text = table.concat({text, '[', M.stringify(key), ']=',  M.stringify(value),  ', '})
    end

    return text:sub(0, text:len() - 1) .. ' }'
  else
    return type(data) == 'string' and table.concat({'"', data, '"'}) or tostring(data)
  end
end

--- Check If A List Contains A Set Of Values (T = Type)
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

--- Get The Index Of An Element (T = Type)
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

--- Check If A Path Exist
--- @param path string
--- @return boolean 
function M.path_exist(path)
  local stats = vim.loop.fs_stat(path)

  return stats ~= nil
end

--- Execute A Function In Async
--- @param callback function
--- @return nil 
function M.execute_async(callback)
  local async

  async = vim.uv.new_async(function()
    callback()

    M.error(async == nil, {'Themify: Failed close the async'})
    async:close()
  end)

  M.error(async == nil, {'Themify: Failed close the async'})
  async:send()
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
