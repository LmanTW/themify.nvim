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

   for chunk in string.gmatch(text, "([^" .. separator .. "]+)") do
      table.insert(chunks, chunk)
   end

   return chunks
end

-- Get The Size Of A Table
function M.size(table)
  local size = 0

  for _ in pairs(table) do size = size + 1 end

  return size
end

-- Combine Tables
function M.combine(base, target)
  local combined = base

  for key, value in pairs(target) do
    if base[key] == nil then combined[key] = value
    else
      if type(target[key]) == 'table' then
        if type(base[key]) ~= 'table' then base[key] = {} end

        combined[key] = M.combine(type(base[key]) == 'table' and base[key] or {}, target[key])
      else combined[key] = value end
    end
  end

  return combined
end

-- Check A Path
function M.check_path(path, callback)
  -- Call the callback if the path does not exists.

  if os.execute("[ -e '" .. path .. "' ]") ~= 0 then
    callback(path)
  end
end

-- Write A File
function M.write_file(path, content)
  local file = io.open(path, 'w')

  if file == nil then
    print('Themify: Cannot Write The File: '.. path)

    return
  end

  file:write(content)

  io.close(file)
end

return M
