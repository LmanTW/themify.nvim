local Text = require('themify.interface.components.text')
local Utilities = require('themify.utilities')

local Group = {}

Group.__index = Group

local blank = Text:new('')

--- @class Group
--- @field lists table<string, { name: string, elements: { content: Text, tags: string[], extra?: any }[] }>
--- @field lists_id string[]

--- @alias Tags 'selectable' | 'title' | 'theme'

--- Create A Group
function Group:new()
  self = setmetatable({}, Group)

  self.lists = {}
  self.lists_id = {}

  return self
end

--- Check If A List Exist
--- @param id string
--- @return boolean
function Group:has_list(id)
  return self.lists[id] ~= nil
end

--- Create A List
--- @param id string
--- @param name Text
--- @return nil
function Group:create_list(id, name)
  self.lists[id] = { name = name, elements = {} }
  self.lists_id[#self.lists_id + 1] = id
end

--- Add Element To A List
--- @param list_id string
--- @param content Text
--- @param tags Tags[]
--- @param extra any?
--- @return nil
function Group:add_element(list_id, content, tags, extra)
  assert(self.lists[list_id] ~= nil, table.concat({'List Not Found: "', list_id, '"'}))

  local list = self.lists[list_id]

  list.elements[#list.elements + 1] = { content = content, tags = tags, extra = extra }
end

--- Render The Group
--- @return { content: Text, tags: Tags[] }[]
function Group:render()
  local lines = {}

  local size = Utilities.size(self.lists)
  local id

  for i = 1, #self.lists_id do
    id = self.lists_id[i]

    lines[#lines + 1] = { content = self.lists[id].name, tags = {'selectable', 'title'}}

    for i2 = 1, #self.lists[id].elements do
      lines[#lines + 1] = self.lists[id].elements[i2]
    end

    if i < size then
      lines[#lines + 1] = { content = blank, tags = {}}
    end
  end

  return lines
end

return Group
