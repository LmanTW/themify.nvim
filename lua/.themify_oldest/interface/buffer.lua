local Window = require('themify.interface.window')
local Text = require('themify.interface.text')
local Data = require('themify.core.data')

local M = {}

local buffer = vim.api.nvim_create_buf(false, true)

vim.api.nvim_set_option_value('modifiable', true, { buf = buffer })

-- Get The Buffer
function M.get_buffer()
  return buffer
end

-- Render The Interface
function M.render(cursor_y, scroll_y)
  local size = Window.get_size()

  vim.api.nvim_set_option_value('modifiable', true, { buf = buffer })

  vim.api.nvim_buf_set_lines(buffer, 0, -1, false, {})

  Text.create('- Themify -', 'Bold'):center(size.width):render(buffer, 1)

  local index = 0

  for theme_name, theme_info in pairs(Data.get_themes_info()) do
    local icon

    if (theme_info.state == 'installed') then icon = ' '
    elseif (theme_info.state == 'not_installed') then icon = ' ' end

    Text.combine({
      Text.create('  ' .. icon .. ' '),
      Text.create(theme_name)
    }):render(buffer, 3 + index)

    index = index + 1
  end

  Text.combine({
    Text.create(' Install (I) ', 'Comment'),
    Text.create(' Update (U) ', 'Comment')
  }):center(size.width):render(buffer, size.height - 2) 

  vim.api.nvim_set_option_value('modifiable', false, { buf = buffer })

  vim.api.nvim_win_set_cursor(Window.get_window(), {4 + cursor_y, 0})
end

return M
