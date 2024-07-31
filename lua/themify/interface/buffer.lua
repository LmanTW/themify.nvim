local Buffer = {}

Buffer.__index = Buffer

-- Create A Buffer
function Buffer:new()
  self = setmetatable({}, Buffer)

  self.buffer = vim.api.nvim_create_buf(false, true)

  vim.api.nvim_set_option_value('modifiable', false, { buf = self.buffer })

  return self
end

return Buffer
