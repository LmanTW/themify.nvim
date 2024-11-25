local M = {
  --- @type table<string, function[]>
  listeners = {}
}

--- Listen to an event.
--- @param event string
--- @param callback function
--- @return nil
function M.listen(event, callback)
  if M.listeners[event] == nil then
    M.listeners[event] = {}
  end

  local group = M.listeners[event]

  group[#group + 1] = callback
end

--- Emit an event.
--- @param event string
function M.emit(event)
  if M.listeners[event] ~= nil then
    local group = M.listeners[event]

    for i = 1, #group do
      group[i]()
    end
  end
end

return M
