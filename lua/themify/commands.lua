local Interface = require('themify.interface.main')
local Manager = require('themify.core.manager')

local M = {}

vim.api.nvim_create_autocmd("WinClosed", {
  callback = function(args)
    Interface.get_interface(tonumber(args.match)):close()
  end
})

-- Open The Interface
function M.open()
  local timer = vim.loop.new_timer()

  local interface = Interface:new(function()
    timer:stop()
    timer:close()
  end)

  Manager.check_colorschemes()

  interface:render()

  local rendered = false

  timer:start(100, 100, vim.schedule_wrap(function()
    if Manager.tasks > 0 then
      rendered = false
    end

    if not rendered then
      interface:render()

      rendered = true
    end

    if Manager.tasks > 0 then
      rendered = false
    end
  end))
end

return M
