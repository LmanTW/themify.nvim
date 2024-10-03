local Snippet = require('themify.interface.components.snippet')
local Text = require('themify.interface.components.text')
local Window = require('themify.interface.window')
local Colors = require('themify.interface.colors')
local Pages = require('themify.interface.pages')
local Manager = require('themify.core.manager')
local Utilities = require('themify.utilities')

--- @type 'all'|'dark'|'light'
local brightness = 'all'
--- @type 'all'|'cold'|'warm'
local temperature = 'all'
--- @type string
local language = 'lua'

--- @type { name: string, repository: string, brightness: 'dark'|'light', temperature: 'cold'|'warm', highlights: table<string, table<string, any>> }[]
local database
--- @type number[]
local result = {}

local line_blank = { content = Text:new(''), tags = {} }
local text_installed = Text.combine({Text:new(' '), Text:new('(Installed)', Colors.description)})

local preview_buffer = vim.api.nvim_create_buf(false, true)
local preview_window

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

--- Update The Preview Snippet
--- @return nil
local function update_preview()
  Snippet.render(preview_buffer, language)
end

update_preview()

Pages.create_page({
  id = 'explore',
  name = 'Explore',

  update = function()
    local content = {
      { content = Text:new(table.concat({'  Brightness: ', brightness})), tags = {'selectable', 'option'}, extra = 'brightness' },
      { content = Text:new(table.concat({'  Temperature: ', temperature})), tags = {'selectable', 'option'}, extra = 'temperature' },
      { content = Text:new(table.concat({'  Language: ', language})), tags = {'selectable', 'option'}, extra = 'language' },
      line_blank
    }

    local theme
    local parts

    for i = 1, #result do
      --- Result is just an array of index that points to the database.
      theme = database[result[i]]
      parts = {Text:new(table.concat({'  ', theme.name}))}

      if Manager.colorschemes_data[theme.repository] ~= nil and vim.list_contains(Manager.colorschemes_data[theme.repository].themes, theme.name) then
        parts[#parts + 1] = text_installed
      end

      content[#content + 1] = { content = Text.combine(parts), tags = {'selectable', 'theme'}, extra = result[i] }
    end

    return content
  end,

  enter = function()
    if database == nil then
      local data = Utilities.read_file(vim.fs.normalize(table.concat({debug.getinfo(1, 'S').source:sub(2), '../../../../../../database/themes.json'})))

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

        local width = math.min(60, math.floor(transformation.width / 2))

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

      local theme = database[line.extra]
      local highlights = {}

      for name, value in pairs(theme.highlights) do
        vim.api.nvim_set_hl(0, table.concat({'ThemifyPreview', name}), value)

        highlights[#highlights + 1] = table.concat({name, table.concat({'ThemifyPreview', name})}, ':')
      end

      vim.api.nvim_buf_set_option(preview_buffer, 'winhl', table.concat(highlights, ','))
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

        update_result()
      elseif line.extra == 'temperature' then
        if temperature == 'all' then temperature = 'cold'
        elseif temperature == 'cold' then temperature = 'warm'
        else temperature = 'all' end

        update_result()
      else
        local snippets = vim.tbl_keys(Snippet.snippets)
        local index = Utilities.index(snippets, language) + 1

        if index > #snippets then
          index = 1
        end

        language = snippets[index]

        update_preview()
      end
    elseif vim.list_contains(line.tags, 'theme') then
      local theme = database[line.extra]

      vim.cmd(table.concat({'exec \'!open https://github.com/', theme.repository, '\''}))
    end

    return {'update'}
  end
})
