local Text = require('themify.interface.components.text')
local Colors = require('themify.interface.colors')
local Pages = require('themify.interface.pages')
local Manager = require('themify.core.manager')
local Data = require('themify.core.data')

local state = Data.read_state_data()
local current = state == vim.NIL and {} or { colorscheme_repository = state.colorscheme_repository, theme = state.theme }

Pages.create_page({
  id = 'home',
  name = 'Themify',

  update = function()
    local content = {}

    if Manager.colorschemes_amount.installed == nil then
      content[#content + 1] = { content = Text:new('  Welcome to Themify!', Colors.description), tags = {'selectable'} }
      content[#content + 1] = { content = Text:new(''), tags = {} }
      content[#content + 1] = { content = Text:new('  Use <Up> <Down> to move the cursor, <CR> to select.', Colors.description), tags = {'selectable'} }
      content[#content + 1] = { content = Text:new('  Use <Left> <Right> to switch between pages.', Colors.description), tags = {'selectable'} }
      content[#content + 1] = { content = Text:new(''), tags = {} }
      content[#content + 1] = { content = Text:new('  Finally, use [I] to install the colorschemes!', Colors.description), tags = {'selectable'} }
    end

    for i = 1, #Manager.colorschemes_repository do
      local colorscheme_data = Manager.colorschemes_data[Manager.colorschemes_repository[i]]

      if colorscheme_data.status == 'installed' then
        content[#content + 1] = { content = Text:new(table.concat({'   ', Manager.colorschemes_repository[i]})), tags = {} }

        for i2 = 1, #colorscheme_data.themes do
          local selected = state ~= vim.NIL and (Manager.colorschemes_repository[i] == state.colorscheme_repository and colorscheme_data.themes[i2] == state.theme)

          content[#content + 1] = { content = Text:new(table.concat({selected and '    > ' or '    - ', colorscheme_data.themes[i2]})), tags = {'selectable', 'theme'}, extra = { colorscheme_repository = Manager.colorschemes_repository[i], theme = colorscheme_data.themes[i2] }}
        end
      end
    end

    return content
  end,

  enter = function(content)
    local state = Data.read_state_data()

    if state ~= vim.NIL then
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
    if state ~= vim.NIL then
      if state.colorscheme_repository ~= current.colorscheme_repository or state.theme ~= current.theme then
        Manager.load_theme(state.colorscheme_repository, state.theme)
      end
    end
  end,

  hover = function(line)
    if vim.list_contains(line.tags, 'theme') then
      if line.extra.colorscheme_repository ~= current.colorscheme_repository or line.extra.theme ~= current.theme then
        Manager.load_theme(line.extra.colorscheme_repository, line.extra.theme)

        current = line.extra
      end
    end
  end,
  select = function(line)
    Data.write_state_data(line.extra)

    state = line.extra

    return {'close'}
  end
})
