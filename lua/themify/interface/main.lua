local Text = require('themify.interface.components.text')
local Control = require('themify.interface.control')
local Buffer = require('themify.interface.buffer')
local Window = require('themify.interface.window')
local Color = require('themify.interface.color')
local Manager = require('themify.core.manager')

local Home = require('themify.interface.pages.home')

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
function Interface:new(close_callback)
  self = setmetatable({}, Interface)

  self.close_callback = close_callback

  self.buffer = Buffer:new()
  self.window = Window:new(self.buffer.buffer)
  self.control = Control:new(self)

  interfaces[self.window.window] = self

  return self
end

-- Close The Interface
function Interface:close()
  if self.window == nil then
    error('Themify: The interface is already closed')
  end

  interfaces[self.window.window] = nil

  self.buffer = nil
  self.window = nil
  self.control = nil

  self.close_callback()
end

-- Get Page Content
function Interface:get_page()
  return Home
end

-- Render The Interface
function Interface:render()
  if self.window == nil then
    error('Themify: The interface is already closed')
  end

  vim.api.nvim_set_option_value('modifiable', true, { buf = self.buffer.buffer })

  -- Clear the buffer.

  vim.api.nvim_buf_set_lines(self.buffer.buffer, 0, -1, false, {})

  local page = Interface.get_page(self)

  Text:new('- ' .. page.title .. ' -', Color.title):center(self.window.width):render(self.buffer.buffer, 1)

  local lines = page.get_content()

  for i = 1, #lines do
    if i - self.control.scroll_y >= 0 and i - self.control.scroll_y < self.window.height - 6 then
      lines[i].text:render(self.buffer.buffer, 3 + (i - self.control.scroll_y))
    end
  end

  Text:new('Install (I)  Update (U)', Color.description):center(self.window.width):render(self.buffer.buffer, self.window.height - 2)

  vim.api.nvim_set_option_value('modifiable', false, { buf = self.buffer.buffer })

  -- Move the cursor.

  vim.api.nvim_win_set_cursor(self.window.window, {4 + (self.control.cursor_y - self.control.scroll_y), 0})
end

return Interface
