--- @class Snippet
--- @field content Text[]

local Text = require('themify.interface.components.text')
local Utilities = require('themify.utilities')
local Data = require('themify.core.data')

local Snippet = {
  --- @type table<string, [string, nil|string][][]>
  snippets = {}
}

local files = Utilities.scan_directory(Data.snippets_path)

for i = 1, #files do
  Snippet.snippets[vim.split(files[i], '%.')[1]] = vim.json.decode(Utilities.read_file(vim.fs.joinpath(Data.snippets_path, files[i])))
end

--local snippets = {
--  lua = [[
--  function main()
--    local file = vim.loop.fs_open('message.txt', 'r', 438)
--    assert(file != nil, 'Cannot open the file')
--  
--    local content = vim.loop.fs_read(file, stats.size, 0)
--    assert(content ~= nil, 'Cannot read the file')
--  
--    print(content)
--  
--    vim.loop.fs_close(file)
--  end
--  
--  main()
--  ]],
--  python = [[
--    def main():
--      print('Hello World!')
--  ]],
--  typescript = [[
--  import fs from 'fs'
--  
--  function main(): void {
--    const file = fs.openSync('message.txt')
--  
--    const buffer_size = fs.statSync('message.txt').size
--    const buffer = Buffer.alloc(buffer_size)
--  
--    fs.readSync(file, buffer)
--  
--    console.log(buffer.toString())
--  
--    fs.closeSync(file)
--  }
--  
--  main()
--  ]],
--  zig = [[
--  const std = @import("std");
--
--  pub fn main() !void {
--      const file = try std.fs.cwd().openFile("message.txt", .{});
--      defer file.close();
--  
--      const allocator = std.heap.page_allocator;
--  
--      const buffer_size = try file.getEndPos();
--      const buffer = try allocator.alloc(u8, buffer_size);
--      defer allocator.free(buffer);
--  
--      _ = try file.readAll(buffer);
--  
--      std.debug.print("{s}", .{buffer});
--  }
--  ]]
--}

--- Render The Snippet
--- @param buffer integer
--- @return nil
function Snippet.render(buffer, language)
  vim.api.nvim_buf_set_lines(buffer, 0, -1, false, {})

  local line
  local parts

  for i = 1, #Snippet.snippets[language] do
    line = Snippet.snippets[language][i]
    parts = {}

    for i2 = 1, #line do
      parts[#parts + 1] = Text:new(line[i2][1], line[i2][2] == nil and nil or table.concat({'ThemifyPreview', line[i2][2]}))
    end

    Text.combine(parts):render(buffer, i - 1)
  end
end

return Snippet
