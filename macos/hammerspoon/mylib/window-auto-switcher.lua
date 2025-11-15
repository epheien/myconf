-- 增强的窗口自动切换器
-- 切换日志: MyConf.modules['window-auto-switcher'].toggleDebug()
local WindowAutoSwitcherV2 = {
  filter = nil,
  isProcessing = false,
  config = {
    enabled = true,
    delay = 0.1, -- 检查延迟(秒)
    excludeApps = { -- 排除的应用
      ['Sidebar'] = true,
      ['微信输入法'] = true,
      ['控制中心'] = true,
      ['通知中心'] = true,
      ['系统设置'] = true,
      ['Alfred'] = true,
      ['Bob'] = true,
      ['EuDic LightPeek'] = true,
      ['iStat Menus Status'] = true,
      ['Contexts'] = true,
    },
    debug = false, -- 调试输出
  },
}

-- 调试输出
function WindowAutoSwitcherV2.log(message)
  if WindowAutoSwitcherV2.config.debug then
    print(message)
  end
end

local function title(win, def)
  local t = win:title()
  if t and t ~= '' then
    return t
  else
    return def or '无标题'
  end
end

-- 检查应用是否有可见窗口
function WindowAutoSwitcherV2.hasVisibleWindows(app)
  if not app then
    return false
  end

  local windows = app:allWindows()
  local visibleCount = 0

  for _, win in ipairs(windows) do
    if win:isVisible() and not win:isMinimized() and win:isStandard() then
      visibleCount = visibleCount + 1
      WindowAutoSwitcherV2.log(string.format('  [可见窗口] %s', title(win, '')))
    end
  end

  WindowAutoSwitcherV2.log(string.format('  [统计] 可见窗口数: %d', visibleCount))

  return visibleCount > 0
end

-- 获取下一个应该聚焦的窗口
function WindowAutoSwitcherV2.getNextWindow()
  --local orderedWindows = require('mylib.utils').getOrderedWindows(true)
  local orderedWindows = hs.window.orderedWindows() -- 为了最大程度避免闪烁, 使用原版的逻辑
  return orderedWindows[1]

  -- 过滤掉最小化和不可见的窗口
  --local validWindows = {}
  --for _, win in ipairs(orderedWindows) do
  --  if win:isVisible() and not win:isMinimized() and win:isStandard() then
  --    table.insert(validWindows, win)
  --  end
  --end

  --if #validWindows > 0 then
  --  return validWindows[1]
  --end

  --return nil
end

-- 切换到下一个窗口
function WindowAutoSwitcherV2.switchToNextWindow(fromApp)
  if WindowAutoSwitcherV2.isProcessing then
    WindowAutoSwitcherV2.log('[跳过] 正在处理中')
    return
  end

  WindowAutoSwitcherV2.isProcessing = true

  local nextWindow = WindowAutoSwitcherV2.getNextWindow()

  if nextWindow then
    local nextApp = nextWindow:application():name()

    WindowAutoSwitcherV2.log(
      string.format('[自动切换] %s -> %s - %s', fromApp or '?', nextApp, title(nextWindow))
    )

    -- 聚焦窗口
    nextWindow:focus()

    -- 显示通知(可选)
    if WindowAutoSwitcherV2.config.debug then
      hs.alert.show(string.format('切换到: %s - %s', nextApp, nextWindow:title()), 1)
    end
  else
    WindowAutoSwitcherV2.log('[自动切换] 没有可用窗口')
  end

  --hs.timer.doAfter(0.3, function() WindowAutoSwitcherV2.isProcessing = false end)
  WindowAutoSwitcherV2.isProcessing = false
end

