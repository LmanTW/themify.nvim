import { spawn } from 'child_process'
import readline from 'readline'
import path from 'path'
import fs from 'fs'

import { Log, execute } from './utilities'

// Start The Worker
async function start(): Promise<void> {
  const colorschemes = JSON.parse(fs.readFileSync(path.resolve(__dirname, '../colorschemes.json'), 'utf8')) as Colorscheme[]
  const parsers: Parser[] = [
    { language: 'typescript', repository: 'tree-sitter/tree-sitter-typescript', source: 'typescript' },
    { language: 'python', repository: 'tree-sitter/tree-sitter-python', source: '' }
  ]

  Log.running('Checking the colorschemes')

  for (const colorscheme of colorschemes) {
    for (const theme of colorscheme.themes) {
      if (theme.brightness !== 'dark' && theme.brightness !== 'light') {
        Log.error(`Invalid value "${theme.brightness}" for property "brightness" in "${theme.name}" (${colorscheme.repository})`)
        Log.blank()

        process.exit()
      }

      if (theme.temperature !== 'cold' && theme.temperature !== 'warm') {
        Log.error(`Invalid value "${theme.brightness}" for property "temperature" in "${theme.name}" (${colorscheme.repository})`)
        Log.blank()

        process.exit()
      }
    }
  }

  if (!fs.existsSync(path.join(__dirname, 'cache'))) fs.mkdirSync(path.join(__dirname, 'cache'))
  if (!fs.existsSync(path.join(__dirname, 'cache', 'colorschemes'))) fs.mkdirSync(path.join(__dirname, 'cache', 'colorschemes'))
  if (!fs.existsSync(path.join(__dirname, 'cache', 'parsers'))) fs.mkdirSync(path.join(__dirname, 'cache', 'parsers'))
  if (!fs.existsSync(path.join(__dirname, 'cache', 'parsers', 'repository'))) fs.mkdirSync(path.join(__dirname, 'cache', 'parsers', 'repository'))
  if (!fs.existsSync(path.join(__dirname, 'cache', 'parsers', 'compiled'))) fs.mkdirSync(path.join(__dirname, 'cache', 'parsers', 'compiled'))

  for (const colorscheme of colorschemes) {
    if (!fs.existsSync(path.join(__dirname, 'cache', 'colorschemes', colorscheme.repository.replaceAll('/', '-')))) {
      Log.running(`Downloading the colorscheme: "${colorscheme.repository}"`)

      const result = await downloadColorscheme(colorscheme.repository)

      if (result.error) {
        Log.error(`Failed to clone the colorscheme: "${result.message}"`)
        Log.blank()

        process.exit()
      }
    }
  }

  Log.running('Checking the parsers')

  for (const parser of parsers) {
    if (!fs.existsSync(path.join(__dirname, 'cache', 'parsers', 'compiled', `${parser.language}.so`))) {
      Log.running(`Downloading the parser: "${parser.language}"`)

      const downloadResult = await downloadParser(parser)

      if (downloadResult.error) {
        Log.error(`Failed to clone the parser:"${downloadResult.message}"`)
        Log.blank()

        process.exit()
      }

      Log.running(`Compiling the parser: "${parser.language}"`)

      const compileResult = await compileParser(parser)

      if (compileResult.error) {
        Log.error(`Failed to compile the parser:"${compileResult.message}"`)
        Log.blank()

        process.exit()
      }
    }
  }

  const child_process = spawn('nvim', ['-u', path.join(__dirname, 'config', 'main.lua'), '--headless'], { cwd: path.join(__dirname, 'cache', 'colorschemes') })
  const reader = readline.createInterface({ input: child_process.stderr })

  reader.on('line', (line) => {
    if (line.substring(0, 7) === 'running') Log.running(line.substring(8))
    else if (line.substring(0, 8) === 'complete') Log.complete(line.substring(9))
    else if (line.substring(0, 4) === 'info') Log.info(line.substring(5))
    else if (line.substring(0, 7) === 'warning') Log.warning(line.substring(8))
    else if (line.substring(0, 5) === 'error') Log.error(line.substring(6))
    else console.log(line)
  }) 

  child_process.on('exit', () => Log.blank())
}

// Download A Colorscheme
async function downloadColorscheme(repository: string): Promise<{ error: boolean, message?: string }> {
  const result = await execute(path.join(__dirname, 'cache', 'colorschemes'), 'git', ['clone', `https://github.com/${repository}`, repository.replaceAll('/', '-')])

  return (result.code === 0) ? { error: false } : { error: true, message: result.stderr.replaceAll('\n', '\\n') }
}

// Download A Parser 
async function downloadParser(parser: Parser): Promise<{ error: boolean, message?: string }> {
  if (fs.existsSync(path.join(__dirname, 'cache', 'parsers', 'repository', parser.repository.split('/')[1]))) fs.rmSync(path.join(__dirname, 'cache', 'parsers', 'repository', parser.repository.split('/')[1]), { recursive: true })

  const result = await execute(path.join(__dirname, 'cache', 'parsers', 'repository'), 'git', ['clone', `https://github.com/${parser.repository}`])

  return (result.code === 0) ? { error: false } : { error: true, message: result.stderr.replaceAll('\n', '\\n') }
}

// Compile A Parser
async function compileParser(parser: Parser): Promise<{ error: boolean, message?: string }> {
  const result = await execute(path.join(__dirname, 'cache', 'parsers', 'repository', parser.repository.split('/')[1], parser.source), 'tree-sitter', ['build', '--output', path.join(__dirname, 'cache', 'parsers', 'compiled', `${parser.language}.so`)])

  return (result.code === 0) ? { error: false } : { error: true, message: result.stderr.replaceAll('\n', '\\n') }
}

start()

// Colorscheme
interface Colorscheme {
  repository: string,
  themes: {
    name: string,
    brightness: string,
    temperature: string
  }[],
  stars: number
}

// Parser
interface Parser {
  language: string,
  repository: string,
  source: string
}
