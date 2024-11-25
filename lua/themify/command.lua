local M = {}

--- Handle the themify command.
--- @return nil
function M.handle(args)
  local Window = require('themify.interface.window')
  local Pages = require('themify.interface.pages')
  local Manager = require('themify.core.manager')

  Manager.check_colorschemes()
  Pages.load_pages()

  local window = Window:new()

  if (args.fargs[1] == 'install') then
    window:install_colorschemes()
  elseif (args.fargs[1] == 'update') then
    window:update_colorschemes()
  else
    -- Both <install_colorschemes> and <update_colorschemes> update the window automatically.
    window:update()
  end
end

--- Complete the command argument.
--- @param lead string
--- @return string[]
function M.complete(lead)
  local options = {'install', 'update'}
  local matches = {}

  for i = 1, #options do
    if options[i]:sub(1, #lead) == lead then
      matches[#matches + 1] = options[i]
    end
  end

  return matches
end

return M
