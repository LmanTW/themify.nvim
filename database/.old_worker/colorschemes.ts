export default [
  {
    repository: 'catppuccin/nvim',
    themes: [{ name: 'catppuccin-latte', brightness: 'light', temperature: 'cold' }, { name: 'catppuccin-frappe', brightness: 'dark', temperature: 'cold' }, { name: 'catppuccin-macchiato', brightness: 'dark', temperature: 'cold' }, { name: 'catppuccin-mocha', brightness: 'dark', temperature: 'cold' }]
  },
  {
    repository: 'folke/tokyonight.nvim',
    themes: [{ name: 'tokyonight-night', brightness: 'dark', temperature: 'cold' }, { name: 'tokyonight-moon', brightness: 'dark', temperature: 'cold' }, { name: 'tokyonight-storm', brightness: 'dark', temperature: 'cold' }, { name: 'tokyonight-day', brightness: 'light', temperature: 'cold' }]
  },
  {
    repository: 'sho-87/kanagawa-paper.nvim',
    themes: [{ name: 'kanagawa-paper', brightness: 'dark', temperature: 'cold' }]
  },
  {
    repository: 'rose-pine/neovim',
    themes: [{ name: 'rose-pine-main', brightness: 'dark', temperature: 'cold' }, { name: 'rose-pine-moon', brightness: 'dark', temperature: 'cold' }, { name: 'rose-pine-dawn', brightness: 'light', temperature: 'cold' }]
  },
  {
    repository: 'EdenEast/nightfox.nvim',
    themes: [{ name: 'nightfox', brightness: 'dark', temperature: 'cold' }, { name: 'dayfox', brightness: 'light', temperature: 'warm' }, { name: 'dawnfox', brightness: 'light', temperature: 'cold' }, { name: 'duskfox', brightness: 'dark', temperature: 'cold' }, { name: 'nordfox', brightness: 'dark', temperature: 'cold' }, { name: 'terafox', brightness: 'dark', temperature: 'cold' }, { name: 'carbonfox', brightness: 'dark', temperature: 'cold' }]
  },
  {
    repository: 'projekt0n/github-nvim-theme',
    themes: [{ name: 'github_dark', brightness: 'dark', temperature: 'cold' }, { name: 'github_light', brightness: 'light', temperature: 'cold' }, { name: 'github_dark_dimmed', brightness: 'dark', temperature: 'cold' }, { name: 'github_dark_default', brightness: 'dark', temperature: 'cold' }, { name: 'github_light_default', brightness: 'light', temperature: 'cold' }, { name: 'github_dark_high_contrast', brightness: 'dark', temperature: 'cold' }, { name: 'github_light_high_contrast', brightness: 'light', temperature: 'cold' }, { name: 'github_dark_colorblind', brightness: 'dark', temperature: 'cold' }, { name: 'github_light_colorblind', brightness: 'light', temperature: 'cold' }, { name: 'github_dark_tritanopia', brightness: 'dark', temperature: 'cold' }, { name: 'github_light_tritanopia', brightness: 'light', temperature: 'cold' }]
  }
] as { repository: string, themes: { name: string, brightness: 'dark' | 'light', temperature: 'cold' | 'warm' }[] }[]
