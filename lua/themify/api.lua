local Manager = require('themify.core.manager')
local Event = require('themify.core.event')
local Data = require('themify.core.data')

local M = {
  colorschemes_data = Manager.colorschemes_data,
  colorschemes_id = Manager.colorschemes_id,
  add_colorscheme = Manager.add_colorscheme,
  load_theme = Manager.load_theme,
  clean_colorschemes = Manager.clean_colorschemes,
  check_colorschemes = Manager.check_colorschemes,
  check_colorscheme = Manager.check_colorscheme,
  install_colorschemes = Manager.install_colorschemes,
  install_colorscheme = Manager.install_colorscheme,
  update_colorschemes = Manager.update_colorschemes,
  update_colorscheme = Manager.update_colorscheme,
  listen = Event.listen,
  read_state_data = Data.read_state_data,
  write_state_data = Data.write_state_data
}

return M
