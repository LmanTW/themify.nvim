--- @class List
--- @field sections table<string, { title: Line, content: Line[] }>
--- @field sections_id string[]

local Text = require('themify.interface.components.text')
local Utilities = require('themify.utilities')

local List = {}
List.__index = List

local line_blank = { content = Text:new(''), tags = {} }

--- Create A New List
function List:new()
  self.sections = {}
  self.sections_id = {}

  return self
end

--- Create A Section
--- @param id string
--- @param title Line
--- @return nil
function List:create_section(id, title)
  Utilities.error(self.sections[id] ~= nil, {'Themify: Section already exists: "', id, '"'})

  self.sections[id] = { title = title, content = {} }
  self.sections_id[#self.sections_id + 1] = id
end

--- Add An Item
--- @param section string
--- @param line Line
--- @return nil
function List:add_item(section, line)
  Utilities.error(self.sections[section] == nil, {'Themify: Section not found: "', section, '"'})

  local content = self.sections[section].content

  content[#content + 1] = line
end

--- Get The Content Of The List
--- @return Line[]
function List:get_content()
  local content = {}
  local section

  for i = 1, #self.sections_id do
    section = self.sections[self.sections_id[i]]

    content[#content + 1] = section.title
    vim.list_extend(content, section.content)

    if i < #self.sections_id then
      content[#content + 1] = line_blank
    end
  end

  return content
end

return List
