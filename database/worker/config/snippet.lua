--- @class Snippet
--- @field language string
--- @field content [string, nil|number][][]
--- @field buffer integer

local Utilities = require('utilities')

local Snippet = {}
Snippet.__index = Snippet

--- Create A New Snippet
--- @param language string
--- @param content [string, nil|string, nil|string][][]
function Snippet:new(language, content)
  self = setmetatable({}, Snippet)

  self.language = language
  self.content = content

  self.buffer = vim.api.nvim_create_buf(false, true)

  local lines = {}
  local parts

  for i = 1, #content do
    parts = {}

    for i2 = 1, #content[i] do
      parts[i2] = content[i][i2][1]
    end

    lines[i] = table.concat(parts)
  end

  vim.api.nvim_buf_set_lines(self.buffer, 0, -1, false, lines)
  vim.api.nvim_set_current_buf(self.buffer)
  vim.treesitter.start(self.buffer, language)

  return self
end

--- Get The Highlights
--- @return table<string, any>
function Snippet:get_highlights() 
  local highlights = {}

  local line
  local part
  local x

  for i = 1, #self.content do
    line = self.content[i]
    x = 0

    for i2 = 1, #line do
      local part = line[i2]

      if part[2] ~= nil and highlights[part[2]] == nil then
        if part[3] == nil then
          local captures = vim.treesitter.get_captures_at_pos(self.buffer, i - 1, x)

          if #captures > 0 then
            highlights[part[2]] = vim.api.nvim_get_hl(0, { name = table.concat({'@', captures[1].capture}) })
          end
        else
           highlights[part[2]] = vim.api.nvim_get_hl(0, { name = line[i2][3] })
        end
      end

      x = x + line[i2][1]:len()
    end
  end

  return highlights
end

return Snippet
