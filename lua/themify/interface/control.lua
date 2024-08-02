local Manager = require('themify.core.manager')

local Control = {}

Control.__index = Control

local mappings = {
  k = 'scroll(-1)',
  ['<Up>'] = 'scroll("up")',
  j = 'scroll(1)',
  ['<Down>'] = 'scroll("down")',

  ['<Left>'] = 'scroll(0)',
  ['<Right>'] = 'scroll(0)',

  I = 'install()'
}

-- Create A New Controller
function Control:new(interface)
  self = setmetatable({}, Control)

  self.interface = interface

  self.cursor_y = 1
  self.scroll_y = 1

  for lhs, rhs in pairs(mappings) do
  	vim.api.nvim_buf_set_keymap(interface.buffer.buffer, 'n', lhs, ':lua require("themify.interface.main").get_interface(' .. interface.window.window .. ').control:' .. rhs .. "<CR>", {
		  nowait = true,
	  	noremap = true,
  		silent = true
	  })
  end

  return self
end

-- Scroll
function Control:scroll(direction)
  local lines = self.interface.get_page().get_content()

  if direction == 'up' then
    for i = 1, self.cursor_y - 1 do
      if lines[self.cursor_y - i].selectable then
        self.cursor_y = self.cursor_y - i

        break
      end
    end
  elseif direction == 'down' then
    for i = self.cursor_y + 1, #lines do
      if lines[i].selectable then
        self.cursor_y = i

        break
      end
    end
  end

  if lines[self.cursor_y].type ~= 'theme' then
    self.cursor_y = 0

    Control.scroll(self, 'down')
  end

  self.interface:render()
end

-- Install
function Control:install()
  Manager.install_colorschemes()
end

return Control
