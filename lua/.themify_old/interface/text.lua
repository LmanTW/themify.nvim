local Utilities = require('themify.utilities')

local Text = {}

Text.__index = Text

local namespace = vim.api.nvim_create_namespace('themify')

-- Create A Text
function Text.create(content, hightlight_group)
  return Text:new({{ content = content, hightlight_group = hightlight_group }})
end

-- Combine Texts
function Text.combine(texts)
  local parts = {}

  for _, text in pairs(texts) do
    for _, part in ipairs(text.parts) do
      table.insert(parts, part)
    end
  end

  return Text:new(parts)
end

-- Create A Text
function Text:new(parts)
  self = setmetatable({}, Text)

  self.parts = parts

  return self
end

-- Center The Text
function Text:center(width)
  local length = 0

  for _, part in pairs(self.parts) do
    length = length + string.len(part.content)
  end

  table.insert(self.parts, 0, { content = string.rep(' ', (width - length) / 2) })

  return self
end

-- Render The Text
function Text:render(buffer, line)
  local content = ''
  local hightlights = {}

  for _, part in pairs(self.parts) do
    if part.hightlight_group ~= nil then
      table.insert(hightlights, {
        part.hightlight_group, -- The hightlight group.

        string.len(content), -- The start.
        string.len(content .. part.content) -- The end, 
      })
    end

    content = content .. part.content
  end

  local buffer_lines = Utilities.size(vim.api.nvim_buf_get_lines(buffer, 0, -1, false))

  while buffer_lines < line do
    vim.api.nvim_buf_set_lines(buffer, -1, -1, false, {''})

    buffer_lines = buffer_lines + 1
  end

  vim.api.nvim_buf_set_lines(buffer, line, line, false, {content})

  for _, hightlight in pairs(hightlights) do
    vim.api.nvim_buf_add_highlight(buffer, namespace, hightlight[1], line, hightlight[2], hightlight[3])
  end
end

return Text
