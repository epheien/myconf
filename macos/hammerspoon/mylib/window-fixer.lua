local M = {}

local getOrderedWindows = function()
  --return require('mylib.utils').getOrderedWindows(false, { ['Sidebar'] = true })
  return hs.window.orderedWindows()
end
local getWindowFromElement = require('mylib.utils').getWindowFromElement

M.windowMinOrClsoeHook = function(window, isMinimized, _hotkey)
  if window ~= hs.window.focusedWindow() then
    return false
  end

  -- NOTE: 不知为何, 无法监控到微信窗口的新建和关闭事件, 只能用这个方法 hack; 1.0.0 貌似无此问题
  --if not isMinimized and window:application():name() == '微信' then
  --  if #window:application():allWindows() == 1 and window:title() == '微信' then
  --    hs.timer.doAfter(0.08, function() window:application():hide() end)
  --    return true
  --  end
  --end

  -- 暂时不处理关闭事件
  if not isMinimized then
    return false
  end

  local orderedWindows = getOrderedWindows()

  -- 某些特殊窗口暂时无法处理, 例如 Hammerspoon Console
  if orderedWindows[1] ~= window then
    return false
  end

  local nextWindow = orderedWindows[2]
  if not nextWindow then
    return false
  end

  --print(string.format('拦截修改 %s 的最小化, 激活窗口为 %s', window:title(), nextWindow:title()))

  nextWindow:focus()
  if isMinimized then
    window:minimize()
  else
    window:close()
  end

  return true
end

-- 拦截窗口关闭和最小化按钮, 模拟成 Windows 的切换逻辑
M.winButtonInterceptor = hs.eventtap.new({ hs.eventtap.event.types.leftMouseDown }, function(_event)
  local pos = hs.mouse.absolutePosition()
  local element = hs.axuielement.systemElementAtPosition(pos.x, pos.y)

  if not element then
    return false
  end

  local role = element:attributeValue('AXRole')
  if role ~= 'AXButton' then
    return false
  end
  local subrole = element:attributeValue('AXSubrole')

  -- 检测最小化按钮
  if subrole == 'AXMinimizeButton' or subrole == 'AXCloseButton' then
    local window = getWindowFromElement(element)
    if not window then
      return false
    end
    return M.windowMinOrClsoeHook(window, subrole == 'AXMinimizeButton', false)
  end

  return false
end)

M.winButtonInterceptor:start()

-- 拦截 Cmd+M 和 Cmd+W 快捷键
M.minimizeKeyWatcher = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(event)
  local flags = event:getFlags()
  local keyCode = event:getKeyCode()

  if
    flags.cmd
    and not flags.shift
    and not flags.alt
    and not flags.ctrl
    and (keyCode == 46) -- hs.keycodes.map.m => 46, hs.keycodes.map.w => 13
  then
    local window = hs.window.focusedWindow()
    if not window then
      return false
    end
    return M.windowMinOrClsoeHook(window, keyCode == 46, true)
  end

  return false
end)

M.minimizeKeyWatcher:start()

return M
