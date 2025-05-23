--- @alias Colorscheme string|{ [1]: string, branch?: string, before?: function, after?: function, whitelist?: string[], blacklist?: string[] }

local Manager = require('themify.core.manager')
local Utilities = require('themify.utilities')
local Command = require('themify.command')
local Data = require('themify.core.data')

local M = {}

--- Throw an colorscheme config error.
--- @param colorscheme_repository string
--- @param option_name string
--- @param type_name string
--- @return nil
local function throw_colorscheme_config_error(colorscheme_repository, option_name, type_name)
  error(table.concat({'[Themify] The "', option_name, '" option for the colorscheme "', colorscheme_repository, '" must be a <', type_name, '>'}))
end

--- Check the config of a colorscheme.
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

--- Setup Themify.
--- @param config Colorscheme[]|table<string, any>
--- @return nil
function M.setup(config)
  Utilities.error(type(config) ~= 'table', {'[Themify] "config" must be a <table>'})

  Manager.colorschemes_data = {}
  Manager.colorschemes_id = {}

  local colorscheme

  for i = 1, #config do
    colorscheme = config[i]

    if type(colorscheme) == 'string' then
      Manager.add_colorscheme(colorscheme, {})
    elseif type(colorscheme[1]) == 'string' then
      Manager.add_colorscheme(colorscheme[1], {
        branch = colorscheme.branch,
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

  --- Replace the loader with the default state loader if not found.
  if type(config.loader) ~= 'function' then
    config.loader = function()
      local state = Data.read_state_data()

      if state ~= vim.NIL then
        local ok = Manager.load_theme(state.colorscheme_id, state.theme)

        if not ok then
          Data.write_state_data(vim.NIL)

          vim.api.nvim_create_autocmd('UIEnter', {
            callback = function()
              vim.notify(table.concat({'[Themify] Colorscheme not found: "', state.colorscheme_id == nil and state.theme or state.colorscheme_id, '"'}), vim.log.levels.WARN)
              vim.cmd('Themify')
            end,

            once = true
          })
        end
      end
    end
  end

  if config.async then
    Utilities.execute_async(vim.schedule_wrap(config.loader))
  else
    config.loader()
  end

  if config.activity then
    Utilities.execute_async(vim.schedule_wrap(function()
      local Activity = require('themify.core.activity')

      if not Activity.enabled then
        Activity.check_activity_data()
        Activity.enable()
      end
    end))
  end
end

vim.api.nvim_create_user_command("Themify", Command.handle, {
  nargs = '?',
  complete = Command.complete
})

return M
