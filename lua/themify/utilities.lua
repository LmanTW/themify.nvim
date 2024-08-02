local M = {}

-- Stringify A Data
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

-- Split A Text
function M.split(text, separator)
   local chunks = {}
   local size = 0

   for chunk in string.gmatch(text, "([^" .. separator .. "]+)") do
      table.insert(chunks, chunk)
      size = size + 1
   end

   return chunks, size
end

-- Get The Size Of A Table
function M.size(table)
  local size = 0

  for _ in pairs(table) do
    size = size + 1
  end

  return size
end

-- Execute A Command
function M.execute(command)
  local handle = io.popen(command)

  if handle == nil then
    error('Themify: Failed to execute command "' .. command .. '"')
  end

  local result = handle:read('*a')

  handle:close()

  return result
end

return M
