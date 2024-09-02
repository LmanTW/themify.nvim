--- @class Window
--- @field buffer integer
--- @field window integer
--- @field page string
--- @field control Control
--- @field updater Updater
--- @field width number
--- @field height number

local Text = require('themify.interface.components.text')
local Control = require('themify.interface.control')
local Updater = require('themify.interface.updater')
local Colors = require('themify.interface.colors')
local Pages = require('themify.interface.pages')
local Manager = require('themify.core.manager')
local Utilities = require('themify.utilities')
local Event = require('themify.core.event')

local Window = {}
Window.__index = Window

--- @type table<integer, Window>
local windows = {}

--- Get A Window
--- @param id integer
function Window.get_window(id)
  Utilities.error(windows[id] == nil, {'Themify: Window not found: "', tostring(id), '"'})

  return windows[id]
end

vim.api.nvim_create_autocmd('WinClosed', {
  callback = function(args)
    local window_id = tonumber(args.match)

    if window_id ~= nil and windows[window_id] ~= nil then
      local window = windows[window_id]

      Pages.get_page(window.page).leave()
      windows[window_id].updater:stop()

      windows[window_id] = nil
    end
  end
})

Event.listen('update', function()
  for id in pairs(windows) do
    windows[id].updater:update()
  end
end)

--- Get The Transformation Of The Window
--- @return { x: number, y: number, width: number, height: number } 
local function get_window_transformation()
  local total_width = vim.api.nvim_get_option_value('columns', { scope = 'global' })
  local total_height = vim.api.nvim_get_option_value('lines', { scope = 'global' })

  local window_width = math.ceil(total_width * 0.5)
  local window_height = math.ceil(total_height * 0.5)

  return {
    -- Yes, I like to use x and y.

    x = math.ceil((total_width - window_width) / 2),
    y = math.ceil((total_height - window_height) / 2),
    width = window_width,
    height = window_height
  }
end

--- Create A New Windowr
function Window:new()
  self = setmetatable({}, Window)

  local transformation = get_window_transformation()

  self.buffer = vim.api.nvim_create_buf(false, true)
  self.window = vim.api.nvim_open_win(self.buffer, true, {
    relative = 'editor',
    col = transformation.x,
    row = transformation.y,
    width = transformation.width,
    height = transformation.height,

    style = 'minimal',
    border = 'rounded'
  })

  self.page = 'home'
  self.control = Control:new(self.window)
  self.updater = Updater:new(function()
    Pages.update_page(self.page)
    self:update()
  end)

  self.width = transformation.width
  self.height = transformation.height

  vim.api.nvim_set_option_value('modifiable', false, { buf = self.buffer })
  vim.api.nvim_set_option_value('cursorline', true, { win = self.window })
  vim.api.nvim_set_current_win(self.window)

  windows[self.window] = self

  self.control:enter_page(nil, self.page)

  return self
end

--- Move The Cursor
--- @param direction 'up'|'down'
--- @return nil
function Window:move_cursor(direction)
  local content = Pages.update_page(self.page)
  local control = self.control:get_page_control(self.page)

  self.control:move_cursor(self.page, direction)

  if content[control.cursor_y] ~= nil then
    Pages.get_page(self.page).hover(content[control.cursor_y])
  end

  self:update()
end

--- Select The Current Line
--- @return nil
function Window:select()
  self.control:check_cursor(self.page)

  local content = Pages.update_page(self.page)
  local control = self.control:get_page_control(self.page)

  if content[control.cursor_y] ~= nil then
    local flags = Pages.get_page(self.page).select(content[control.cursor_y])

    if vim.list_contains(flags, 'update') then
      Pages.update_page(self.page)
      self:update()
    end
    if vim.list_contains(flags, 'close') then
      vim.api.nvim_win_close(self.window, false)
    end
  end
end

--- Switch The Page
--- @param direction 'left'|'right'
--- @return nil
function Window:switch_page(direction)
  self.page = self.control:switch_page(self.page, direction)

  self.control:check_cursor(self.page)

  self:update()
end

--- Check The Colorschemes
--- @return nil
function Window:check_colorschemes()
  Manager.check_colorschemes()

  self.page = self.control:enter_page(self.page, 'manager')

  self:update()
end

--- Install The Colorschemes
--- @return nil
function Window:install_colorschemes()
  Manager.install_colorschemes()

  self.page = self.control:enter_page(self.page, 'manager')

  self:update()
end

--- Update The Colorschemes
--- @return nil
function Window:update_colorschemes()
  Manager.update_colorschemes()

  self.page = self.control:enter_page(self.page, 'manager')

  self:update()
end

--- Update The Window
--- @return nil
function Window:update()
  vim.api.nvim_set_option_value('modifiable', true, { buf = self.buffer })

  -- Clear the buffer.
  vim.api.nvim_buf_set_lines(self.buffer, 0, -1, false, {})

  local content = Pages.get_page_content(self.page)
  local control = self.control:get_page_control(self.page)

  for i = 1, #content do
    if i - control.scroll_y >= 0 and i - control.scroll_y < self.height - 6 then
      content[i].content:render(self.buffer, 2 + (i - control.scroll_y))
    end
  end

  local left = table.concat({'  < ', Pages.pages[Pages.get_neighbor_page(self.page, -1)].name})
  local current = table.concat({'- ', Pages.pages[self.page].name, ' -'})
  local right = table.concat({Pages.pages[Pages.get_neighbor_page(self.page, 1)].name, ' >  '})

  Text.combine({
    Text:new(left, Colors.description),
    Text:new(string.rep(' ', math.floor((self.width / 2) - (current:len() / 2)) - left:len())),
    Text:new(current, Colors.title),
    Text:new(string.rep(' ', math.floor((self.width / 2) - (current:len() / 2)) - right:len())),
    Text:new(right, Colors.description)
  }):render(self.buffer, 1)

  local amount = Manager.colorschemes_amount

  local actions = '  (I) Install  (U) Update  (C) Check  '
  local info = table.concat({amount.installed == nil and '0' or tostring(amount.installed), ' / ', tostring(#Manager.colorschemes_repository), '  '})

  Text.combine({
    Text:new('  '),
    Text:new('(I) Install', amount.not_installed == nil and Colors.description or nil),
    Text:new('  '),
    Text:new('(U) Update', Colors.description),
    Text:new('  '),
    Text:new('(C) Check', Colors.description),
    Text:new('  '),
    Text:new(string.rep(' ', (self.width - actions:len()) - info:len())),
    Text:new(info)
  }):render(self.buffer, self.height - 2)

  vim.api.nvim_set_option_value('modifiable', false, { buf = self.buffer })

  -- Move the cursor.
  vim.api.nvim_win_set_cursor(self.window, {4 + (control.cursor_y - control.scroll_y), 0})
end

return Window
