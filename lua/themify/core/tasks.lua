local Pipeline = require('themify.core.pipeline')

local M = {}

--- Create a fetch task.
--- @param cwd string
--- @param branch? string
--- @param callback? function
function M.fetch(cwd, branch, callback)
  if callback ~= nil then
    callback()
  end

  local arguments = {'fetch', 'origin'}

  if branch ~= nil then
    arguments[#arguments + 1] = branch
  end

  return Pipeline.create_task(cwd, 'git', arguments)
end

--- Create a task to get the commit.
--- @param cwd string
--- @param target string
--- @param callback function
function M.get_commit(cwd, target, callback)
  return Pipeline.create_task(cwd, 'git', {'rev-parse', target}, function(stdout)
    callback(vim.split(stdout, '\n')[1])
  end)
end

--- Create a pull task.
--- @param cwd string
--- @param branch? string
--- @param callback? function
function M.pull(cwd, branch, callback)
  if callback ~= nil then
    callback()
  end

  local arguments = {'pull', '-X', 'theirs', 'origin'}

  if branch ~= nil then
    arguments[#arguments + 1] = branch
  end

  arguments[#arguments + 1] = '--progress'

  return Pipeline.create_task(cwd, 'git', arguments)
end

--- Create a clone task.
--- @param cwd string
--- @param source string
--- @param branch? string
--- @param path string
--- @param callback function
function M.clone(cwd, source, branch, path, callback)
  local arguments = {'clone', source, path, '--progress'}

  if branch ~= nil then
    arguments[#arguments + 1] = '-b'
    arguments[#arguments + 1] = branch
  end

  return Pipeline.create_task(cwd, 'git', arguments, function(_, stderr)
    if stderr ~= nil then
      if (stderr:sub(0, 24) == 'Counting objects') then
        callback((tonumber(stderr:match('[0-9]*[0-9]')) or 0) / 4, 'Counting Objects...')
      elseif stderr:sub(0, 27) == 'Compressing objects' then
        callback((25 + (tonumber(stderr:match('[0-9]*[0-9]')) or 0) / 4), 'Compressing Objects...')
      elseif (stderr:sub(0, 17)) == 'Receiving objects' then
        callback((50 + (tonumber(stderr:match('[0-9]*[0-9]')) or 0) / 4), 'Receiving Objects...')
      elseif (stderr:sub(0, 16) == 'Resolving deltas') then
        callback((75 + (tonumber(stderr:match('[0-9]*[0-9]')) or 0) / 4), 'Resolving Deltas...')
      end
    end
  end)
end

--- Create a checkout task.
--- @param cwd string
--- @param branch? string
--- @param callback? function
function M.checkout(cwd, branch, callback)
  if callback ~= nil then
    callback()
  end

  local arguments = {'checkout'}

  if branch ~= nil then
    arguments[#arguments + 1] = branch
  end

  return Pipeline.create_task(cwd, 'git', arguments)
end

--- Create a reset task.
--- @param cwd string
--- @param branch string
--- @param callback? function
function M.reset(cwd, branch, callback)
  if callback ~= nil then
    callback()
  end

  return Pipeline.create_task(cwd, 'git', {'reset', '--hard', table.concat({'origin', branch}, '/')})
end

return M
