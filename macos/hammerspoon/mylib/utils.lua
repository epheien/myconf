local M = {}

function M.getOrderedWindows(fallback, excludeApps)
  excludeApps = excludeApps or {}
  local code, resp, _ = hs.http.get('http://127.0.0.1:7749/orderedWindows') -- 22-35 ms
  if code == 200 then
    --print(resp)
    local windows = hs.json.decode(resp)
    local result = {}
    local allWindows = hs.window.allWindows()
    for _, win in ipairs(windows) do
      local found = false
      for _, hsWin in ipairs(allWindows) do
        if win.windowNumber == hsWin:id() then
          found = true
          -- 排除一些应用的特殊窗口, 例如 Sidebar 的 Settings 窗口无法正常工作
          -- Sidebar 的 Settings 窗口很奇怪, 聚焦后再调用 window:minimize() 会失效
          local appName = hsWin:application():name()
          if excludeApps[appName] then
            -- ignore
          else
            table.insert(result, hsWin)
            break
          end
        end
      end
      if not found then
        hs.alert.show(string.format('window %s not found', win.windowNumber))
        print(string.format('window not found: %s', hs.json.encode(win)))
      end
      -- 仅需要 2 个条目即可
      if #result == 2 then
        break
      end
    end
    return result
  else
    return fallback and hs.window.orderedWindows() or {}
  end
end

-- 向上遍历 UI 元素树，找到窗口元素
-- NOTE: 不一定能找到, 通常点击标题栏都能找到, 已知点击 kitty 终端内容无法获取到(显存内容?)
function M.getWindowFromElement(element)
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

-- log(msg)
-- log(fmt, a, b, c)
function M.log(...)
  local args = { ... }
  if #args == 0 then
    return
  elseif #args == 1 then
    -- 单个参数,直接打印
    print(tostring(args[1]))
  else
    -- 多个参数,第一个作为格式字符串
    local fmt = tostring(args[1])
    local params = {}

    for i = 2, #args do
      table.insert(params, args[i])
    end

    print(string.format(fmt, table.unpack(params)))
  end
end

return M
