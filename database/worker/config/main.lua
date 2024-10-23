package.path = vim.fs.normalize(vim.fs.joinpath(debug.getinfo(1, 'S').source:sub(2), '../?.lua'))

local cache_path = vim.fs.normalize(vim.fs.joinpath(debug.getinfo(1, 'S').source:sub(2), '../../cache'))
local snippets_path = vim.fs.normalize(vim.fs.joinpath(debug.getinfo(1, 'S').source:sub(2), '../../../snippets'))
local parsers_path = vim.fs.joinpath(cache_path, 'parsers', 'compiled')

local Utilities = require('utilities')
local Snippet = require('snippet')

print('running', 'Loading the parsers\n')

local parser_files = Utilities.scan_directory(parsers_path)

for i = 1, #parser_files do
  vim.treesitter.language.add(vim.split(parser_files[i], '%.')[1], {
    path = vim.fs.joinpath(parsers_path, parser_files[i]),
  })
end

print('complete', table.concat({'Successfully loaded ', tostring(#parser_files), ' parsers\n'}))
print('running', 'Loading the colorschemes\n')

local colorschemes = vim.json.decode(Utilities.read_file(vim.fs.normalize(vim.fs.joinpath(debug.getinfo(1, 'S').source:sub(2), '../../../colorschemes.json'))))
local colorscheme
local colorscheme_name

for i = 1, #colorschemes do
  colorscheme = colorschemes[i]
  colorscheme_name = colorscheme.repository:gsub('/', '-')

  vim.o.runtimepath = table.concat({vim.o.runtimepath, ',', vim.fs.joinpath(cache_path, 'colorschemes', colorscheme_name)})
end

print('complete', table.concat({'Successfully loaded ', tostring(#colorschemes), ' colorschemes\n'}))
print('running', 'Loading the snippets\n')

local snippets = {}
local snippet_files = Utilities.scan_directory(snippets_path)
local snippet_file

for i = 1, #snippet_files do
  snippet_file = Utilities.read_file(vim.fs.joinpath(snippets_path, snippet_files[i]))

  snippets[#snippets + 1] = Snippet:new(vim.split(snippet_files[i], '%.')[1], vim.json.decode(snippet_file))
end

print('complete', table.concat({'Successfully loaded ', tostring(#snippets), ' snippets\n'}))
print('running', 'Getting the preview highlight groups\n')

local themes = {}
local theme
local highlights

for i = 1, #colorschemes do
  colorscheme = colorschemes[i]
  colorscheme_name = colorscheme.repository:gsub('/', '-')

  for i2 = 1, #colorscheme.themes do
    theme = colorscheme.themes[i2]

    vim.cmd.highlight('clear')

    if theme.background == nil then
      vim.o.background = 'dark'
    else
      vim.o.background = theme.background
    end

    if theme.setup == nil then
      vim.cmd.colorscheme(theme.name)
    else
      loadstring(theme.setup)()
    end

    highlights = {
      Normal = vim.api.nvim_get_hl(0, { name = 'Normal', link = true }),
      FloatBorder = vim.api.nvim_get_hl(0, { name = 'FloatBorder', link = true })
    }

    for i3 = 1, #snippets do
      highlights = vim.tbl_deep_extend('keep', highlights, snippets[i3]:get_highlights())
    end

    themes[#themes + 1] = { name = table.concat({theme.name, theme.background == nil and '' or table.concat({' ', '(', theme.background, ')'})}), repository = colorscheme.repository, brightness = theme.brightness, temperature = theme.temperature, highlights = highlights }
  end
end

Utilities.write_file(vim.fs.normalize(vim.fs.joinpath(debug.getinfo(1, 'S').source:sub(2), '../../../themes.json')), vim.json.encode(themes))

print('complete', table.concat({'Successfully got all the preview highlight groups\n'}))

print('info', table.concat({'Themes in the database: ', tostring(#themes), '\n'}))

vim.cmd('qa')
