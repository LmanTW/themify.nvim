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
    Process.close(self)

    callback(code, signal)
  end)

  return self
end

-- Close The Process
function Process:close()
  self.handle:close()
  self.stdout:close()
  self.stderr:close()
end

return Process
