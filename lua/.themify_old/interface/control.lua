local Colorschemes = require('themify.core.colorschemes')
local Buffer = require('themify.interface.buffer')
local Window = require('themify.interface.window')
local Utilities = require('themify.utilities')

local M = {
  cursor_y = 0,
  scroll_y = 0
}

local mappings = {
  k = 'scroll(-1)',
  ['<Up>'] = 'scroll(-1)',
  j = 'scroll(1)',
  ['<Down>'] = 'scroll(1)',

  ['<Left>'] = 'scroll(0)',
  ['<Right>'] = 'scroll(0)',

  I = 'install()'
}

for lhs, rhs in pairs(mappings) do
	vim.api.nvim_buf_set_keymap(Buffer.buffer, 'n', lhs, ':lua require("themify.interface.control").' .. rhs .. "<CR>", {
		nowait = true,
		noremap = true,
		silent = true,
	})
end

-- Scroll
function M.scroll(direction)
  if direction == 0 then
    vim.api.nvim_win_set_cursor(Window.window, {4 + M.cursor_y, 0})
  else
    M.cursor_y = M.cursor_y + direction

    local lines = Utilities.size(Buffer.get_lines(false))

    if M.cursor_y < 0 then M.cursor_y = 0
    elseif M.cursor_y >= lines then M.cursor_y = lines - 1 end

    -- Make sure the cursor is not out of the window by changing the scrolling.

    if M.cursor_y > Window.size.height - 7 then
      M.scroll_y = M.cursor_y - (Window.size.height - 7)
    else
      M.scroll_y = 0
    end

    -- Render first otherwise the cursor is going to get reset.

    Buffer.render(M.cursor_y, M.scroll_y)
  end
end

-- Install
function M.install()
  Colorschemes.install()
end

-- Reset The Control
function M.reset()
  M.cursor_y = 0
  M.scroll_y = 0
end

return M
