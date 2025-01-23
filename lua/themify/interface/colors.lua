--- @type table<string, string>
local M = {
  icon = 'ThemifyIcon',

  title = 'ThemifyTitle',
  description = 'ThemifyDescription',

  info = 'ThemifyInfo',
  warn = 'ThemifyWarn',
  error = 'ThemifyError'
}

--- @type table<string, string>
local highlight_groups = {
  ThemifyIcon = 'Operator',

  ThemifyTitle = 'Bold',
  ThemifyDescription = 'Comment',

  ThemifyInfo = 'DiagnosticVirtualTextInfo',
  ThemifyWarn = 'DiagnosticVirtualTextWarn',
  ThemifyError = 'DiagnosticVirtualTextError'
}

for highlight_group, link in pairs(highlight_groups) do
  vim.api.nvim_set_hl(0, highlight_group, { link = link, default = true })
end

return M
