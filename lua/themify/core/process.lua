local Process = {}
Process.__index = Process

--- @class Process
--- @field private _stdout any
--- @field private _stderr any
--- @field private _handle any

--- Execute A Command
--- @param cwd string
--- @param command string
--- @param args string[]
--- @param callback function
function Process.execute(cwd, command, args, callback)
  local stdout
  local stderr

  local process = Process:new(cwd, command, args, function(code)
    callback(code, stdout, stderr)
  end)

  process:on_stdout(function(data)
    stdout = data
  end)

  process:on_stderr(function(data)
    stderr = data
  end)
end

--- Create A Process
--- @param cwd string
--- @param command string
--- @param args string[]
--- @param callback function
function Process:new(cwd, command, args, callback)
  self = setmetatable({}, Process)

  self._stdout = vim.loop.new_pipe(false)
  self._stderr = vim.loop.new_pipe(false)

  self._handle = vim.loop.spawn(command, {
    cwd = cwd,
    args = args,

    stdio = {nil, self._stdout, self._stderr}
  }, function(code, signal)
    self._handle:close()
    self._stdout:close()
    self._stderr:close()

    callback(code, signal)
  end)

  return self
end

--- Listen To Stdout
--- @param callback function
--- @return nil
function Process:on_stdout(callback)
  self._stdout:read_start(function(_, data)
    if data ~= nil then
      callback(data)
    end
  end)
end

--- Listen To Stderr
--- @param callback function
--- @return nil
function Process:on_stderr(callback)
  self._stderr:read_start(function(_, data)
    if data ~= nil then
      callback(data)
    end
  end)
end

return Process
