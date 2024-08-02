local Text = {}

Text.__index = Text

local namespace = vim.api.nvim_create_namespace('themify')

-- Combine Texts
function Text.combine(texts)
  local text = Text:new()

  for i = 1, #texts do
    text:add_parts(texts[i].parts)
  end

  return text
end

-- Create A Text
function Text:new(content, hightlight_group)
  self = setmetatable({}, Text)

  self.parts = content == nil and {} or {{ content = content, hightlight_group = hightlight_group }}

  return self
end

-- Add Parts To The Text
function Text:add_parts(parts)
  for i = 1, #parts do
    self.parts[#self.parts + 1] = parts[i]
  end
end

-- Center The Text
function Text:center(width)
  local text_width = 0

  for i = 1, #self.parts do
    text_width = text_width + string.len(self.parts[i].content)
  end

  table.insert(self.parts, 1, { content = string.rep(' ', (width - text_width) / 2) })
  table.insert(self.parts, { content = string.rep(' ', (width - text_width) / 2) })

  return self
end

-- Render The Text
function Text:render(buffer, line)
  local content = ''
  local hightlights = {}

  local part

  for i = 1, #self.parts do
    part = self.parts[i]

    if part.hightlight_group ~= nil then
      table.insert(hightlights, {
        part.hightlight_group, -- The hightlight group.

        string.len(content), -- The start.
        string.len(content .. part.content) -- The end, 
      })
    end

    content = table.concat({content, part.content})
  end

  -- If the lines in the buffer does not reach the line, add more lines.

  local lines = #vim.api.nvim_buf_get_lines(buffer, 0, -1, false)

  while lines < line do
    vim.api.nvim_buf_set_lines(buffer, -1, -1, false, {''})

    lines = lines + 1
  end

  vim.api.nvim_buf_set_lines(buffer, line, line, false, {content})

  for _, hightlight in pairs(hightlights) do
    vim.api.nvim_buf_add_highlight(buffer, namespace, hightlight[1], line, hightlight[2], hightlight[3])
  end
end

return Text
