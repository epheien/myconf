local stages_util = require('notify.stages.util')

local M = {}

M.stages = function(direction)
  return {
    function(state)
      local next_height = state.message.height + 2
      local next_row = stages_util.available_slot(state.open_windows, next_height, direction)
      if not next_row then
        return nil
      end
      return {
        relative = 'editor',
        anchor = 'NE',
        width = state.message.width,
        height = state.message.height,
        col = vim.opt.columns:get() - 1, -- 适配 scrollbar
        row = next_row,
        border = 'rounded',
        style = 'minimal',
      }
    end,
    function(state, win)
      return {
        col = vim.opt.columns:get() - 1, -- 适配 scrollbar
        time = true,
        row = stages_util.slot_after_previous(win, state.open_windows, direction),
      }
    end,
  }
end

return M
