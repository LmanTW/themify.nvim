local M = {
  title = 'ThemifyTitle',
  description = 'ThemifyDescription',

  icon = 'ThemifyIcon',
  progress = 'ThemifyProgress'
}

local highlight_groups = {
  Title = 'Bold',
  Description = 'Comment',

  Icon = 'Operator',
  Progress = 'IncSearch'
}

for highlight_group, link in pairs(highlight_groups) do
  local highlight = type(link) == 'table' and link or { link = link }

  highlight.default = true

  vim.api.nvim_set_hl(0, 'Themify' .. highlight_group, highlight)
end

return M
