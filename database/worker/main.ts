import { spawn } from 'child_process'
import path from 'path'
import fs from 'fs'

import colorschemes from './colorschemes'

if (!fs.existsSync(path.join(__dirname, 'cache'))) fs.mkdirSync(path.join(__dirname, 'cache'))
if (!fs.existsSync(path.join(__dirname, 'cache', 'colorschemes'))) fs.mkdirSync(path.join(__dirname, 'cache', 'colorschemes'))

for (const folderName of fs.readdirSync(path.join(__dirname, 'cache', 'colorschemes'))) {
  if (colorschemes.find((colorscheme) => colorscheme.name === folderName) === undefined) fs.rmSync(path.join(__dirname, 'cache', 'colorschemes', folderName), { recursive: true })
}

// Start The Database Updating Process
async function start(): Promise<void> {
  for (const colorscheme of colorschemes) {
    if (!fs.existsSync(path.join(__dirname, 'cache', 'colorschemes', colorscheme.name))) {
      console.log(`Cloning: "${colorscheme.author}/${colorscheme.name}"`)

      const result = await execute(path.join(__dirname, 'cache', 'colorschemes'), 'git', ['clone', `https://github.com/${colorscheme.author}/${colorscheme.name}.git`])

      if (result.code !== 0) {
        console.log(`Error: "${result.stderr.replaceAll('\n', '\\n')}"`)
    
        process.exit(1)
      }
    } 
  }

  const lines = `

local colorschemes = {${colorschemes.map((colorscheme) => `{ path = '${path.join(__dirname, 'cache', 'colorschemes', colorscheme.name)}', themes = {${colorscheme.themes.map((theme) => `'${theme.name}'`)}} }`).join(', ')}}
local colorscheme

local data = {}

for i = 1, #colorschemes do
  colorscheme = colorschemes[i]

  vim.o.runtimepath = table.concat({vim.o.runtimepath, ',', colorscheme.path})

  data[i] = {}

  for i2 = 1, #colorscheme.themes do
    vim.cmd.colorscheme(colorscheme.themes[i2])

    data[i][i2] = {
      ["@string.regexp"] = vim.api.nvim_get_hl(0, { name = '@string.regexp', link = true })
    }
  end
end

local file = vim.loop.fs_open('${path.join(__dirname, 'cache', 'highlight_data.json')}', 'w', 438)

vim.loop.fs_write(file, vim.json.encode(data))

vim.cmd(':qa!')

  `.split('\n')

  for (let i = lines.length - 1; i >= 0; i--) {
    lines[i] = lines[i].trim()

if (lines[i].length === 0) lines.splice(i, 1)
  }

  fs.writeFileSync(path.join(__dirname, 'cache', 'config.lua'), lines.join('\n'))

  const neovim = spawn('nvim', ['-u', 'config.lua', '--headless'], { cwd: path.join(__dirname, 'cache') })

  neovim.stdout.pipe(process.stdout)
  neovim.stderr.pipe(process.stderr)

  neovim.once('exit', () => {
    const highlight_data: { [key: string]: { [key: string]: number }}[][] = JSON.parse(fs.readFileSync(path.join(__dirname, 'cache', 'highlight_data.json')))
    const data: { name: string, author: string, themes: { name: string, brightness: 'dark' | 'light', temperature: 'cold' | 'warm', highlights: { [key: string]: { [key: string]: number }}}[] }[] = []

    for (let i = 0; i < colorschemes.length; i++) {
      const colorscheme = colorschemes[i]

      data.push({ name: colorscheme.name, author: colorscheme.author, themes: [] })

      for (let i2 = 0; i2 < colorscheme.themes.length; i2++) data[data.length - 1].themes.push({ name: colorscheme.themes[i2].name, brightness: colorscheme.themes[i2].brightness, temperature: colorscheme.themes[i2].temperature, highlights: highlight_data[i][i2] })        
    }

    fs.writeFileSync(path.resolve(__dirname, '../colorschemes.json'), JSON.stringify(data))

    fs.rmSync(path.join(__dirname, 'cache', 'config.lua'))
    fs.rmSync(path.join(__dirname, 'cache', 'highlight_data.json'))
  })
}

// Execute A Command
async function execute(cwd: string, command: string, args: string[]): Promise<{ code: null|number, stdout: string, stderr: string }> {
  return new Promise((resolve) => {
    const child_process = spawn(command, args, { cwd })

    let stdout = Buffer.alloc(0)
    let stderr = Buffer.alloc(0)
  
    child_process.stdout.on('data', (data) => stdout = data)
    child_process.stderr.on('data', (data) => stderr = data)
  
    child_process.once('exit', (code) => resolve({ code, stdout: stdout.toString(), stderr: stderr.toString() }))
  })
}

start()
