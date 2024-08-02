local Text = require('themify.interface.components.text')
local Utilities = require('themify.utilities')

local List = {}

List.__index = List

-- Create A List
function List:new()
  self = setmetatable({}, List)

  self.groups = {}

  return self
end

-- Check If The List Has A Group
function List:has_group(name)
  return self.groups[name] ~= nil
end

-- Create A Group
function List:create_group(name, text)
  if self.groups[name] ~= nil then
    error('Themify: Group already exists "' .. name .. '"')
  end

  self.groups[name] = { text = text, children = {} }
end

-- Add Child
function List:add_child(group_name, text, info)
  if self.groups[group_name] == nil then
    error('Themify: Group not found "' .. group_name .. '"')
  end

  table.insert(self.groups[group_name].children, { text = text, info = info })
end

-- Render The List
function List:render()
  local lines = {}

  local groups = Utilities.size(self.groups)
  local index = 1

  for _, group in pairs(self.groups) do
    table.insert(lines, { text = group.text, info = { type = 'group_title' }})

    for i = 1, #group.children do
      table.insert(lines, group.children[i])
    end

    if (index < groups) then
      table.insert(lines, { text = Text:new(''), info = { type = 'blank' }})
    end

    index = index + 1
  end

  return lines
end

return List
