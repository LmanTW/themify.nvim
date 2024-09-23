local Text = require('themify.interface.components.text')
local Window = require('themify.interface.window')
local Pages = require('themify.interface.pages')
local Utilities = require('themify.utilities')

--- @type 'all'|'dark'|'light'
local brightness = 'all'
--- @type 'all'|'cold'|'warm'
local temperature = 'all'

--- @type { name: string, repository: string, brightness: 'dark'|'light', temperature: 'cold'|'warm', preview: table<string, table<string, number>> }[]
local database
--- @type number[]
local result = {}

local blank = { content = Text:new(''), tags = {} }

local preview_buffer = vim.api.nvim_create_buf(false, true)
local preview_window

vim.api.nvim_set_option_value('modifiable', false, { buf = preview_buffer })

--- Update The Search Result 
--- @return nil
local function update_result()
  result = {}

  local theme

  for i = 1, #database do
    theme = database[i]

    if (brightness == 'all' or theme.brightness == brightness)
      and (temperature == 'all' or theme.temperature == temperature)
    then
      result[#result + 1] = i
    end
  end
end

Pages.create_page({
  id = 'explore',
  name = 'Explore',

  update = function()
    local content = {
      { content = Text:new(table.concat({'  Brightness: ', brightness})), tags = {'selectable', 'option'}, extra = 'brightness' },
      { content = Text:new(table.concat({'  Temperature: ', temperature})), tags = {'selectable', 'option'}, extra = 'temperature' },
      blank
    }

    local theme

    for i = 1, #result do
      --- Result is just an array of index that points to the database.
      theme = database[result[i]]

      content[#content + 1] = { content = Text:new(table.concat({'  ', theme.name})), tags = {'selectable', 'theme'}, extra = result[i] }
    end

    return content
  end,

  enter = function()
    if database == nil then
      local data = Utilities.read_file(vim.fs.normalize(table.concat({debug.getinfo(1, 'S').source:sub(2), '../../../../../../database/colorschemes.json'})))

      database = vim.json.decode(data)
      Utilities.error(database == nil, {'Themify: Failed to encode the colorscheme database'})

      update_result()
    end

    return 1
  end,
  leave = function()
    if preview_window ~= nil then
      vim.api.nvim_win_close(preview_window, false)

      preview_window = nil
    end
  end,

  hover = function(line)
    if vim.list_contains(line.tags, 'theme') then
      if preview_window == nil then
        local transformation = Window.get_window_transformation()

        local width = 30

        preview_window = vim.api.nvim_open_win(preview_buffer, false, {
          relative = 'editor',
          col = ((transformation.x + transformation.width) - width) - 3,
          row = transformation.y + 4,
          width = width,
          height = transformation.height - 8,

          style = 'minimal',
          border = 'rounded',

          focusable = false,
          zindex = 999
        })
      end
    else
      if preview_window ~= nil then
        vim.api.nvim_win_close(preview_window, false)

        preview_window = nil
      end
    end
  end,
  select = function(line)
    if vim.list_contains(line.tags, 'option') then
      if line.extra == 'brightness' then
        if brightness == 'all' then brightness = 'dark'
        elseif brightness == 'dark' then brightness = 'light'
        else brightness = 'all' end
      else
        if temperature == 'all' then temperature = 'cold'
        elseif temperature == 'cold' then temperature = 'warm'
        else temperature = 'all' end
      end

      update_result()
    end

    return {'update'}
  end
})
