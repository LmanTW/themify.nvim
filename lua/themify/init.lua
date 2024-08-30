--- @alias Colorscheme string|{ [1]: string, branch?: string, config?: function, whitelist?: string[], blacklist?: string[] }

local Manager = require('themify.core.manager')
local Utilities = require('themify.utilities')
local Data = require('themify.core.data')

local M = {}

--- Throw An Colorscheme Config Error
--- @param colorscheme_repository string
--- @param option_name string
--- @param type_name string
local function throw_colorscheme_config_error(colorscheme_repository, option_name, type_name)
  error(table.concat({'Themify: The "', option_name, '" option for the colorscheme "', colorscheme_repository, '" must be a <', type_name, '>'}))
end

--- Check The Config Of A Colorscheme
--- @param colorscheme_repository string
--- @param colorscheme Colorscheme
local function check_colorscheme_config(colorscheme_repository, colorscheme)
  if colorscheme.branch ~= nil and type(colorscheme.branch) ~= 'string' then throw_colorscheme_config_error(colorscheme_repository, 'branch', 'string') end
  if colorscheme.config ~= nil and type(colorscheme.config) ~= 'function' then throw_colorscheme_config_error(colorscheme_repository, 'config', 'function') end
  if colorscheme.whitelist ~= nil and type(colorscheme.whitelist) ~= 'table' then throw_colorscheme_config_error(colorscheme_repository, 'whitelist', 'table') end
  if colorscheme.blacklist ~= nil and type(colorscheme.blacklist) ~= 'table' then throw_colorscheme_config_error(colorscheme_repository, 'blacklist', 'table') end
end

--- Setup Themify
--- @param colorschemes Colorscheme[]
--- @return nil
function M.setup(colorschemes)
  Utilities.error(type(colorschemes) ~= 'table', {'Themify: "colorschemes" must be a <table>'})

  local colorscheme

  for i = 1, #colorschemes do
    colorscheme = colorschemes[i]

    if type(colorscheme) == 'string' then
      Manager.add_colorscheme(colorscheme, {
        branch = 'main'
      })
    elseif type(colorscheme[1]) == 'string' then
      check_colorscheme_config(colorscheme[1], colorscheme)

      Manager.add_colorscheme(colorscheme[1], {
        branch = colorscheme.branch or 'main',
        config = colorscheme.config,
        whitelist = colorscheme.whitelist,
        blacklist = colorscheme.blacklist
      })
    end
  end

  -- Run the checking process in async to avoid blocking the thread.
  Utilities.execute_async(vim.schedule_wrap(function()
    Manager.check_colorschemes()

    local state = Data.read_state_data()

    if state ~= nil and state ~= vim.NIL then
      local ok = Manager.load_theme(state.colorscheme_repository, state.theme)

      if not ok then
        Data.write_state_data(nil)

        M.open()

        vim.cmd('Themify')
      end
    end
  end))
end

vim.cmd('command! Themify lua require("themify.commands").open()')

return M
