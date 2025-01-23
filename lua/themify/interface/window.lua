--- @class Window
--- @field buffer integer
--- @field window integer
--- @field page string
--- @field control Control
--- @field updater Updater
--- @field width number
--- @field height number

local Cache = require('themify.interface.components.cache')
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

--- Get a window.
--- @param id integer
function Window.get_window(id)
  Utilities.error(windows[id] == nil, {'[Themify] Window not found: "', tostring(id), '"'})

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

vim.api.nvim_create_autocmd('VimResized', {
  callback = function(args)
    local transformation = Window.get_window_transformation()

    for id in pairs(windows) do
      vim.api.nvim_win_set_config(id, {
        relative = 'editor',

        col = transformation.x,
        row = transformation.y,
        width = transformation.width,
        height = transformation.height
      })

      windows[id].width = transformation.width
      windows[id].height = transformation.height
      windows[id].control.height = transformation.height

      windows[id]:update()
    end    
  end
})

Event.listen('interface-update', function()
  for id in pairs(windows) do
    windows[id].updater:update()
  end
end)

--- Get the transformation of the window.
--- @return { x: number, y: number, width: number, height: number } 
function Window.get_window_transformation()
  local screen_width = vim.api.nvim_get_option_value('columns', { scope = 'global' })
  local screen_height = vim.api.nvim_get_option_value('lines', { scope = 'global' })

  local width = math.ceil(screen_width * 0.5)
  local height = math.ceil(screen_height * 0.5)

  return {
    -- Yes, I use x and y.

    x = math.floor((screen_width - width) / 2),
    y = math.floor((screen_height - height) / 2),
    width = width,
    height = height
  }
end

--- Create a new window.
function Window:new()
  self = setmetatable({}, Window)

  local transformation = Window.get_window_transformation()

  self.buffer = vim.api.nvim_create_buf(false, true)
  self.window = vim.api.nvim_open_win(self.buffer, true, {
    relative = 'editor',

    col = transformation.x,
    row = transformation.y,
    width = transformation.width,
    height = transformation.height,

    style = 'minimal',
    border = 'rounded',

    zindex = 999
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

  local content = Pages.update_page(self.page)
  local control = self.control:get_page_control(self.page)

  if content[control.cursor_y] ~= nil and vim.list_contains(content[control.cursor_y].tags, 'selectable') then
    Pages.get_page(self.page).hover(content[control.cursor_y])
  end

  Event.emit('interface-opened', self.window)

  return self
end

--- Move the cursor.
--- @param direction 'up'|'down'
--- @return nil
function Window:move_cursor(direction)
  local content = Pages.update_page(self.page)
  local control = self.control:get_page_control(self.page)

  self.control:move_cursor(self.page, direction)

  if content[control.cursor_y] ~= nil and vim.list_contains(content[control.cursor_y].tags, 'selectable') then
    Pages.get_page(self.page).hover(content[control.cursor_y])
  end

  self:update()
end

--- Select the current line.
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

--- Switch a page.
--- @param direction 'left'|'right'
--- @return nil
function Window:switch_page(direction)
  self.page = self.control:switch_page(self.page, direction)

  local content = Pages.update_page(self.page)
  local control = self.control:get_page_control(self.page)

  if content[control.cursor_y] ~= nil and vim.list_contains(content[control.cursor_y].tags, 'selectable') then
    Pages.get_page(self.page).hover(content[control.cursor_y])
  end

  control.scroll_y = 1

  self.control:check_scroll(self.page)

  self:update()
end

--- Install the colorschemes.
--- @return nil
function Window:install_colorschemes()
  Manager.install_colorschemes()

  self.page = self.control:enter_page(self.page, 'manage')

  self:update()
end

--- Update the colorschemes.
--- @return nil
function Window:update_colorschemes()
  Manager.update_colorschemes()

  self.page = self.control:enter_page(self.page, 'manage')

  self:update()
end

--- Check The Colorschemes
--- @return nil
function Window:check_colorschemes()
  Manager.check_colorschemes()

  self.page = self.control:enter_page(self.page, 'manage')

  self:update()
end

--- Update the window.
--- @return nil
function Window:update()
  vim.api.nvim_set_option_value('modifiable', true, { buf = self.buffer })
  vim.api.nvim_buf_set_lines(self.buffer, 0, -1, false, {})

  local content = Pages.get_page_content(self.page)
  local control = self.control:get_page_control(self.page)

  for i = 1, #content do
    if i - control.scroll_y >= 0 and i - control.scroll_y < self.height - 6 then
      content[i].content:render(self.buffer, 2 + (i - control.scroll_y))
    end
  end

  -- Render the page tab.

  local left = table.concat({'< ', Pages.pages[Pages.get_neighbor_page(self.page, -1)].name})
  local current = table.concat({'- ', Pages.pages[self.page].name, ' -'})
  local right = table.concat({Pages.pages[Pages.get_neighbor_page(self.page, 1)].name, ' >'})

  Text.combine({
    Cache.text_padding_2,
    Text:new(left, Colors.description),
    Text:new(string.rep(' ', math.ceil((self.width / 2) - (current:len() / 2)) - (left:len() + 2))),
    Text:new(current, Colors.title),
    Text:new(string.rep(' ', math.floor((self.width / 2) - (current:len() / 2)) - (right:len() + 2))),
    Text:new(right, Colors.description),
    Cache.text_padding_2
  }):render(self.buffer, 1)

  -- Render the actions and info.

  local amount = Manager.colorschemes_amount

  local actions = '  (I) Install  (U) Update  (C) Check  '
  local info = table.concat({(amount.installed == nil and 0 or amount.installed) + (amount['local'] == nil and 0 or amount['local']), ' / ', tostring(#Manager.colorschemes_id), '  '})

  Text.combine({
    Cache.text_padding_2,
    Text:new('(I) Install', amount.not_installed == nil and Colors.description or nil),
    Cache.text_padding_2,
    Cache.text_update,
    Cache.text_padding_2,
    Cache.text_check,
    Text:new(string.rep(' ', (self.width - actions:len()) - info:len())),
    Text:new(info)
  }):render(self.buffer, self.height - 2)

  vim.api.nvim_set_option_value('modifiable', false, { buf = self.buffer })

  -- Move the cursor.
  vim.api.nvim_win_set_cursor(self.window, {4 + (control.cursor_y - control.scroll_y), 0})
end

-- Close The Window.
function Window:close()
  vim.api.nvim_win_close(self.window, false)

  Event.emit('interface-closed')
end

return Window
