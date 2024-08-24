local M = {}

--- @type table<string, function[]>
local events = {}

--- Listen To An Event
--- @param event string
--- @param callback function
--- @return nil
function M.listen(event, callback)
  if events[event] == nil then
    events[event] = {}
  end

  events[event][#events[event] + 1] = callback
end

-- Call An Event
function M.call(event)
  if events[event] ~= nil then
    for i = 1, #events[event] do
      events[event][i]()
    end
  end
end

return M
