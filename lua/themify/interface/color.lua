--- @type table<string, string>
local M = {
  title = 'ThemifyTitle',
  description = 'ThemifyDescription',

  icon = 'ThemifyIcon',

  info = 'ThemifyInfo',
  error = 'ThemifyError'
}

--- @type table<string, string>
local highlight_groups = {
  Title = 'Bold',
  Description = 'Comment',

  Icon = 'Operator',

  info = 'DiagnosticVirtualTextInfo',
  error = 'DiagnosticVirtualTextError'
}

for highlight_group, link in pairs(highlight_groups) do
  vim.api.nvim_set_hl(0, 'Themify' .. highlight_group, { link = link, default = true })
end

return M
