import fs from 'fs'

// The main function
function main(): void {
  const file = fs.openSync('message.txt', 'r')

  const buffer_size = fs.statSync('message.txt').size
  const buffer = Buffer.alloc(buffer_size)

  fs.readSync(file, buffer)
  fs.closeSync(file)

  console.log(buffer.toString())
}

main()
