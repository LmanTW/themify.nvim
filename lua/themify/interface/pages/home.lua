local Text = require('themify.interface.components.text')
local Pages = require('themify.interface.pages')
local Manager = require('themify.core.manager')
local Data = require('themify.core.data')

local state = Data.read_state_data()

Pages.create_page({
  id = 'home',
  name = 'Themify',

  update = function()
    local content = {}

    for i = 1, #Manager.colorschemes_repository do
      local colorscheme_data = Manager.colorschemes_data[Manager.colorschemes_repository[i]]

      if colorscheme_data.status == 'installed' then
        content[#content + 1] = { content = Text:new(table.concat({'   ', Manager.colorschemes_repository[i]})), tags = {} }

        for i2 = 1, #colorscheme_data.themes do
          local selected = (state ~= nil and state ~= vim.NIL) and (Manager.colorschemes_repository[i] == state.colorscheme_repository and colorscheme_data.themes[i2] == state.theme)

          content[#content + 1] = { content = Text:new(table.concat({selected and '    > ' or '    - ', colorscheme_data.themes[i2]})), tags = {'selectable', 'theme'}, extra = { colorscheme_repository = Manager.colorschemes_repository[i], theme = colorscheme_data.themes[i2] }}
        end
      end
    end

    return content
  end,

  enter = function(content)
    local state = Data.read_state_data()

    if state ~= nil and state ~= vim.NIL then
      for i = 1, #content do
        if vim.list_contains(content[i].tags, 'theme') then
          if content[i].extra.colorscheme_repository == state.colorscheme_repository and content[i].extra.theme == state.theme then
            return i
          end
        end
      end
    end

    return 1
  end,
  leave = function()
    local state = Data.read_state_data()

    if state ~= nil and state ~= vim.NIL then
      Manager.load_theme(state.colorscheme_repository, state.theme)
    end
  end,

  hover = function(line)
    if vim.list_contains(line.tags, 'theme') then
      Manager.load_theme(line.extra.colorscheme_repository, line.extra.theme)
    end
  end,
  select = function(line)
    Data.write_state_data(line.extra)

    state = line.extra

    return { close = true }
  end
})
