local Text = {}

Text.__index = Text

local namespace = vim.api.nvim_create_namespace('themify')

--- @class Text
--- @field parts { content: string, hightlight_group?: string }[]

--- Combine The Texts
--- @param texts Text[]
--- @return Text
function Text.combine(texts)
  local text = Text:new()

  for i = 1, #texts do
    for i2 = 1, #texts[i].parts do
      text.parts[#text.parts + 1] = texts[i].parts[i2]
    end
  end

  return text
end

--- Create A Text
--- @param content string?
--- @param hightlight_group string?
function Text:new(content, hightlight_group)
  self = setmetatable({}, Text)

  self.parts = content == nil and {} or {{ content = content, hightlight_group = hightlight_group }}

  return self
end

--- Center The Text
--- @param width number
--- @return Text
function Text:center(width)
  local text_width = 0

  for i = 1, #self.parts do
    text_width = text_width + string.len(self.parts[i].content)
  end

  table.insert(self.parts, 1, { content = string.rep(' ', (width - text_width) / 2) })

  return self
end

--- Render The Text
--- @param buffer any
--- @param line any
--- @return nil
function Text:render(buffer, line)
  local content_chunks = {}
  local hightlights = {}

  local part
  local current_x = 0

  for i = 1, #self.parts do
    part = self.parts[i]

    content_chunks[#content_chunks + 1] = part.content

    if part.hightlight_group ~= nil then
      hightlights[#hightlights + 1] = {
        group = part.hightlight_group,

        x = current_x,
        width = string.len(part.content)
      }
    end

    current_x = current_x + string.len(part.content)
  end

  -- If the lines in the buffer does not reach the line (y) of the text, add more lines.

  local lines = #vim.api.nvim_buf_get_lines(buffer, 0, -1, false)

  while lines < line do
    vim.api.nvim_buf_set_lines(buffer, -1, -1, false, {''})

    lines = lines + 1
  end

  vim.api.nvim_buf_set_lines(buffer, line, line, false, {table.concat(content_chunks)})

  for _, hightlight in pairs(hightlights) do
    vim.api.nvim_buf_add_highlight(buffer, namespace, hightlight.group, line, hightlight.x, hightlight.x + hightlight.width)
  end
end

return Text
