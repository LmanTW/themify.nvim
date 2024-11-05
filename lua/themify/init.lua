--- @alias Colorscheme string|{ [1]: string, branch?: string, before?: function, after?: function, whitelist?: string[], blacklist?: string[] }

local Manager = require('themify.core.manager')
local Utilities = require('themify.utilities')
local Event = require('themify.core.event')
local Command = require('themify.command')
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
  listen = Event.listen
}

--- Throw An Colorscheme Config Error
--- @param colorscheme_repository string
--- @param option_name string
--- @param type_name string
--- @return nil
local function throw_colorscheme_config_error(colorscheme_repository, option_name, type_name)
  error(table.concat({'Themify: The "', option_name, '" option for the colorscheme "', colorscheme_repository, '" must be a <', type_name, '>'}))
end

--- Check The Config Of A Colorscheme
--- @param colorscheme_repository string
--- @param colorscheme Colorscheme
--- @return nil
local function check_colorscheme_config(colorscheme_repository, colorscheme)
  if colorscheme.branch ~= nil and type(colorscheme.branch) ~= 'string' then throw_colorscheme_config_error(colorscheme_repository, 'branch', 'string') end
  if colorscheme.before ~= nil and type(colorscheme.before) ~= 'function' then throw_colorscheme_config_error(colorscheme_repository, 'before', 'function') end
  if colorscheme.after ~= nil and type(colorscheme.after) ~= 'function' then throw_colorscheme_config_error(colorscheme_repository, 'after', 'function') end
  if colorscheme.whitelist ~= nil and type(colorscheme.whitelist) ~= 'table' then throw_colorscheme_config_error(colorscheme_repository, 'whitelist', 'table') end
  if colorscheme.blacklist ~= nil and type(colorscheme.blacklist) ~= 'table' then throw_colorscheme_config_error(colorscheme_repository, 'blacklist', 'table') end
end

--- Load The State
--- @return nil
local function load_state()
  local state = Data.read_state_data()

  if state ~= vim.NIL then
    local ok = Manager.load_theme(state.colorscheme_id, state.theme)

    if not ok then
      Data.write_state_data(vim.NIL)

      vim.api.nvim_create_autocmd('UIEnter', {
        callback = function()
          vim.notify(table.concat({'Themify: Colorscheme not found: "', state.colorscheme_id, '"'}), vim.log.levels.WARN)
          vim.cmd('Themify')
        end,

        once = true
      })
    end
  end
end

--- Setup Themify
--- @param config Colorscheme[]|table<string, boolean>
--- @return nil
function M.setup(config)
  Utilities.error(type(config) ~= 'table', {'Themify: "config" must be a <table>'})

  local colorscheme

  for i = 1, #config do
    colorscheme = config[i]

    if type(colorscheme) == 'string' then
      Manager.add_colorscheme(colorscheme, {
        branch = 'main'
      })
    elseif type(colorscheme[1]) == 'string' then
      Manager.add_colorscheme(colorscheme[1], {
        branch = colorscheme.branch or 'main',
        before = colorscheme.before,
        after = colorscheme.after,
        whitelist = colorscheme.whitelist,
        blacklist = colorscheme.blacklist
      })
    end
  end

  -- Run the checking process in async to avoid blocking the thread.
  Utilities.execute_async(vim.schedule_wrap(function()
    for i = 1, #config do
      colorscheme = config[i]

      if type(colorscheme[1]) == 'string' then
        check_colorscheme_config(colorscheme[1], colorscheme)
      end
    end

    Manager.check_colorschemes()
  end))

  if config.async then
    Utilities.execute_async(vim.schedule_wrap(load_state))
  else
    load_state()
  end
end

vim.api.nvim_create_user_command("Themify", Command.handle, {
  nargs = '?',
  complete = Command.complete
})

return M
