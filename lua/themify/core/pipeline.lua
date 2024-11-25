--- @class Pipeline
--- @field tasks Task[]

--- @alias Task { cwd: string, command: string, args: string[], callback?: function }

local Process = require('themify.core.process')
local Pipeline = {}

Pipeline.__index = Pipeline

--- Create a task.
--- @param command string
--- @param args string[]
--- @param callback function?
--- @return Task
function Pipeline.create_task(cwd, command, args, callback)
  return { cwd = cwd, command = command, args = args, callback = callback }
end

--- Create a new pipeline.
--- @param tasks Task[]
function Pipeline:new(tasks)
  self = setmetatable({}, Pipeline)

  self.tasks = tasks

  return self
end

--- Start the pipeline.
--- @param callback function
function Pipeline:start(callback)
  local current_task = 0

  -- Execute the next task.
  local function next()
    current_task = current_task + 1

    local stdout_output
    local stderr_output

    local task = self.tasks[current_task]

    local process = Process:new(task.cwd, task.command, task.args, function(code)
      if code == 0 and current_task < #self.tasks then
        next()
      else
        callback(code, stdout_output, stderr_output)
      end
    end)

    process:listen(function(stdout, stderr)
      if task.callback ~= nil then
        task.callback(stdout, stderr)
      end

      if stdout ~= nil then stdout_output = stdout end
      if stderr ~= nil then stderr_output = stderr end
    end)
  end

  next()
end

return Pipeline
