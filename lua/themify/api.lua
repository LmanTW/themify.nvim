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
      Utilities.error(Manager.colorschemes_data[colorscheme_id] == nil, {'[Themify] Colorscheme not found: "', colorscheme_id, '"'})

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
