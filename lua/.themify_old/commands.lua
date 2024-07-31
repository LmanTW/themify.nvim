local Colorschemes = require('themify.core.colorschemes')
local Control = require('themify.interface.control')
local Buffer = require('themify.interface.buffer')
local Window = require('themify.interface.window')

local M = {}

-- Open The Interface
function M.open()
  Control.reset()
  Window.open(Buffer.buffer)
  Buffer.render(Control.cursor_y, Control.scroll_y)

  Colorschemes.check()

  Buffer.render(Control.cursor_y, Control.scroll_y)
end

return M
