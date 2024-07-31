local Utilities = require('themify.utilities')
local Colorschemes = require('themify.core.colorschemes')
local Window = require('themify.interface.window')
local Color = require('themify.interface.color')
local Text = require('themify.interface.text')

local M = {
  buffer = vim.api.nvim_create_buf(false, true)
}

vim.api.nvim_set_option_value('modifiable', false, { buf = M.buffer })

-- Render The Interface
function M.render(cursor_y, scroll_y)
  vim.api.nvim_set_option_value('modifiable', true, { buf = M.buffer })

  -- Reset the buffer.

  vim.api.nvim_buf_set_lines(M.buffer, 0, -1, false, {})

  -- Render the content.

  Text.create('- Themify   -', Color.title):center(Window.size.width):render(M.buffer, 1)

  local index = 0

  for _, line in pairs(M.get_lines(true)) do
    if index - scroll_y >= 0 and index - scroll_y < Window.size.height - 6 then
      line:render(M.buffer, 3 + (index - scroll_y))
    end

    index = index + 1
  end

  Text.create('Install (I)  Update (U)', Color.description):center(Window.size.width):render(M.buffer, Window.size.height - 2)

  vim.api.nvim_set_option_value('modifiable', false, { buf = M.buffer })

  -- Move the cursor. 

  vim.api.nvim_win_set_cursor(Window.window, {4 + (cursor_y - scroll_y), 0})
end

-- Get Lines
function M.get_lines(render)
  local lines = {}

  for _, colorscheme_info in pairs(Colorschemes.colorschemes_info) do
    local icon

    if colorscheme_info.state == nil then icon = '󰘥'
    elseif colorscheme_info.state == 'installed' then icon = '󰗡'
    elseif colorscheme_info.state == 'installing' then icon = '󰄰'
    elseif colorscheme_info.state == 'idle' then icon = '󱑥' end

    if render then
      table.insert(lines, Text.combine({
        Text.create('  '),
        Text.create(icon, Color.icon),
        Text.create(' ' .. colorscheme_info.name)
      }))
    else
      table.insert(lines, { type = 'colorscheme' })
    end

    if colorscheme_info.progress ~= nil then
      if render then
        table.insert(lines, Text.combine({
          Text.create('  Installing: ', Color.description),
          Text.create(colorscheme_info.progress)
        }))
      else
        table.insert(lines, { type = 'progress' })
      end
    end
  end

  return lines
end

return M
