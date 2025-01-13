local Cache = require('themify.interface.components.cache')
local Text = require('themify.interface.components.text')
local Colors = require('themify.interface.colors')
local Activity = require('themify.core.activity')
local Pages = require('themify.interface.pages')
local Manager = require('themify.core.manager')
local Data = require('themify.core.data')

local state = Data.read_state_data()

Pages.create_page({
  id = 'activity',
  name = 'Activity',

  update = function()
    local content = {}

    if not Activity.enabled then
      content[#content + 1] = { content = Text.combine({Cache.text_padding_2, Text:new('󰗖  Activity is not enabled, so your colorscheme usage will not be recorded.', Colors.warn)}), tags = {'selectable'} }
      content[#content + 1] = Cache.line_blank
    end

    if vim.tbl_count(Activity.data.colorschemes) == 0 then
      content[#content + 1] = { content = Text.combine({Cache.text_padding_2, Text:new('No activity data available. Please come back later!', Colors.description)}), tags = {'selectable'} }
    else
      local colorscheme_id
      local colorscheme_activity
      local colorscheme_data
      local theme_usage
      local selected

      for i = 1, #Manager.colorschemes_id do
        colorscheme_id = Manager.colorschemes_id[i]
        colorscheme_activity = Activity.data.colorschemes[colorscheme_id]

        if colorscheme_activity ~= nil then
          if colorscheme_activity.type == 'remote' then
            colorscheme_data = Manager.colorschemes_data[colorscheme_id]

            content[#content + 1] = { content = Text:new(table.concat({'   ', Manager.colorschemes_id[i]})), tags = {} }

            for i2 = 1, #colorscheme_data.themes do
              theme_usage = colorscheme_activity.themes[colorscheme_data.themes[i2]]

              if theme_usage ~= nil then
                selected = state ~= vim.NIL and (colorscheme_id == state.colorscheme_id and colorscheme_data.themes[i2] == state.theme)

                content[#content + 1] = { content = Text.combine({
                  Text:new(table.concat({selected and '    > ' or '    - ', colorscheme_data.themes[i2], ': '})),
                  Text:new(table.concat({tostring(math.ceil(theme_usage.total_minutes)), 'min'}), Colors.info),
                }), tags = {'selectable', 'theme'}, extra = { colorscheme_id = colorscheme_id, theme = colorscheme_data.themes[i2] } }
                content[#content + 1] = { content = Text.combine({
                  Cache.text_padding_6,
                  Text:new(table.concat({'| Today: ', tostring(math.ceil(theme_usage.today_minutes)), 'min'}), Colors.description),
                }), tags = {} }
                content[#content + 1] = { content = Text.combine({
                  Cache.text_padding_6,
                  Text:new(table.concat({'| Last: ', os.date('%Y/%m/%d (%H:%M)', theme_usage.last_active)}), Colors.description)
                }), tags = {} }
              end
            end
          else
            theme_usage = colorscheme_activity.usage
            selected = state ~= vim.NIL and (state.colorscheme_id == nil and state.theme == colorscheme_id)

            content[#content + 1] = { content = Text.combine({
              Text:new(table.concat({selected and '  > ' or '  - ', colorscheme_id, ': '})),
              Text:new(table.concat({tostring(math.ceil(theme_usage.total_minutes)), 'min'}), Colors.info),
            }), tags = {'selectable', 'theme'}, extra = { theme = colorscheme_id } }
            content[#content + 1] = { content = Text.combine({
              Cache.text_padding_4,
              Text:new(table.concat({'| Today: ', tostring(math.ceil(theme_usage.today_minutes)), 'min'}), Colors.description),
            }), tags = {} }
            content[#content + 1] = { content = Text.combine({
              Cache.text_padding_4,
              Text:new(table.concat({'| Last: ', os.date('%Y/%m/%d (%H:%M)', theme_usage.last_active)}), Colors.description)
            }), tags = {} }
          end
        end
      end
    end

    return content
  end,

  enter = function(content)
    state = Data.read_state_data()

    if state ~= vim.NIL then
      for i = 1, #content do
        if vim.list_contains(content[i].tags, 'theme') then
          if content[i].extra.colorscheme_id == state.colorscheme_id and content[i].extra.theme == state.theme then
            return i
          end
        end
      end
    end

    return 1
  end,
  leave = function()
  end,

  hover = function()
  end,
  select = function()
    return {}
  end
})
