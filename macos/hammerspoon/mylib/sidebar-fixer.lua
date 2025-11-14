-- 修正 Sidebar.app 的一些问题
local M = {}

-- 仅处理 macOS 13
if hs.host.operatingSystemVersion().major ~= 13 then
  return M
end

-- 创建一个监听所有窗口的filter
M.windowCreatedFilter = hs.window.filter.new()

-- 所有关闭全部窗口仍然不退出 Dock 栏中的应用的那些应用都要处理
local toFixApps = {
  '访达',
  '终端',
  '备忘录',
  '微信',
  'QQ',
  'Safari浏览器',
  'Microsoft Edge',
  'Firefox',
  'Google Chrome',
  'Royal TSX',
  'Dash',
  'MacVim',
  'PDF Expert',
  'Typora',
  'Vmware Fusion',
  'Telegram',
  'Proxifier',
}
local toFixAppsDict = {}
for _, name in ipairs(toFixApps) do
  toFixAppsDict[name] = name
end

-- 监听窗口创建事件
M.windowCreatedFilter:subscribe(hs.window.filter.windowCreated, function(window, appName, eventName)
  --print(string.format('新窗口创建(%s): %s (%s)', eventName, appName, window:title()))
  if toFixAppsDict[appName] then
    window:focus()
  end
end)

return M
