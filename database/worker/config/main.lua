package.path = vim.fs.normalize(vim.fs.joinpath(debug.getinfo(1, 'S').source:sub(2), '../?.lua'))

local Utilities = require('utilities')
local Snippet = require('snippet')

local cache_path = vim.fs.joinpath(vim.fs.dirname(vim.fs.dirname(debug.getinfo(1, 'S').source:sub(2))), 'cache')
local lazy_path = vim.fs.joinpath(cache_path, 'lazy.nvim')

--- Install Lazy And The Plugins

if not vim.loop.fs_stat(lazy_path) then
  vim.fn.system({
    'git', 'clone',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    '--filter=blob:none',
    lazy_path,
  })
end

vim.opt.rtp:prepend(lazy_path)

require('lazy').setup({
  'neovim/nvim-lspconfig',
  {
    'williamboman/mason.nvim',

    dependencies = {'williamboman/mason-lspconfig.nvim'},

    config = function()
      require('mason').setup({
        install_root_dir = vim.fs.joinpath(cache_path, 'mason')
      })

      require('mason-lspconfig').setup({
        ensure_installed = {'lua_ls', 'ts_ls', 'zls'},
      })
    end
  },
  {
    'nvim-treesitter/nvim-treesitter',

    config = function()
      require('nvim-treesitter.configs').setup({
        parser_install_dir = vim.fs.joinpath(cache_path, 'parsers'),

        ensure_installed = {'lua', 'typescript', 'zig'},
        sync_install = true
      })

      vim.opt.runtimepath:append(vim.fs.joinpath(cache_path, 'parsers'))
    end
  }
}, {
  root = vim.fs.joinpath(cache_path, 'plugins'),
  lockfile = vim.fs.joinpath(cache_path, 'lazy-lock.json'),
})

vim.cmd('Lazy install')

--- Load The Snippets

local snippet_path = vim.fs.normalize(vim.fs.joinpath(debug.getinfo(1, 'S').source:sub(2), '../../../snippets'))

local snippets = {}
local files = Utilities.scan_directory(snippet_path)

for i = 1, #files do
  snippets[#snippets + 1] = Snippet:new(vim.split(files[i], '%.')[1], vim.fs.joinpath(snippet_path, files[i]))
end

--- Load The Colorschemes

local colorschemes = vim.json.decode(Utilities.read_file(vim.fs.normalize(vim.fs.joinpath(debug.getinfo(1, 'S').source:sub(2), '../../../colorschemes.json'))))
local colorscheme
local colorscheme_name

local themes = {}
local theme

local highlights

for i = 1, #colorschemes do
  colorscheme = colorschemes[i]
  colorscheme_name = colorscheme.repository:gsub('/', '-')

  vim.o.runtimepath:append(vim.fs.joinpath(cache_path, 'colorschemes', colorscheme_name))

  for i2 = 1, #colorscheme.themes do
    theme = colorscheme.themes[i2]

    vim.cmd.highlight('clear')
    vim.cmd.colorscheme(theme.name)

    highlights = {
      Normal = vim.api.nvim_get_hl_by_name('Normal', true),
    }

    for i3 = 1, #snippets do
      highlights = vim.tbl_deep_extend('keep', highlights, snippets[i3]:get_highlights())
    end

    themes[#themes + 1] = { name = theme.name, repository = theme.repository, brightness = theme.brightness, temperature = theme.temperature, highlights = highlights } 
  end
end

Utilities.write_file(vim.fs.normalize(vim.fs.joinpath(debug.getinfo(1, 'S').source:sub(2), '../../../themes.json')), vim.json.encode(themes))

-- vim.cmd('qa!')
