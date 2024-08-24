local Content = require('themify.interface.content')
local Utilities = require('themify.utilities')
local Manager = require('themify.core.manager')


local Control = {}

Control.__index = Control

--- @type table<string, string>
local mappings = {
  k = 'move_cursor(nil, "up")',
  ['<Up>'] = 'move_cursor(nil, "up")',
  j = 'move_cursor(nil, "down")',
  ['<Down>'] = 'move_cursor(nil, "down")',

  ['<Left>'] = 'move_cursor(nil, "previous_title")',
  ['<Right>'] = 'move_cursor(nil, "next_title")',

  I = 'install_colorschemes()',
  U = 'update_colorschemes()'
}

--- @class Control
--- @field window Window
--- @field cursor_y number
--- @field scroll_y number

--- Create A New Controller
--- @param window Window
function Control:new(window)
  self = setmetatable({}, Control)

  self.window = window

  self.cursor_y = 1
  self.scroll_y = 1

  for lhs, rhs in pairs(mappings) do
  	vim.api.nvim_buf_set_keymap(window.buffer, 'n', lhs, table.concat({':lua require("themify.interface.window").get_window(', window.window, ').control:', rhs, '<CR>'}), {
		  nowait = true,
	  	noremap = true,
  		silent = true
	  })
  end

  vim.api.nvim_set_option_value('cursorline', true, { win = window.window })

  return self
end

--- Move The Cursor
--- @param lines nil|{ content: Text, tags: Tags[] }[]
--- @param direction 'up' | 'down' | 'next_title' | 'previous_title' | 'none'
--- @return boolean
function Control:move_cursor(lines, direction)
  if lines == nil then
    lines = Content.get_content()
  end

  if direction == 'down' or direction == 'next_title' then
    for i = self.cursor_y + 1, #lines do
      if lines[i] ~= nil
        and (
          (direction == 'down' and Utilities.contains(lines[i].tags, {'selectable'}))
          or (direction == 'next_title' and Utilities.contains(lines[i].tags, {'title'}))
        )
      then
        self.cursor_y = i

        if self.cursor_y - self.scroll_y > self.window.height - 7 then
          self.scroll_y = self.cursor_y - (self.window.height - 7)
        end

        self.window:update(lines)

        return true
      end
    end
  elseif direction == 'up' or direction == 'previous_title' then
    for i = 1, self.cursor_y - 1 do
      if lines[self.cursor_y - i] ~= nil
        and (
          (direction == 'up' and Utilities.contains(lines[self.cursor_y - i].tags, {'selectable'}))
          or (direction == 'previous_title' and Utilities.contains(lines[self.cursor_y - i].tags, {'title'}))
        )
      then
        self.cursor_y = self.cursor_y - i

        if self.cursor_y - self.scroll_y < 1 then
          self.scroll_y = self.cursor_y
        end

        self.window:update(lines)

        return true
      end
    end
  end

  return false
end

--- Check The Cursor
--- @param lines { content: Text, tags: Tags[] }[]
--- @return nil
function Control:check_cursor(lines)
  if lines[self.cursor_y] == nil
    or (
      not Utilities.contains(lines[self.cursor_y].tags, {'selectable'})
      and not Utilities.contains(lines[self.cursor_y].tags, {'title'})
    )
  then
    if not self:move_cursor(lines, 'down') then
      self:move_cursor(lines, 'up')
    end
  end
end

--- Install The Colorschemes
function Control:install_colorschemes()
  Manager.install_colorschemes()
end

--- Update The Colorschemes
function Control:update_colorschemes()
  Manager.update_colorschemes()
end

return Control
