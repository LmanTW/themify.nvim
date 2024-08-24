local Group = require('themify.interface.components.group')
local Text = require('themify.interface.components.text')
local Color = require('themify.interface.color')
local Manager = require('themify.core.manager')

local M = {}

--- Get The Progress Icon
--- @param progress number
--- @return string
local function get_progress_icon(progress)
  if progress >= 100 then return  '󰪥 '
  elseif progress >= 87.5 then return '󰪤 '
  elseif progress >= 75 then return '󰪣 '
  elseif progress >= 62.5 then return '󰪢 '
  elseif progress >= 50 then return '󰪡 '
  elseif progress >= 37.5 then return '󰪠 '
  elseif progress >= 25 then return '󰪟 '
  elseif progress >= 12.5 then return '󰪞 '
  else return '󰄰 ' end
end

--- Get The Content
--- @return { content: Text, tags: Tags[], extra?: any }[]
function M.get_content()
  local group = Group:new()

  local amount = {
    unknown = 0,
    installing = 0,
    updating = 0,
    failed = 0,
    not_installed = 0,
    installed = 0
  }

  for _, colorscheme_data in pairs(Manager.colorschemes_data) do
    if colorscheme_data.status == 'unknown' then amount.unknown = amount.unknown + 1
    elseif colorscheme_data.status == 'installing' then amount.installing = amount.installing + 1
    elseif colorscheme_data.status == 'updating' then amount.updating = amount.updating + 1
    elseif colorscheme_data.status == 'failed' then amount.failed = amount.failed + 1
    elseif colorscheme_data.status == 'not_installed' then amount.not_installed = amount.not_installed + 1
    elseif colorscheme_data.status == 'installed' then amount.installed = amount.installed + 1
    end
  end

  if amount.unknown > 0 then
    group:create_list('unknown', Text.combine({
      Text:new('  Unknown '),
      Text:new(table.concat({'(', tostring(amount.unknown), ')'}), Color.description)
    }))
  end
  if amount.installing > 0 then
    group:create_list('installing', Text.combine({
      Text:new('  Installing '),
      Text:new(table.concat({'(', tostring(amount.installing), ')'}), Color.description)
    }))
  end
  if amount.updating > 0 then
    group:create_list('updating', Text.combine({
      Text:new('  Updating '),
      Text:new(table.concat({'(', tostring(amount.installing), ')'}), Color.description)
    }))
  end
  if amount.failed > 0 then
    group:create_list('failed', Text.combine({
      Text:new('  Failed '),
      Text:new(table.concat({'(', tostring(amount.installing), ')'}), Color.description)
    }))
  end
  if amount.not_installed > 0 then
    group:create_list('not_installed', Text.combine({
      Text:new('  Not Installed '),
      Text:new(table.concat({'(', tostring(amount.not_installed), ')'}), Color.description)
    }))
  end
  if amount.installed > 0 then
    group:create_list('installed', Text.combine({
      Text:new('  Installed '),
      Text:new(table.concat({'(', tostring(amount.installed), ')'}), Color.description)
    }))
  end

  for _, colorscheme_data in pairs(Manager.colorschemes_data) do
    if colorscheme_data.status == 'unknown' then
      group:add_element('not_installed', Text.combine({
        Text:new('    '),
        Text:new('󰘥 ', Color.icon),
        Text:new(colorscheme_data.repository)
      }), {})
    elseif colorscheme_data.status == 'installing' then
      group:add_element('installing', Text.combine({
        Text:new('    '),
        Text:new(get_progress_icon(colorscheme_data.progress), Color.icon),
        Text:new(colorscheme_data.repository),
        Text:new(' '),
        Text:new(table.concat({' ', colorscheme_data.info, ' '}), Color.info),
      }), {})
    elseif colorscheme_data.status == 'updating' then
      group:add_element('updating', Text.combine({
        Text:new('    '),
        Text:new(get_progress_icon(colorscheme_data.progress), Color.icon),
        Text:new(colorscheme_data.repository),
        Text:new(' '),
        Text:new(table.concat({' ', colorscheme_data.info, ' '}), Color.info),
      }), {})
    elseif colorscheme_data.status == 'failed' then
      group:add_element('failed', Text.combine({
        Text:new('    '),
        Text:new('󰗖 ', Color.icon),
        Text:new(colorscheme_data.repository), 
      }), {})
      group:add_element('failed', Text.combine({
        Text:new('      '),
        Text:new(table.concat({' ', colorscheme_data.info, ' '}), Color.error)
      }), {})
    elseif colorscheme_data.status == 'not_installed' then
      group:add_element('not_installed', Text.combine({
        Text:new('    '),
        Text:new('󱑥 ', Color.icon),
        Text:new(colorscheme_data.repository)
      }), {})
    elseif colorscheme_data.status == 'installed' then
      local parts = {
        Text:new('    '),
        Text:new('󰗡 ', Color.icon),
        Text:new(colorscheme_data.repository)
      }

      if string.len(colorscheme_data.info) > 0 then
        parts[#parts + 1] = Text:new(' ')
        parts[#parts + 1] = Text:new(table.concat({' ', colorscheme_data.info, ' '}), Color.info)
      end

      group:add_element('installed', Text.combine(parts), {'title'})

      for i = 1, #colorscheme_data.themes do
        group:add_element('installed', Text.combine({
          Text:new('      - '),
          Text:new(colorscheme_data.themes[i])
        }), {'selectable', 'theme'}, { colorscheme_path = colorscheme_data.path, theme = colorscheme_data.themes[i] })
      end
    end
  end

  return group:render()
end

return M
