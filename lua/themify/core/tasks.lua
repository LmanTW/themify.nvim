local Pipeline = require('themify.core.pipeline')

local M = {}

--- Create A Fetch Task
--- @param cwd string
--- @param branch string
--- @param callback function?
function M.fetch(cwd, branch, callback)
  if callback ~= nil then
    callback()
  end

  return Pipeline.create_task(cwd, 'git', {'fetch', 'origin', branch})
end

--- Create A Task To Get The Commit
--- @param cwd string
--- @param target string
--- @param callback function
function M.get_commit(cwd, target, callback)
  return Pipeline.create_task(cwd, 'git', {'rev-parse', target}, function(stdout)
    callback(vim.split(stdout, '\n')[1])
  end)
end

--- Create A Pull Task
--- @param cwd string
--- @param branch string
--- @param callback function?
function M.pull(cwd, branch, callback)
  if callback ~= nil then
    callback()
  end

  return Pipeline.create_task(cwd, 'git', {'pull', '-X', 'theirs', 'origin', branch, '--progress'})
end

--- Create A Clone Task
--- @param cwd string
--- @param repository string
--- @param branch string
--- @param callback function
function M.clone(cwd, repository, branch, callback)
  return Pipeline.create_task(cwd, 'git', {'clone', table.concat({'https://github.com/', repository}), '-b', branch, '--progress'}, function(_, stderr)
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

--- Create A Checkout Task
--- @param cwd string
--- @param branch string
--- @param callback function?
function M.checkout(cwd, branch, callback)
  if callback ~= nil then
    callback()
  end

  return Pipeline.create_task(cwd, 'git', {'checkout', branch})
end

--- Create A Reset Task
--- @param cwd string
--- @param branch string
--- @param callback function?
function M.reset(cwd, branch, callback)
  if callback ~= nil then
    callback()
  end

  return Pipeline.create_task(cwd, 'git', {'reset', '--hard', table.concat({'origin', branch}, '/')})
end

return M
