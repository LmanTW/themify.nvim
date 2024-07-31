
local Utilities = require('themify.utilities')
local Data = require('themify.core.data')
local Config = require('themify.config')

local Control = require('themify.interface.control')
local Buffer = require('themify.interface.buffer')
local Window = require('themify.interface.window')

local M = {}

function M.setup(config)
  M.config = Utilities.combine(Config.default_config, config == nil and {} or config)

  Config.check(M.config)

  Data.check()
  Data.load(M.config)

  vim.api.nvim_create_user_command('Themify', function()
    Window.open(Buffer.get_buffer())

    Buffer.render(Control.get_control())

    Control.reset()
  end, {})
end

M.scroll = Control.scroll

return M
