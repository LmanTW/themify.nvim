local Window = require('themify.interface.window')
local Manager = require('themify.core.manager')
local Loader = require('themify.core.loader')

local M = {}

--- @alias Colorscheme string|{ [1]: string, branch?: string, config?: function, whitelist?: string[] }

--- Setup Themify
--- @param colorschemes Colorscheme[]
--- @return nil
function M.setup(colorschemes)
  assert(type(colorschemes) == 'table', 'Themify: "colorschemes" must be a <table>')

  local colorscheme

  for i = 1, #colorschemes do
    colorscheme = colorschemes[i]

    if type(colorscheme) == 'string' then
      Manager.add_colorscheme({
        repository = colorscheme,
        branch = 'main',
      })
    elseif type(colorscheme[1]) == 'string' then
      Manager.add_colorscheme({
        repository = colorscheme[1],
        branch = colorscheme.branch or 'main',

        config = colorscheme.config,
        whitelist = colorscheme.whitelist
      })
    end
  end

  local async

  async = vim.uv.new_async(vim.schedule_wrap(function()
    Manager.check_colorschemes()
    Loader.load_state()

    async:close()
  end))

  if async ~= nil then
    async:send()
  end
end

--- Open The Themify Menu
function M.open()
  local window = Window:new()

  window:start_render_loop()
end

vim.cmd('command! Themify lua require("themify").open()')

return M
