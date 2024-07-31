local Control = require('themify.interface.control')
local Buffer = require('themify.interface.buffer')
local Window = require('themify.interface.window')
local Color = require('themify.interface.color')
local Text = require('themify.interface.text')

local Interface = {}

Interface.__index = Interface

local interfaces = {}

-- Get An Interface
function Interface.get_interface(id)
  if interfaces[id] == nil then
    error('Themify: Interface not found "' .. id .. '"')
  end

  return interfaces[id]
end

-- Create An Interface
function Interface:new()
  self = setmetatable({}, Interface)

  self.buffer = Buffer:new()
  self.window = Window:new(self.buffer.buffer)
  self.controller = Control:new(self)

  interfaces[self.window.window] = self

  Interface.render(self)
end

-- Render The Interface
function Interface:render()
  vim.api.nvim_set_option_value('modifiable', true, { buf = self.buffer.buffer })

  -- Clear the buffer.

  vim.api.nvim_buf_set_lines(self.buffer.buffer, 0, -1, false, {})

  Text:new('- Themify -', Color.title):center(self.window.width):render(self.buffer.buffer, 1)

  local lines = M.get_colorschemes_lines()

  for i = 1, #lines do
    if i - self.controller.scroll_y >= 0 and i - self.controller.scroll_y < self.window.height - 6 then
      lines[i]:render(self.buffer.buffer, 3 + (i - self.controller.scroll_y))
    end
  end

  Text:new('Install (I)  Update (U)', Color.description):center(self.window.width):render(self.buffer.buffer, interface.window.height - 2)

  vim.api.nvim_set_option_value('modifiable', false, { buf = self.buffer.buffer })

  -- Move the cursor.

  vim.api.nvim_win_set_cursor(self.window.window, {4 + (self.controller.cursor_y - self.controller.scroll_y), 0})
end

return Interface
