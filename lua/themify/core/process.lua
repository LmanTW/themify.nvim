local Process = {}

Process.__index = Process

-- Create A Process
function Process:new(command, args, callback)
  self = setmetatable({}, Process)

  self.stdout = vim.loop.new_pipe(false)
  self.stderr = vim.loop.new_pipe(false)

  self.handle = vim.loop.spawn(command, {
    args = args,

    stdio = {nil, self.stdout, self.stderr}
  }, function(code, signal)
    self.handle:close()
    self.stdout:close()
    self.stderr:close()

    callback(code, signal)
  end)

  return self
end

-- Listen To Stdout
function Process:on_stdout(callback)
  self.stdout:read_start(function(_, data)
    if data ~= nil then
      callback(data)
    end
  end)
end

-- Listen To Stderr
function Process:on_stderr(callback)
  self.stderr:read_start(function(_, data)
    if data ~= nil then
      callback(data)
    end
  end)
end

return Process
