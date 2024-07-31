local Control = {}

Control.__index = Control

local mappings = {
  k = 'scroll(-1)',
  ['<Up>'] = 'scroll(-1)',
  j = 'scroll(1)',
  ['<Down>'] = 'scroll(1)',

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
  print(direction)
end

return Control
