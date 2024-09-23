import { spawn } from 'child_process'
import path from 'path'
import fs from 'fs'

import colorschemes from './colorschemes'

if (!fs.existsSync(path.join(__dirname, 'cache'))) fs.mkdirSync(path.join(__dirname, 'cache'))
if (!fs.existsSync(path.join(__dirname, 'cache', 'colorschemes'))) fs.mkdirSync(path.join(__dirname, 'cache', 'colorschemes'))

for (const folderName of fs.readdirSync(path.join(__dirname, 'cache', 'colorschemes'))) {
  if (colorschemes.find((colorscheme) => colorscheme.repository.split('/')[1] === folderName) === undefined) fs.rmSync(path.join(__dirname, 'cache', 'colorschemes', folderName), { recursive: true })
}

// Start The Database Updating Process
async function start(): Promise<void> {
  const themes: { name: string, repository: string, brightness: 'dark'|'light', temperature: 'cold'|'warm' }[] = []

  for (const colorscheme of colorschemes) {
    for (const theme of colorscheme.themes) {
      themes.push({
        name: theme.name,
        repository: colorscheme.repository,

        brightness: theme.brightness,
        temperature: theme.temperature
      })
    }

    if (!fs.existsSync(path.join(__dirname, 'cache', 'colorschemes', colorscheme.repository.split('/')[1]))) {
      console.log(`Cloning: "${colorscheme.repository}"`)

      const result = await execute(path.join(__dirname, 'cache', 'colorschemes'), 'git', ['clone', `https://github.com/${colorscheme.repository}.git`])

      if (result.code !== 0) {
        console.log(`Error: "${result.stderr.split('\n')[0]}"`)
    
        process.exit(1)
      }
    }
  }

  const lines = `

local themes = {${themes.map((theme) => `{ name = '${theme.name}', colorscheme_path = '${path.join(__dirname, 'cache', 'colorschemes', theme.repository.split('/')[1])}' }`).join(', ')}}
local theme

local previews_data = {}

for i = 1, #themes do
  theme = themes[i]

  if vim.o.runtimepath:find(theme.colorscheme_path) == nil then
    vim.o.runtimepath = table.concat({vim.o.runtimepath, ',', theme.colorscheme_path})
  end

  vim.cmd.colorscheme(theme.name)

  previews_data[i] = {
    ["@string.regexp"] = vim.api.nvim_get_hl(0, { name = '@string.regexp', link = true }) 
  }
end

local file = vim.loop.fs_open('${path.join(__dirname, 'cache', 'previews_data.json')}', 'w', 438)

vim.loop.fs_write(file, vim.json.encode(previews_data))

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
    const previews_data: { [key: string]: { [key: string]: number }}[] = JSON.parse(fs.readFileSync(path.join(__dirname, 'cache', 'previews_data.json'), 'utf8'))
    const database: { name: string, repository: string, brightness: 'dark'|'light', temperature: 'cold'|'warm', preview: { [key: string]: { [key: string]: number }} }[] = []

    for (let i = 0; i < themes.length; i++) {
      const theme = themes[i]

      database.push({ name: theme.name, repository: theme.repository, brightness: theme.brightness, temperature: theme.temperature, preview: previews_data[i] })
    }

    fs.writeFileSync(path.resolve(__dirname, '../colorschemes.json'), JSON.stringify(database))

    fs.rmSync(path.join(__dirname, 'cache', 'config.lua'))
    fs.rmSync(path.join(__dirname, 'cache', 'previews_data.json'))
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
