--- @class Control
--- @field window integer
--- @field height number
--- @field pages table<string, { cursor_y: number, scroll_y: number }>

local Pages = require('themify.interface.pages')
local Utilities = require('themify.utilities')

local Control = {}
Control.__index = Control

local mapping = {
  k = 'move_cursor("up")',
  ['<Up>'] = 'move_cursor("up")',
  j = 'move_cursor("down")',
  ['<Down>'] = 'move_cursor("down")',

  gg = 'move_cursor("top")',
  ['<S-Up>'] = 'move_cursor("top")',
  G = 'move_cursor("bottom")',
  ['<S-Down>'] = 'move_cursor("bottom")',

  ['<CR>'] = 'select()',

  h = 'switch_page("left")',
  ['<Left>'] = 'switch_page("left")',
  l = 'switch_page("right")',
  ['<Right>'] = 'switch_page("right")',

  I = 'install_colorschemes()',
  U = 'update_colorschemes()',
  C = 'check_colorschemes()',

  q = 'close()'
}

--- Create a new control.
--- @param window integer
function Control:new(window)
  self = setmetatable({}, Control)

  self.window = window
  self.height = vim.api.nvim_win_get_height(window)
  self.pages = {}

  local buffer = vim.api.nvim_win_get_buf(window)

  for lhs, rhs in pairs(mapping) do
  	vim.api.nvim_buf_set_keymap(buffer, 'n', lhs, table.concat({':lua require("themify.interface.window").get_window(', window, '):', rhs, '<CR>'}), {
		  nowait = true,
	  	noremap = true,
  		silent = true
	  })
  end

  for i = 1, #Pages.pages_id do
    self.pages[Pages.pages_id[i]] = { cursor_y = 1, scroll_y = 1 }
  end

  return self
end

--- Get the control of a page.
--- @param page string
--- @return { cursor_y: number, scroll_y: number }
function Control:get_page_control(page)
  Utilities.error(self.pages[page] == nil, {'Themify: Page not found: "', page, '"'})

  return self.pages[page]
end

--- Move the cursor.
--- @param page string
--- @param direction 'up'|'down'
--- @return boolean
function Control:move_cursor(page, direction)
  local content = Pages.get_page_content(page)
  local control = self:get_page_control(page)

  if direction == 'up' then
    for i = 1, control.cursor_y - 1 do
      if content[control.cursor_y - i] ~= nil and vim.list_contains(content[control.cursor_y - i].tags, 'selectable') then
        control.cursor_y = control.cursor_y - i

        if control.cursor_y - control.scroll_y < 1 then
          control.scroll_y = control.cursor_y
        end

        return true
      end
    end
  elseif direction == 'down' then
    for i = control.cursor_y + 1, #content do
      if content[i] ~= nil and vim.list_contains(content[i].tags, 'selectable') then
        control.cursor_y = i

        if control.cursor_y - control.scroll_y > self.height - 7 then
          control.scroll_y = control.cursor_y - (self.height - 7)
        end

        return true
      end
    end
  elseif direction == 'top' then
    for i = 1, #content do
      if content[i] ~= nil and vim.list_contains(content[i].tags, 'selectable') then
        control.cursor_y = i

        if control.cursor_y - control.scroll_y < 1 then
          control.scroll_y = control.cursor_y
        end

        return true
      end
    end
  elseif direction == 'bottom' then
    for i = 0, #content do
      if content[#content - i] ~= nil and vim.list_contains(content[#content - i].tags, 'selectable') then
        control.cursor_y = #content - i

        if control.cursor_y - control.scroll_y > self.height - 7 then
          control.scroll_y = control.cursor_y - (self.height - 7)
        end

        return true
      end
    end
  end

  return false
end

--- Check the cursor.
--- @param page string
--- @return nil
function Control:check_cursor(page)
  local content = Pages.get_page_content(page)
  local control = self:get_page_control(page)

  if (content[control.cursor_y] == nil or not vim.list_contains(content[control.cursor_y].tags, 'selectable')) then
    if not self:move_cursor(page, 'up') then
      self:move_cursor(page, 'down')
    end
  end
end

--- Check the scrolling.
--- @param page string
--- @return nil
function Control:check_scroll(page)
  local control = self:get_page_control(page)

  if control.cursor_y - control.scroll_y > self.height - 7 then
    control.scroll_y = control.cursor_y - (self.height - 7)
  end
end

--- Switch a page.
--- @param page string
--- @param direction 'left'|'right'
--- @return nil
function Control:switch_page(page, direction)
  local new_page = Pages.get_neighbor_page(page, direction == 'left' and -1 or 1)

  self:enter_page(page, new_page)

  return new_page
end

--- Enter a page.
--- @param old_page nil|string
--- @param new_page string
--- @return string
function Control:enter_page(old_page, new_page)
  if old_page ~= nil then
    Pages.get_page(old_page).leave(Pages.get_page_content(old_page))
  end

  local content = Pages.update_page(new_page)

  local control = self:get_page_control(new_page)
  control.cursor_y = Pages.get_page(new_page).enter(content)

  self:check_cursor(new_page)
  self:check_scroll(new_page)

  return new_page
end

return Control
