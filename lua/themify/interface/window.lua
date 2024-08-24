local Text = require('themify.interface.components.text')
local Control = require('themify.interface.control')
local Content = require('themify.interface.content')
local Color = require('themify.interface.color')
local Loader = require('themify.core.loader')
local Event = require('themify.core.event')

local Window = {}

Window.__index = Window

--- @type table<number, Window>
local windows = {}

vim.api.nvim_create_autocmd('WinClosed', {
  callback = function(args)
    local window_id = tonumber(args.match)

    if window_id ~= nil and windows[window_id] ~= nil then
      Loader.load_state()

      if windows[window_id].timer ~= nil then
        local timer = windows[window_id].timer

        timer:stop()
        timer:close()
      end

      windows[window_id] = nil
    end
  end
})

Event.listen('update', function()
  for _, window in pairs(windows) do
    window.update_cooldown = window.update_cooldown + 3
  end
end)

--- Get The Transformation Of The Window
--- @return { x: number, y: number, width: number, height: number } 
local function get_window_transformation()
  local total_width = vim.api.nvim_get_option('columns')
  local total_height = vim.api.nvim_get_option('lines')

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

--- @class Window
--- @field buffer any
--- @field window any
--- @field timer any
--- @field control Control
--- @field width number
--- @field height number
--- @field update_cooldown number

--- Get The Window
--- @param window_id number
--- @return Window
function Window. get_window(window_id)
  assert(windows[window_id] ~= nil, table.concat({'Themify: Interface not found "', window_id, '"'}))

  return windows[window_id]
end

--- Create A Windowr
function Window:new()
  self = setmetatable({}, Window)

  self.buffer = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_option_value('modifiable', false, { buf = self.buffer })

  local transformation = get_window_transformation()

  self.window = vim.api.nvim_open_win(self.buffer, true, {
    relative = 'editor',
    col = transformation.x,
    row = transformation.y,
    width = transformation.width,
    height = transformation.height,

    style = 'minimal',
    border = 'rounded'
  })

  self.control = Control:new(self)

  self.width = transformation.width
  self.height = transformation.height
  self.update_cooldown = -1

  windows[self.window] = self

  local lines = Content.get_content()

  self.control:check_cursor(lines)
  self:update(lines)

  return self
end

--- Start The Render Loop
function Window:start_render_loop()
  self.timer = vim.uv.new_timer()

  self.timer:start(10, 10, vim.schedule_wrap(function()
    if (self.update_cooldown > 0) then
      self.update_cooldown = self.update_cooldown - 1

      if self.update_cooldown == 0 or self.update_cooldown > 9 then
        self.update_cooldown = 0

        local ok, error = pcall(function()
          local lines = Content.get_content()

          self.control:check_cursor(lines)
          self:update(lines)
        end)

        if not ok then
          self.timer:stop()
          self.timer:close()

          self.timer = nil

          assert(false, error)
        end
      end
    end
  end))
end

--- Update The Window
--- @param lines { content: Text, tags: Tags[] }[]
--- @return nil
function Window:update(lines)
  vim.api.nvim_set_option_value('modifiable', true, { buf = self.buffer })

  -- Clear the buffer.
  vim.api.nvim_buf_set_lines(self.buffer, 0, -1, false, {})

  for i = 1, #lines do
    if i - self.control.scroll_y >= 0 and i - self.control.scroll_y < self.height - 6 then
      lines[i].content:render(self.buffer, 2 + (i - self.control.scroll_y))
    end
  end

  Text:new('- Themery -', Color.title):center(self.width):render(self.buffer, 1)
  Text:new('Install (I)  Update (U)', Color.description):center(self.width):render(self.buffer, self.height - 2)

  vim.api.nvim_set_option_value('modifiable', false, { buf = self.buffer }) 

  -- Move the cursor.
  vim.api.nvim_win_set_cursor(self.window, {4 + (self.control.cursor_y - self.control.scroll_y), 0})
end

return Window
