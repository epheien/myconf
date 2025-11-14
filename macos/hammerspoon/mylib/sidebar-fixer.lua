-- 修正 Sidebar.app 的一些问题
local M = {}

-- 创建一个监听所有窗口的filter
M.windowCreatedFilter = hs.window.filter.new()

local toFixApp = {
  ['访达'] = true,
  ['终端'] = true,
  ['备忘录'] = true,
}
-- 监听窗口创建事件
M.windowCreatedFilter:subscribe(hs.window.filter.windowCreated, function(window, appName, eventName)
  --print(string.format('新窗口创建(%s): %s (%s)', eventName, appName, window:title()))
  -- 在这里添加您的处理逻辑
  if toFixApp[appName] then
    window:focus()
  end
end)

return M
