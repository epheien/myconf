-- 修正 Sidebar.app 的一些问题
local M = {}

-- 仅处理 macOS 13
if hs.host.operatingSystemVersion().major ~= 13 then
  return M
end

-- 创建一个监听所有窗口的filter
M.windowFilter = hs.window.filter.new()

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
M.windowFilter:subscribe(hs.window.filter.windowCreated, function(window, appName, eventName)
  --print(string.format('新窗口创建(%s): %s (%s)', eventName, appName, window:title()))
  if toFixAppsDict[appName] then
    --window:focus()
    hs.timer.doAfter(0.01, function() window:focus() end)
  end
end)

-- 完整的Sidebar右键菜单检测
local sidebarPID = nil

-- 获取Sidebar的PID
function updateSidebarPID()
  local sidebar = hs.application.get('Sidebar')
  if sidebar then
    sidebarPID = sidebar:pid()
    print('found PID of Sidebar.app: ' .. sidebarPID)
  end
end

-- 初始化
updateSidebarPID()

-- 监听应用启动
hs.application.watcher
  .new(function(appName, eventType, appObject)
    if appName == 'Sidebar' then
      updateSidebarPID()
    end
  end)
  :start()

M.contextMenuWatcher = hs.eventtap.new({ hs.eventtap.event.types.leftMouseDown }, function(event)
  if not sidebarPID then
    return false
  end

  local pos = hs.mouse.absolutePosition()
  local element = hs.axuielement.systemElementAtPosition(pos.x, pos.y)
  if not element then
    return false
  end

  -- 检查是否属于Sidebar进程
  if sidebarPID ~= element:pid() then
    return false
  end

  local role = element:attributeValue('AXRole')
  -- AXGroup 表示点击图标, AXButton 表示点击菜单
  if role == 'AXButton' then
    -- 大概率点击了图标右键菜单
    local desc = element:attributeValue('AXDescription') -- 菜单标题
    if desc and desc ~= '' then
      element:performAction('AXPress')
      return true
    end
  end

  return false
end)

M.contextMenuWatcher:start()

return M
