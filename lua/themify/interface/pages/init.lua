--- @class Page
--- @field id string
--- @field name string
--- @field update function
--- @field enter function
--- @field leave function
--- @field hover function
--- @field select function

--- @class Line
--- @field content Text
--- @field tags Tag[]
--- @field extra any

--- @alias Tag 'selectable'|string

local Utilities = require('themify.utilities')

local M = {
  --- @type table<string, Page>
  pages = {},
  --- @type string[]
  pages_id = {},

  --- @type table<string, Line[]>
  page_content_cache = {}
}

--- @type boolean
local loaded = false

--- Load The Pages
function M.load_pages()
  if not loaded then
    require('themify.interface.pages.home')
    require('themify.interface.pages.manager')

    for i = 1, #M.pages_id do
      M.pages[M.pages_id[i]].update()
    end

    loaded = true
  end
end

--- Create A Page
--- @param page Page
--- @return nil
function M.create_page(page)
  M.pages[page.id] = page
  M.pages_id[#M.pages_id + 1] = page.id
end

--- Get Page Content
--- @param id string
--- @return Line[]
function M.get_page_content(id)
  Utilities.error(M.pages[id] == nil, {'Themify: Page not found: "', id, '"'})

  if M.page_content_cache[id] == nil then
    M.update_page(id)
  end

  return M.page_content_cache[id]
end

--- Get A Page
--- @param id string
--- @return Page
function M.get_page(id)
  Utilities.error(M.pages[id] == nil, {'Themify: Page not found: "', id, '"'})

  return M.pages[id]
end

--- Get The Neighbor Page
--- @param id string
--- @param offset number
--- @return string
function M.get_neighbor_page(id, offset)
  Utilities.error(M.pages[id] == nil, {'Themify: Page not found: "', id, '"'})

  local index = Utilities.index(M.pages_id, id) + offset

  while index < 1 do index = index + #M.pages_id end
  while index > #M.pages_id do index = index - #M.pages_id end

  return M.pages_id[index]
end

--- Update The Page
--- @param id string
--- @return Line[]
function M.update_page(id)
  Utilities.error(M.pages[id] == nil, {'Themify: Page not found: "', id, '"'})

  M.page_content_cache[id] = M.pages[id].update()

  return M.page_content_cache[id]
end

return M
