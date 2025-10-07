local M = {}

-- 将当前窗口调整为5:4比例，宽度为屏幕高度的75%，并居中
function M.resize_center()
  -- 获取当前焦点窗口
  local win = hs.window.focusedWindow()
  if not win or win:title() == "" then
    hs.alert.show('没有活动窗口')
    return
  end

  -- 获取当前屏幕
  local screen = win:screen()
  local screenFrame = screen:frame() -- LG显示器: .w = 2560, .h = 1010

  -- 计算新窗口尺寸
  -- 高度 = 屏幕高度的N%
  local newHeight = screenFrame.h * 0.8

  -- 用于 kitty.app 的经验值
  if screenFrame.h > 1000 then
    newHeight = 800
  end

  -- 宽度 = 高度 / (宽高比例)
  local newWidth = newHeight / (2 / 3)

  -- 计算居中位置
  local newX = screenFrame.x + (screenFrame.w - newWidth) / 2
  local newY = screenFrame.y + (screenFrame.h - newHeight) / 2

  -- 设置窗口的新位置和大小
  win:setFrame({
    x = newX,
    y = newY,
    w = newWidth,
    h = newHeight,
  })

  -- 显示提示信息（可选）
  hs.alert.show(string.format('窗口已调整: %.0fx%.0f', newWidth, newHeight))
end

function M.setup()
  hs.hotkey.bind({ 'option' }, 'c', M.resize_center)
end

return M
