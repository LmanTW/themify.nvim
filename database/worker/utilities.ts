import { spawn } from 'child_process'

// Log
class Log {
  public static blank    (): void                {console.log()}
  public static running  (content: string): void {console.log(`\u001b[37m[ Running  ]: ${content}\u001b[39m`)}
  public static complete (content: string): void {console.log(`\u001b[32m[ Complete ]: ${content}\u001b[39m`)}
  public static info     (content: string): void {console.log(`\u001b[35m[ Info     ]: ${content}\u001b[39m`)}
  public static warning  (content: string): void {console.log(`\u001b[33m[ Warning  ]: ${content}\u001b[39m`)}
  public static error    (content: string): void {console.log(`\u001b[31m[ Error    ]: ${content}\u001b[39m`)}
}

// Execute A Command
async function execute(cwd: string, command: string, args: string[]): Promise<{ code: null | number, stdout: string, stderr: string }> {
  return new Promise((resolve) => {
    const child_process = spawn(command, args, { cwd })

    let stdout: Buffer = Buffer.alloc(0)
    let stderr: Buffer = Buffer.alloc(0)
  
    child_process.stdout.on('data', (data) => stdout = data)
    child_process.stderr.on('data', (data) => stderr = data)
    child_process.on('exit', (code) => resolve({ code, stdout: stdout.toString(), stderr: stderr.toString() }))
  }) 
}

export { Log, execute }
