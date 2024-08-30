local Window = require('themify.interface.window')
local Pages = require('themify.interface.pages')

local M = {}

--- Open The Menu
--- @return nil
function M.open()
  Pages.load_pages()

  local window = Window:new()

  window:update()
end

return M
