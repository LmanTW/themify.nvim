local Text = require('themify.interface.components.text')
local Colors = require('themify.interface.colors')
local Pages = require('themify.interface.pages')
local Manager = require('themify.core.manager')
local Data = require('themify.core.data')

local state = Data.read_state_data()
local current = state == vim.NIL and {} or { colorscheme_id = state.colorscheme_id, theme = state.theme }

Pages.create_page({
  id = 'home',
  name = 'Themify',

  update = function()
    local content = {}

    if Manager.colorschemes_amount.installed == nil and Manager.colorschemes_amount.updating == nil then
      content[#content + 1] = { content = Text:new('  Welcome to Themify!', Colors.description), tags = {'selectable'} }
      content[#content + 1] = { content = Text:new(''), tags = {} }
      content[#content + 1] = { content = Text:new('  Use <Up> <Down> to move the cursor, <CR> to select.', Colors.description), tags = {'selectable'} }
      content[#content + 1] = { content = Text:new('  Use <Left> <Right> to switch between pages.', Colors.description), tags = {'selectable'} }
      content[#content + 1] = { content = Text:new(''), tags = {} }
      content[#content + 1] = { content = Text:new('  Finally, use [I] to install the colorschemes!', Colors.description), tags = {'selectable'} }
    end

    for i = 1, #Manager.colorschemes_id do
      local colorscheme_data = Manager.colorschemes_data[Manager.colorschemes_id[i]]

      if colorscheme_data.type == 'github' then

        if colorscheme_data.status == 'installed' or colorscheme_data.status == 'updating' then
          content[#content + 1] = { content = Text:new(table.concat({'   ', Manager.colorschemes_id[i]})), tags = {} }

          for i2 = 1, #colorscheme_data.themes do
            local selected = state ~= vim.NIL and (Manager.colorschemes_id[i] == state.colorscheme_id and colorscheme_data.themes[i2] == state.theme)

            content[#content + 1] = { content = Text:new(table.concat({selected and '    > ' or '    - ', colorscheme_data.themes[i2]})), tags = {'selectable', 'theme'}, extra = { colorscheme_id = Manager.colorschemes_id[i], theme = colorscheme_data.themes[i2] }}
          end
        end
      else
        local selected = state ~= vim.NIL and (state.colorscheme_id == nil and state.theme == colorscheme_data.name)

        content[#content + 1] = { content = Text:new(table.concat({selected and '  > ' or '  - ', colorscheme_data.name})), tags = {'selectable', 'theme'}, extra = { theme = colorscheme_data.name }}
      end
    end

    return content
  end,

  enter = function(content)
    if state ~= vim.NIL then
      for i = 1, #content do
        if vim.list_contains(content[i].tags, 'theme') then
          if content[i].extra.colorscheme_id == state.colorscheme_id and content[i].extra.theme == state.theme then
            return i
          end
        end
      end
    end

    return 2
  end,
  leave = function()
    if state ~= vim.NIL then
      if state.colorscheme_id ~= current.colorscheme_id or state.theme ~= current.theme then
        Manager.load_theme(state.colorscheme_id, state.theme)

        current = state
      end
    else
      vim.cmd.colorscheme('default')

      current = { colorscheme_id = nil, theme = 'default' }
    end
  end,

  hover = function(line)
    if vim.list_contains(line.tags, 'theme') then
      if line.extra.colorscheme_id ~= current.colorscheme_id or line.extra.theme ~= current.theme then
        Manager.load_theme(line.extra.colorscheme_id, line.extra.theme)

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
