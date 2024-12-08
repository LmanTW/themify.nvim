local Manager = require('themify.core.manager')
local Utilities = require('themify.utilities')
local Event = require('themify.core.event')
local Data = require('themify.core.data')

local M = {
  --- @type boolean
  enabled = false,

  --- @type Activity_Data
  data = Data.read_activity_data(),
  --- @type number (Minutes)
  update_interval = 1
}

--- Enable activity and start recording.
--- @return nil
function M.enable()
  Utilities.error(M.enabled, {'[Themify] Activity is already enabled'})

  M.enabled = true

  local active = true

  vim.api.nvim_create_autocmd({'CursorMoved', 'CursorMovedI', 'InsertEnter'}, {
    callback = function()
      local buffer = vim.bo[vim.api.nvim_get_current_buf()].buftype

      if buffer == '' then
        active = true
      end
    end
  })

  vim.uv.new_timer():start(0, M.update_interval * 60000, vim.schedule_wrap(function()
    local state = Data.read_state_data()

    if state ~= vim.NIL and active then
      active = false

      local activity = Data.read_activity_data()
      local timestamp = vim.loop.gettimeofday()

      if activity == vim.NIL then
        activity = { last_update = timestamp - M.update_interval, colorschemes = {} }
      end

      if timestamp - activity.last_update >= M.update_interval then
        activity.last_update = timestamp

        if state.colorscheme_id == nil then
          if activity.colorschemes[state.theme] == nil then
            activity.colorschemes[state.theme] = {
              type = 'local',
              usage = { last_active = timestamp, total_minutes = 0, today_minutes = 0 }
            }
          end

          if activity.colorschemes[state.theme].type == 'local' then
            local usage = activity.colorschemes[state.theme].usage

            usage.total_minutes = usage.total_minutes + M.update_interval
            usage.today_minutes = os.date('%d', timestamp) == os.date('%d', usage.last_active) and usage.today_minutes + M.update_interval or 0
            usage.last_active = timestamp
          end
        else
          if activity.colorschemes[state.colorscheme_id] == nil then
            activity.colorschemes[state.colorscheme_id] = {
              type = 'remote',
              themes = {}
            }
          end

          if activity.colorschemes[state.colorscheme_id].type == 'remote' then
            local themes = activity.colorschemes[state.colorscheme_id].themes

            if themes[state.theme] == nil then
              themes[state.theme] = { last_active = timestamp, total_minutes = 0, today_minutes = 0 }
            end

            local usage = themes[state.theme]

            usage.total_minutes = usage.total_minutes + M.update_interval
            usage.today_minutes = os.date('%d', timestamp) == os.date('%d', usage.last_active) and usage.today_minutes + M.update_interval or 0
            usage.last_active = timestamp
          end
        end

        M.data = activity
        Data.write_activity_data(activity)

        Event.emit('window_update')
      end
    end
  end))
end

--- Check the activity data.
function M.check_activity_data()
  local activity = Data.read_activity_data()

  local colorscheme_data
  local themes
  local usage

  local timestamp = vim.loop.gettimeofday()

  if activity == vim.NIL then
    activity = { last_update = timestamp - M.update_interval, colorschemes = {} }
  end

  for colorscheme_id, colorscheme_activity in pairs(activity.colorschemes) do
    if colorscheme_activity.type == 'remote' then
      colorscheme_data = Manager.colorschemes_data[colorscheme_id]

      if colorscheme_data == nil or colorscheme_data.type ~= 'remote' then
        activity.colorschemes[colorscheme_id] = nil
      else
        themes = colorscheme_activity.themes

        for _, theme_usage in pairs(themes) do
          if os.date('%d', timestamp) ~= os.date('%d', theme_usage.last_active) then
            theme_usage.today_minutes = 0
          end
        end
      end
    else
      colorscheme_data = Manager.colorschemes_data[colorscheme_id]

      if colorscheme_data == nil or colorscheme_data.type ~= 'local' then
        activity.colorschemes[colorscheme_id] = nil
      else
        usage = colorscheme_activity.usage

        if os.date('%d', timestamp) ~= os.date('%d', usage.last_active) then
          usage.today_minutes = 0
        end
      end
    end
  end

  Data.write_activity_data(activity)
end

return M
