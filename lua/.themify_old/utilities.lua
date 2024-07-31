local M = {}

-- Stringify A Data
function M.stringify(data)
  if type(data) == 'table' then
    local s = '{'

    for key, v in pairs(data) do
      if type(key) ~= 'number' then key = '"'..key..'"' end

      s = s .. '[' .. key ..'] = ' .. M.stringify(v) .. ','
    end

    return s .. '}'
  else
    return tostring(data)
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

return M
