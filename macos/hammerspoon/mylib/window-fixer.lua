local M = {}

-- 向上遍历 UI 元素树，找到窗口元素
-- NOTE: 不一定能找到, 通常点击标题栏都能找到, 已知点击 kitty 终端内容无法获取到(显存内容?)
local function getWindowFromElement(element)
  local current = element
  while current do
    local role = current:attributeValue('AXRole')

    -- 找到窗口角色
    if role == 'AXWindow' then
      local win = current:asHSWindow()
      return win
    end

    -- 继续向上查找父元素
    current = current:attributeValue('AXParent')
  end
end

-- 拦截窗口关闭和最小化按钮, 模拟成 Windows 的切换逻辑
M.winButtonInterceptor = hs.eventtap.new({ hs.eventtap.event.types.leftMouseDown }, function(event)
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

    if window ~= hs.window.focusedWindow() then
      return false
    end

    -- 某些特殊窗口暂时无法处理, 例如 Hammerspoon Console
    if hs.window.orderedWindows()[1] ~= window then
      return false
    end

    --local app = window:application()
    --local appName = app:name()

    print(string.format('拦截并修改 %s 的最小化操作', window:title()))

    local nextWindow = hs.window.orderedWindows()[2]
    if not nextWindow then
      return false
    end

    nextWindow:focus()
    if Subrole == 'AXMinimizeButton' then
      window:minimize()
    else
      window:close()
    end

    return true
  end

  return false
end)

M.winButtonInterceptor:start()

-- 拦截 Cmd+M 和 Cmd+W 快捷键
minimizeKeyWatcher = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(event)
  local flags = event:getFlags()
  local keyCode = event:getKeyCode()

  if
    flags.cmd
    and not flags.shift
    and not flags.alt
    and not flags.ctrl
    and (keyCode == 46 or keyCode == 13) -- hs.keycodes.map.m => 46, hs.keycodes.map.w => 13
  then
    local window = hs.window.focusedWindow()
    if not window then
      return false
    end
    -- 某些特殊窗口暂时无法处理, 例如 Hammerspoon Console
    if hs.window.orderedWindows()[1] ~= window then
      return false
    end
    local nextWindow = hs.window.orderedWindows()[2]
    if not nextWindow then
      return false
    end

    nextWindow:focus()
    if keyCode == 46 then
      window:minimize()
    else
      window:close()
    end

    return true
  end

  return false
end)

minimizeKeyWatcher:start()

return M
