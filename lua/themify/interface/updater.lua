--- @class Updater
--- @field timer any
--- @field update_cooldown number

local Utilities = require('themify.utilities')

local Updater = {}
Updater.__index = Updater

--- Create a new updater.
--- @param callback function
function Updater:new(callback)
  self = setmetatable({}, Updater)

  self.timer = vim.uv.new_timer()
  self.update_cooldown = 0

  self.timer:start(25, 25, vim.schedule_wrap(function()
    if (self.update_cooldown > 0) then
      self.update_cooldown = self.update_cooldown - 1

      if self.update_cooldown == 0 or self.update_cooldown > 9 then
        self.update_cooldown = 0

        local ok, error = pcall(callback)

        if not ok then
          self.timer:stop()
          self.timer:close()

          self.timer = nil

          assert(false, error)
        end
      end
    end
  end))

  return self
end

--- Update.
--- @return nil
function Updater:update()
  if self.timer ~= nil then
    self.update_cooldown = 5
  end
end

--- Stop the updater.
--- @return nil
function Updater:stop()
  Utilities.error(self.timer == nil, {'Themify: The updater is already stopped'})

  self.timer:stop()
  self.timer:close()

  self.timer = nil
end

return Updater
