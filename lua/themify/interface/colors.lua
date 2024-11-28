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
  Icon = 'Operator',
  Title = 'Bold',
  Description = 'Comment',

  Info = 'DiagnosticVirtualTextInfo',
  Warn = 'DiagnosticVirtualTextWarn',
  Error = 'DiagnosticVirtualTextError'
}

for highlight_group, link in pairs(highlight_groups) do
  vim.api.nvim_set_hl(0, 'Themify' .. highlight_group, { link = link, default = true })
end

return M
