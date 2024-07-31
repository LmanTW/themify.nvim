local Manager = require('themify.core.manager')
local Loader = require('themify.core.loader')
local Data = require('themify.core.data')

local M = {}

-- Setup
function M.setup(colorschemes)
  if type(colorschemes) ~= 'table' then
    print('Themify: "colorschemes" must be a <table>')

    return
  end

  Manager.add_colorschemes(colorschemes)

  -- Don't block the main thread when loading the colorscheme, this should be alright (I guess).

  local thread

  thread = coroutine.create(vim.schedule_wrap(function()
    local state = Data.get_state()

    if state ~= nil then
      local success = Loader.load_colorscheme(state.colorscheme, state.theme)

      if not success then
        -- Fallback to other colorschemes.

        print(true)
      end
    end
  end))

  coroutine.resume(thread)

  vim.cmd('command! Themify lua require("themify.commands").open()')
end

return M
