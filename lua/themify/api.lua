local Manager = require('themify.core.manager')
local Utilities = require('themify.utilities')
local Event = require('themify.core.event')
local Data = require('themify.core.data')

local M = {
  --- Get the current colorscheme.
  --- @return State_Data
  get_current = function()
    return Data.read_state_data()
  end,

  --- Set the current colorscheme.
  --- @param colorscheme_id nil|string
  --- @param theme string
  --- @return nil
  set_current = function(colorscheme_id, theme)
    Data.write_state_data({ colorscheme_id = colorscheme_id, theme = theme })

    Manager.load_theme(colorscheme_id, theme)
  end,

  Manager = {
    --- A list of id of the colorschemes in order.
    --- @type string[]
    colorschemes = Manager.colorschemes_id,

    --- Get a colorscheme.
    --- @param colorscheme_id string
    --- @return Colorscheme_Data
    get = function(colorscheme_id)
      Manager.check_colorscheme(colorscheme_id)

      return Manager.colorschemes_data[colorscheme_id]
    end,

    --- Add a colorscheme to manage.
    --- @param colorscheme_source string
    --- @param colorscheme_info Colorscheme_Info
    --- @return nil
    add = function(colorscheme_source, colorscheme_info)
      Manager.add_colorscheme(colorscheme_source, colorscheme_info)
    end,

    --- Clean unused colorschemes.
    --- @return nil
    clean = function()
      Manager.clean_colorschemes()
    end,

    --- Install the colorschemes.
    --- @return nil
    install = function()
      Manager.install_colorschemes()
    end,

    --- Update the colorschemes.
    --- @return nil
    update = function()
      Manager.update_colorschemes()
    end
  },

  Activity = {
    --- Get the activity of a skin.
    --- @param colorscheme nil|string
    --- @param theme string
    --- @return nil|Usage_Data
    get = function(colorscheme, theme)
      local activity = Data.read_activity_data()
      local colorscheme_data

      if activity ~= vim.NIL then
        if colorscheme == nil then
          if activity.colorschemes[theme] ~= nil and activity.colorschemes[theme].type == 'local' then
            return activity.colorschemes[theme].usage
          end
        else
          if activity.colorschemes[colorscheme] ~= nil and activity.colorschemes[colorscheme].type == 'remote' then
            colorscheme_data = activity.colorschemes[colorscheme]

            if colorscheme_data.themes[theme] ~= nil then
              return colorscheme_data.themes[theme]
            end
          end
        end
      end

      return nil
    end
  },

  Event = {
    --- Listen to an event.
    --- @param event string
    --- @param callback function
    --- @return nil
    listen = function(event, callback)
      Event.listen(event, callback)
    end
  }
}

return M