-- 处理窗口事件
function WindowAutoSwitcherV2.handleWindowEvent(window, appName, eventName)
  if not WindowAutoSwitcherV2.config.enabled then
    return
  end

  if not window then
    WindowAutoSwitcherV2.log('[事件] 窗口为空')
    return
  end

  -- 检查是否在排除列表中
  if WindowAutoSwitcherV2.config.excludeApps[appName] then
    WindowAutoSwitcherV2.log(string.format('[跳过] %s 在排除列表中', appName))
    return
  end

  WindowAutoSwitcherV2.log(
    string.format('\n[事件] %s: %s - %s', eventName, appName, title(window))
  )

  local app = window:application()
  if not app then
    WindowAutoSwitcherV2.log('[错误] 无法获取应用对象')
    return
  end

  -- 延迟检查,等待窗口状态更新
  hs.timer.doAfter(WindowAutoSwitcherV2.config.delay, function()
    WindowAutoSwitcherV2.log(string.format('[检查] %s 的窗口状态', appName))
    if not WindowAutoSwitcherV2.hasVisibleWindows(app) then
      WindowAutoSwitcherV2.log(string.format('[触发] %s 没有可见窗口', appName))
      WindowAutoSwitcherV2.switchToNextWindow(appName)
    else
      WindowAutoSwitcherV2.log(string.format('[保持] %s 仍有可见窗口', appName))
    end
  end)
end

-- 启动监听
function WindowAutoSwitcherV2.start()
  if WindowAutoSwitcherV2.filter then
    WindowAutoSwitcherV2.stop()
  end

  WindowAutoSwitcherV2.filter = hs.window.filter.new()

  WindowAutoSwitcherV2.filter:subscribe({
    hs.window.filter.windowDestroyed,
    --hs.window.filter.windowMinimized,
  }, WindowAutoSwitcherV2.handleWindowEvent)

  WindowAutoSwitcherV2.config.enabled = true

  print('✓ 窗口自动切换已启动')
end

-- 停止监听
function WindowAutoSwitcherV2.stop()
  if WindowAutoSwitcherV2.filter then
    WindowAutoSwitcherV2.filter:unsubscribeAll()
    WindowAutoSwitcherV2.filter = nil
  end

  print('✓ 窗口自动切换已停止')
end

-- 切换开关
function WindowAutoSwitcherV2.toggle()
  if WindowAutoSwitcherV2.config.enabled then
    WindowAutoSwitcherV2.config.enabled = false
    hs.alert.show('窗口自动切换: 关闭')
    print('✓ 窗口自动切换已禁用')
  else
    WindowAutoSwitcherV2.config.enabled = true
    if not WindowAutoSwitcherV2.filter then
      WindowAutoSwitcherV2.start()
    end
    hs.alert.show('窗口自动切换: 开启')
    print('✓ 窗口自动切换已启用')
  end
end

-- 添加排除应用
function WindowAutoSwitcherV2.excludeApp(appName)
  WindowAutoSwitcherV2.config.excludeApps[appName] = true
  print(string.format('✓ 已排除应用: %s', appName))
end

-- 移除排除应用
function WindowAutoSwitcherV2.includeApp(appName)
  WindowAutoSwitcherV2.config.excludeApps[appName] = nil
  print(string.format('✓ 已包含应用: %s', appName))
end

-- 切换调试模式
function WindowAutoSwitcherV2.toggleDebug()
  WindowAutoSwitcherV2.config.debug = not WindowAutoSwitcherV2.config.debug
  hs.alert.show(
    string.format('调试模式: %s', WindowAutoSwitcherV2.config.debug and '开启' or '关闭')
  )
end

-- 启动
WindowAutoSwitcherV2.start()

-- 绑定快捷键
--hs.hotkey.bind({"cmd", "alt", "ctrl"}, "A", WindowAutoSwitcherV2.toggle)
--hs.hotkey.bind({"cmd", "alt", "ctrl", "shift"}, "A", WindowAutoSwitcherV2.toggleDebug)

print('✓ WindowAutoSwitcherV2 已加载')
print('  Cmd+Alt+Ctrl+A: 切换开关')
print('  Cmd+Alt+Ctrl+Shift+A: 切换调试模式')

return WindowAutoSwitcherV2
