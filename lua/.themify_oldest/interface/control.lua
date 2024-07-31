local Buffer = require('themify.interface.buffer')
local Window = require('themify.interface.window')
local Utilities = require('themify.utilities')
local Data = require('themify.core.data')

local M = {}

local mappings = {
  k = 'scroll(-1)',
  ['<Up>'] = 'scroll(-1)',
  j = 'scroll(1)',
  ['<Down>'] = 'scroll(1)',

  ['<Left>'] = 'scroll(0)',
  ['<Right>'] = 'scroll(0)'
}

for lhs, rhs in pairs(mappings) do
	vim.api.nvim_buf_set_keymap(Buffer.get_buffer(), 'n', lhs, ':lua require("themify.control").' .. rhs .. "<CR>", {
		nowait = true,
		noremap = true,
		silent = true,
	})
end

local cursor_y = 0
local scroll_y = 0

-- Scroll
function M.scroll(direction)
  if direction == 0 then
    vim.api.nvim_win_set_cursor(Window.get_window(), {4 + cursor_y, 0})
  else
    cursor_y = cursor_y + direction

    if cursor_y < 0 then cursor_y = 0
    elseif cursor_y >= Utilities.size(Data.get_themes_info()) then cursor_y = Utilities.size(Data.get_themes_info()) - 1 end

    -- Render first otherwise the cursor is going to get reset.

    Buffer.render(cursor_y, scroll_y)
  end
end

-- Get The Control
function M.get_control()
  return cursor_y, scroll_y
end

-- Reset The Control
function M.reset()
  cursor_y = 0
  scroll_y = 0
end

return M
