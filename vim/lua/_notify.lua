-- 定制的通用 notify 库, 替代 noice.nvim 中 buggy 的 nvim-notify.nvim

local M = {}

local level_map = {
  DEBUG = vim.log.levels.DEBUG,
  ERROR = vim.log.levels.ERROR,
  INFO = vim.log.levels.INFO,
  TRACE = vim.log.levels.TRACE,
  WARN = vim.log.levels.WARN,
  OFF = vim.log.levels.OFF,
}

-- opts: replace = bool, title = string
function M.notify(msg, level, opts)
  local notify = require('mini.notify').make_notify()
  level = level or vim.log.levels.INFO
  if type(level) == 'string' then
    level = level_map[string.upper(level)] or vim.log.levels.INFO
  end
  return notify(msg, level, opts) -- opts 未使用
end

-- 关闭 notify, 并可以把 pending 的消息也全清
-- `require("notify").dismiss({ pending = true, silent = true })`
function M.dismiss(opts) opts = opts or {} end

return M.notify
