local Cache = require('themify.interface.components.cache')
local List = require('themify.interface.components.list')
local Text = require('themify.interface.components.text')
local Colors = require('themify.interface.colors')
local Pages = require('themify.interface.pages')
local Manager = require('themify.core.manager')

--- Get Progress Icon
--- @param progress number
local function get_progress_icon(progress)
  if progress >= 100 then return '󰪥 '
  elseif progress >= 87.5 then return '󰪤 '
  elseif progress >= 75 then return '󰪣 '
  elseif progress >= 62.5 then return '󰪢 '
  elseif progress >= 50 then return '󰪡 '
  elseif progress >= 37.5 then return '󰪠 '
  elseif progress >= 25 then return '󰪟 '
  elseif progress >= 12.5 then return '󰪞 '
  else return '󰄰 ' end
end

Pages.create_page({
  id = 'manage',
  name = 'Manage',

  update = function()
    local list = List:new()

    local amount = Manager.colorschemes_amount

    if amount.not_installed ~= nil then
      list:create_section('not_installed', { content = Text.combine({
        Text:new('  Not Installed '),
        Text:new(table.concat({'(', amount.not_installed, ')'}), Colors.description)
      }), tags = {} })
    end
    if amount.failed ~= nil then
      list:create_section('failed', { content = Text.combine({
        Text:new('  Failed '),
        Text:new(table.concat({'(', amount.failed, ')'}), Colors.description)
      }), tags = {} })
    end
    if amount.installing ~= nil then
      list:create_section('installing', { content = Text.combine({
        Text:new('  Installing '),
        Text:new(table.concat({'(', amount.installing, ')'}), Colors.description)
      }), tags = {} })
    end
    if amount.updating ~= nil then
      list:create_section('updating', { content = Text.combine({
        Text:new('  Updating '),
        Text:new(table.concat({'(', amount.updating, ')'}), Colors.description)
      }), tags = {} })
    end
    if amount.installed ~= nil then
      list:create_section('installed', { content = Text.combine({
        Text:new('  Installed '),
        Text:new(table.concat({'(', amount.installed, ')'}), Colors.description)
      }), tags = {} })
    end

    local colorscheme_id
    local colorscheme_data

    for i = 1, #Manager.colorschemes_id do
      colorscheme_id = Manager.colorschemes_id[i]
      colorscheme_data = Manager.colorschemes_data[colorscheme_id]

      if colorscheme_data.type == 'remote' then
        if colorscheme_data.status == 'not_installed' then
          list:add_item(colorscheme_data.status, { content = Text.combine({
            Cache.text_padding_4,
            Text:new('󱑥 ', Colors.icon),
            Text:new(colorscheme_id)
          }), tags = {'selectable', 'install'}, extra = colorscheme_id })
        elseif colorscheme_data.status == 'failed' then
          list:add_item('failed', { content = Text.combine({
            Cache.text_padding_4,
            Text:new('󰗖 ', Colors.icon),
            Text:new(colorscheme_id)
          }), tags = {'selectable', 'check'}, extra = colorscheme_id })
          list:add_item('failed', { content = Text.combine({
            Cache.text_padding_4,
            Text:new(table.concat({' ', colorscheme_data.info, ' '}), Colors.error)
          }), tags = {} })
        elseif colorscheme_data.status == 'installing' or colorscheme_data.status == 'updating' then
          list:add_item(colorscheme_data.status, { content = Text.combine({
            Cache.text_padding_4,
            Text:new(get_progress_icon(colorscheme_data.progress), Colors.icon),
            Text:new(colorscheme_id),
            Cache.text_padding_1,
            Text:new(table.concat({' ', colorscheme_data.info, ' '}), Colors.info)
          }), tags = {} })
        elseif colorscheme_data.status == 'installed' then
          local parts = {
            Cache.text_padding_4,
            Text:new('󰸡 ', Colors.icon),
            Text:new(colorscheme_id),
          }

          if colorscheme_data.info:len() > 0 then
            vim.list_extend(parts, {
              Cache.text_padding_1,
              Text:new(table.concat({' ', colorscheme_data.info, ' '}), Colors.info)
            })
          end

          list:add_item('installed', { content = Text.combine(parts), tags = {'selectable', 'update'}, extra = Manager.colorschemes_id[i] })
        end
      end
    end

    return list:get_content()
  end,

  enter = function()
    return 1
  end,
  leave = function() end,

  hover = function() end,
  select = function(line)
    if vim.list_contains(line.tags, 'check') then Manager.check_colorscheme(line.extra)
    elseif vim.list_contains(line.tags, 'install') then Manager.install_colorscheme(line.extra)
    elseif vim.list_contains(line.tags, 'update') then Manager.update_colorscheme(line.extra) end

    return {}
  end
})
