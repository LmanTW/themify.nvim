local Window = {}

Window.__index = Window

-- Get The Transformation Of The Window
local function get_window_transformation()
  local total_width = vim.api.nvim_get_option('columns')
  local total_height = vim.api.nvim_get_option('lines')

  local window_width = math.ceil(total_width * 0.5)
  local window_height = math.ceil(total_height * 0.5)

  return {
    -- Yes, I like to use x and y.

    x = math.ceil((total_width - window_width) / 2),
    y = math.ceil((total_height - window_height) / 2),
    width = window_width,
    height = window_height
  }
end

-- Create A Window 
function Window:new(buffer)
  self = setmetatable({}, Window)

  local transformation = get_window_transformation()

  self.window = vim.api.nvim_open_win(buffer, true, {
    relative = 'editor',
    col = transformation.x,
    row = transformation.y,
    width = transformation.width,
    height = transformation.height,

    style = 'minimal',
    border = 'rounded'
  })

  self.width = transformation.width
  self.height = transformation.height

  vim.api.nvim_set_option_value('cursorline', true, { win = self.window })

  return self
end

return Window
