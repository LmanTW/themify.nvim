local Utilities = require('utilities')

local Snippet = {}
Snippet.__index = Snippet

local language_servers = {
  zig = 'zls'
}

--- Create A New Snippet
--- @param path string
--- @param language string
function Snippet:new(language, path)
  self = setmetatable({}, Snippet)

  self.language = language
  self.content = vim.json.decode(Utilities.read_file(path))

  return self
end

--- Attach The Language Server
--- @param buffer integer
--- @param name string
--- @return boolean
function attach_language_server(buffer, name)
  local clients = vim.lsp.get_clients()
  local client

  for i = 1, #clients do
    client = clients[i]

    print(vim.inspect(clients))

    if client.name == name then
      vim.lsp.buf_attach_client(bufnr, client.id)

      return true
    end
  end

  return false
end

--- Get Highlights
--- @return table<string, any>
function Snippet:get_highlights()
  local fragments = {}
  local fragment

  local lines = {}
  local line

  local x

  for i = 1, #self.content do
    line = {}
    x = 0

    for i2 = 1, #self.content[i] do
      fragment = self.content[i][i2]
      fragments[#fragments + 1] = { x = x, y = i - 1, highlight = fragment[2] }

      line[#line + 1] = fragment[1]
      x = x + fragment[1]:len()
    end

    lines[i] = table.concat(line)
  end

  local buffer = vim.api.nvim_create_buf(false, true)

  vim.api.nvim_buf_set_lines(buffer, 0, -1, false, lines)
  vim.api.nvim_set_current_buf(buffer)

  vim.treesitter.start(buffer, self.language)
  attach_language_server(buffer, language_servers[self.language])

  local highlights = {}

  for i = 1, #fragments do
    fragment = fragments[i]

    if fragment.highlight ~= nil and highlights[fragment.highlight] == nil then
      local range = vim.lsp.semantic_tokens.get_at_pos(buffer, fragment.y, fragment.x)
      local captures = vim.treesitter.get_captures_at_pos(buffer, fragment.y, fragment.x)

      -- print(vim.inspect(range))

      if #captures > 0 then
        highlights[fragment.highlight] = vim.api.nvim_get_hl_by_name('@' .. captures[1].capture, true)
      end
    end
  end

  return highlights
end

return Snippet
