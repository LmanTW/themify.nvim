local Text = require('themify.interface.components.text')
local Color = require('themify.interface.color')
local Manager = require('themify.core.manager')

local M = {
  title = 'Themify'
}

-- Get The Content
function M.get_content()
  local lines = {}

  local count = { not_installed = 0, installing = 0 }

  for _, info in pairs(Manager.colorschemes_info) do
    if info.state == 'not_installed' then
      count.not_installed = count.not_installed + 1
    elseif info.state == 'installing' or info.state == 'install_failed' then
      count.installing = count.installing + 1
    end
  end

  if count.installing > 0 then
    lines[#lines + 1] = {
      selectable = false,
      text = Text.combine({
        Text:new('  Installing '),
        Text:new(table.concat({'(', tostring(count.installing), ')'}), Color.description)
      })
    }

    for name, info in pairs(Manager.colorschemes_info) do
      if info.state == 'installing' or info.state == 'install_failed' then
        local icon

        if info.state == 'install_failed' then icon = '󰗖 '
        elseif info.progress >= 100 then icon = '󰪥 '
        elseif info.progress >= 87.5 then icon = '󰪤 '
        elseif info.progress >= 75 then icon = '󰪣 '
        elseif info.progress >= 62.5 then icon = '󰪢 '
        elseif info.progress >= 50 then icon = '󰪡 '
        elseif info.progress >= 37.5 then icon = '󰪠 '
        elseif info.progress >= 25 then icon = '󰪟 '
        elseif info.progress >= 12.5 then icon = '󰪞 '
        else icon = '󰄰 ' end
--
        lines[#lines + 1] = {
          selectable = false,
          text = Text.combine({
            Text:new('    '),
            Text:new(icon, Color.icon),
            Text:new(name),
            Text:new(' '),
            Text:new(table.concat({'(', info.progress_info, ')'}), Color.description),
          })
        }
      end
    end

    lines[#lines + 1] = {
      selectable = false,
      text = Text:new(''),
    }
  end

  if count.not_installed > 0 then
    lines[#lines + 1] = {
      selectable = false,
      text = Text.combine({
        Text:new('  Not Installed '),
        Text:new(table.concat({'(', tostring(count.not_installed), ')'}), Color.description)
      })
    }

    for name, info in pairs(Manager.colorschemes_info) do
      if info.state == 'not_installed' then
        lines[#lines + 1] = {
          selectable = false,
          text = Text.combine({
            Text:new('    '),
            Text:new('󱑥 ', Color.icon),
            Text:new(name)
          })
        }
      end
    end

    lines[#lines + 1] = {
      selectable = false,
      text = Text:new(''),
    }
  end

  for name, info in pairs(Manager.colorschemes_info) do
    if info.state == 'installed' then
      lines[#lines + 1] = {
        selectable = false,
        text = Text.combine({
          Text:new('  '),
          Text:new(' ', Color.icon),
          Text:new(name)
        })
      }

      for i = 1, #info.themes do
        lines[#lines + 1] = {
          selectable = true,
          value = info.themes[i],
          text = Text.combine({
            Text:new('    '),
            Text:new('- ', Color.icon),
            Text:new(info.themes[i])
          })
        }
      end
    end
  end

  return lines
end

return M

--    local icon
--
--    if colorscheme_info.state == nil then icon = '󰘥 '
--    elseif colorscheme_info.state == 'installed' then icon = '󰗡 '
--    elseif colorscheme_info.state == 'installing' then icon = '󰄰 '
--    elseif colorscheme_info.state == 'idle' then icon = '󱑥 ' end
--
--    if (colorscheme_info.progress ~= nil) then
--      if colorscheme_info.progress >= 100 then icon = '󰪥 '
--      elseif colorscheme_info.progress >= 87.5 then icon = '󰪤 '
--      elseif colorscheme_info.progress >= 75 then icon = '󰪣 '
--      elseif colorscheme_info.progress >= 62.5 then icon = '󰪢 '
--      elseif colorscheme_info.progress >= 50 then icon = '󰪡 '
--      elseif colorscheme_info.progress >= 37.5 then icon = '󰪠 '
--      elseif colorscheme_info.progress >= 25 then icon = '󰪟 '
--      elseif colorscheme_info.progress >= 12.5 then icon = '󰪞 '
--      else icon = '󰄰 ' end
--    end
