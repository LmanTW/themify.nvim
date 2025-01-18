--- @class Process
--- @field handle any
--- @field stdout any
--- @field stderr any

local Utilities = require('themify.utilities')
local Process = {}

Process.__index = Process

--- Execute a command.
--- @param command string
--- @return any
function Process.execute(command)
  local handle = io.popen(command)

  Utilities.error(handle == nil, {'[Themify] Failed to execute command "', command, '"'})

  local result = handle:read('*a')
  handle:close()

  return result
end

--- Execute a command asynchrony.
--- @param cwd string
--- @param command string
--- @param args string[]
--- @param callback function
function Process.execute_async(cwd, command, args, callback)
  local output_stdout, output_stderr

  local process = Process:new(cwd, command, args, function(code)
    callback(code, output_stdout, output_stderr)
  end)

  process:listen(function(stdout, stderr)
    if stdout ~= nil then
      output_stdout = stdout
    end

    if stderr ~= nil then
      output_stderr = stderr
    end
  end)
end


--- Create a new process.
--- @param cwd string
--- @param command string
--- @param args string[]
--- @param callback function
function Process:new(cwd, command, args, callback)
  self = setmetatable({}, Process)

  self.stdout = vim.uv.new_pipe(false)
  self.stderr = vim.uv.new_pipe(false)

  self.handle = vim.uv.spawn(command, {
    cwd = cwd,
    args = args,

    stdio = {nil, self.stdout, self.stderr}
  }, function(code)
    self.handle:close()
    self.stdout:close()
    self.stderr:close()

    callback(code)
  end)

  return self
end

--- Listen to the output.
--- @param callback function
--- @return nil
function Process:listen(callback)
  self.stdout:read_start(function(_, data)
    if data ~= nil then
      callback(data, nil)
    end
  end)

  self.stderr:read_start(function(_, data)
    if data ~= nil then
      callback(nil, data)
    end
  end)
end

return Process
