export default [
  {
    repository: 'folke/tokyonight.nvim',
    themes: [{ name: 'tokyonight-night', brightness: 'dark', temperature: 'cold' }, { name: 'tokyonight-moon', brightness: 'dark', temperature: 'cold' }, { name: 'tokyonight-storm', brightness: 'dark', temperature: 'cold' }, { name: 'tokyonight-day', brightness: 'light', temperature: 'cold' }]
  },
  {
    repository: 'sho-87/kanagawa-paper.nvim',
    themes: [{ name: 'kanagawa-paper', brightness: 'dark', temperature: 'cold' }]
  }
] as { repository: string, themes: { name: string, brightness: 'dark' | 'light', temperature: 'cold' | 'warm' }[] }[]
