local Window = require('themify.interface.window')
local Pages = require('themify.interface.pages')
local Manager = require('themify.core.manager')

local M = {}

--- Open The Menu
--- @return nil
function M.open()
  Manager.check_colorschemes()
  Pages.load_pages()

  local window = Window:new()

  window:update()
end

return M
