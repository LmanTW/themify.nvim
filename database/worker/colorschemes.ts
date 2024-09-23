export default [
  {
    name: 'kanagawa-paper.nvim',
    author: 'sho-87',

    themes: [{ name: 'kanagawa-paper', brightness: 'dark', temperature: 'cold' }]
  }
] as { name: string, author: string, themes: { name: string, brightness: 'dark' | 'light', temperature: 'cold' | 'warm' }[] }[]
