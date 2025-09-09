-- NOTE: hs.hotkey.bind() 的参数需要仔细看文档
--  - 如果 (mods, key, func), 那么 pressedfn, releasefn, repeatfn 都是 func, 可能会出现奇怪的问题
--  - 如果 (mods, key, nil, func), 那么 releasefn 为 func, 另外2个是 nil
hs.hotkey.bind({"cmd", "ctrl"}, "i", nil, function()
  local win = hs.window.focusedWindow()
  local appName = win:application():name()
  local bundleID = win:application():bundleID()
  local f = win:frame()
  local delay = 10
  hs.alert.show(appName, nil, nil, delay)
  hs.alert.show(string.format('%s %s', bundleID, f), nil, nil, delay)
  hs.alert.show(hs.keycodes.currentSourceID())
end)

local g_last_clipboard_content = ''
local g_clipboard_history_write_ts = 0
local g_clipboard_history_file = io.open(os.getenv('HOME') .. '/.clipboard_history', 'a')
clipboard_watcher = hs.pasteboard.watcher.new(function(str)
  --print('clipboard changed: ', string.format('"%s"', str))
  if str == 'toEnIM()' then
    toEnIM()
    -- 恢复为之前的内容; 会再次进入这个函数
    hs.pasteboard.setContents(g_last_clipboard_content)
    return
  end
  -- 不再实现剪切板历史, 使用 Alfred 的剪切板历史即可
  --if str ~= g_last_clipboard_content and str then
  --  -- 最多保存 1000 个字符, 避免文件膨胀过快
  --  g_clipboard_history_file:write(string.sub(str, 1, 1000))
  --  g_clipboard_history_file:write("\n")
  --  g_clipboard_history_write_ts = hs.timer.absoluteTime()
  --end
  g_last_clipboard_content = str
end)
clipboard_watcher:start()

--local g_clipboard_history_flush_ts = 0
--clipboard_history_flush_timer = hs.timer.new(10, function()
--  if g_clipboard_history_write_ts > g_clipboard_history_flush_ts then
--    g_clipboard_history_file:flush()
--    g_clipboard_history_flush_ts = hs.timer.absoluteTime()
--  end
--end)
--clipboard_history_flush_timer:start()

-- hook cmd-w 快捷键的 app
local hookApps = {
  '终端',
  'MacVim',
  'iTerm2',
  'iTerm',
  'Terminal',
  'kitty',
  'Alacritty',
}

local hookAppsDict = {}
for _, app in ipairs(hookApps) do
  hookAppsDict[app] = true
end

local wf = hs.window.filter.new()
local previousWindow = nil
local focusedWindow = nil
function updateWindow(win, title)
  -- 将当前窗口保存为上一个窗口
  if win ~= focusedWindow then
    previousWindow = focusedWindow
    focusedWindow = win
    --if previousWindow ~= nil then
      --print(string.format('%s: %s(%s) => %s(%s)', title, previousWindow:application():name(), previousWindow:title(), win:application():name(), win:title()))
    --end
  end
end

--wf:subscribe(hs.window.filter.windowFocused, function(win)
--  updateWindow(win, 'Focus')
--end)

--wf:subscribe(hs.window.filter.windowVisible, function(win)
--  updateWindow(win, 'Visible')
--end)

-- NOTE: 无法用这个函数实现切换, 因为主动关闭的动作导致的事件顺序为: windowFocused => windowDestroyed
-- 这时候 previousWindow 就已经被改变了, 并且焦点 app 的其他窗口也已经弹出来了
--wf:subscribe(hs.window.filter.windowDestroyed, function(win, appName, event)
--  --hs.alert.show(string.format('[%s]:Window %s of %s occur %s event', prevWin:title(), win:title(), appName, event))
--  if previousWindow ~= nil then
--    print(string.format('previousWindow: %s(%s)', previousWindow:application():name(), previousWindow:title()))
--    previousWindow:focus()
--  end
--end)

-- 初步实现关闭窗口的时候, 切换到上一个窗口
--hs.hotkey.bind({"cmd"}, "w", function()
--  local win = hs.window.focusedWindow()
--  local prevWin = previousWindow
--  --local prevWin = hs.window.orderedWindows()[2]
--  --win:close() -- NOTE: another window of this app will popup
--
--  local tabCount = win:tabCount() or 0
--  if hookAppsDict[win:application():name()] == nil or tabCount > 1 then
--    hs.eventtap.keyStroke({'cmd'}, 'w', 200000, win:application())
--    return
--  end
--
--  --print('prevWin:', prevWin:title())
--  if prevWin ~= nil and win:application() ~= prevWin:application() then
--    prevWin:focus()
--  end
--  win:close()
--end)

--hs.hotkey.bind({"cmd"}, "m", function()
--  local win = hs.window.focusedWindow()
--  local prevWin = previousWindow
--  if prevWin ~= nil and win:application() ~= prevWin:application() then
--    prevWin:focus()
--  end
--  win:minimize()
--end)

-- 需要使用这种按键方式才能避免各种副作用
-- NOTE: 选择“输入法”菜单中的下一个输入法 这个功能在删除再添加输入法后可恢复
function toggleInputMethod()
  --hs.eventtap.keyStroke({}, hs.keycodes.map['f17'])
  --hs.eventtap.keyStroke({"ctrl"}, "space")
  if true then
    -- 使用 capslock 键切换
    hs.eventtap.event.newSystemKeyEvent('CAPS_LOCK', true):post()
    hs.timer.usleep(10000)
    hs.eventtap.event.newSystemKeyEvent('CAPS_LOCK', false):post()
  else
    -- NOTE: 使用 ctrl-space 快捷键的话, 可能会导致按下左 cmd 的时候弹出表情输入框
    hs.eventtap.event.newKeyEvent("cmd", true):post()
    hs.timer.usleep(10000)
    hs.eventtap.event.newKeyEvent("f17", true):post()
    hs.timer.usleep(10000)
    hs.eventtap.event.newKeyEvent("f17", false):post()
    hs.timer.usleep(10000)
    hs.eventtap.event.newKeyEvent("cmd", false):post()
  end
  --hs.alert.show("Toggle Input Method")
end

-- 纳秒级别的时间戳, 基于 hs.timer.absoluteTime()
-- 这个机制主要是避免短时间连续触发, 导致连续按F18/F19的时候, 一直切换输入法
local g_lastToEn = 0
local g_lastToZh = 0
local g_IMThresh = 1000000000 -- 单位纳秒
local g_major = 10000 -- 此版本号之后 currentSourceID() 没有任何 BUG
-- com.apple.inputmethod.SCIM.ITABC       - 自带输入法
-- com.sogou.inputmethod.sogou.pinyin     - 搜狗输入法
-- com.tencent.inputmethod.wetype.pinyin  - 微信输入法
local g_zh_im_name = 'com.tencent.inputmethod.wetype.pinyin'
-- 切换到英文输入法
-- force: 表示使用 currentSourceID() 函数切换
function toEnIM(force)
  local now = hs.timer.absoluteTime()
  local diff = now - g_lastToEn
  --print("F18", string.format('%f, %f', g_lastToEn, now))
  if diff < g_IMThresh then
    --print('bypass toEnIM', diff)
    return
  end

  if (hs.keycodes.currentSourceID() ~= 'com.apple.keylayout.ABC') then
    if hs.host.operatingSystemVersion().major >= g_major or force then
      hs.keycodes.currentSourceID('com.apple.keylayout.ABC')
    else
      --hs.keycodes.currentSourceID('com.apple.keylayout.ABC')
      toggleInputMethod()
    end
    g_lastToEn = now
    g_lastToZh = 0
  end
  --hs.alert.show(hs.keycodes.currentMethod())
end

-- 切换到中文输入法
function toZhIM()
  local now = hs.timer.absoluteTime()
  local diff = now - g_lastToZh
  --print("F19", string.format('%f, %f', g_lastToZh, now))
  if diff < g_IMThresh then
    --print('bypass toZhIM', diff)
    return
  end

  if (hs.keycodes.currentSourceID() == 'com.apple.keylayout.ABC') then
    -- BUG: 对于第三方的输入法, 使用 currentSourceID 函数来切换的话, 会出现奇怪的问题
    if hs.host.operatingSystemVersion().major >= g_major then
      hs.keycodes.currentSourceID(g_zh_im_name)
    else
      --hs.keycodes.currentSourceID(g_zh_im_name)
      toggleInputMethod()
    end
    g_lastToZh = now
    g_lastToEn = 0
  end
  --hs.alert.show(hs.keycodes.currentSourceID())
end

g_keyBinds = {}
function enableKeyBind()
  local function keyCode(key, modifiers)
    modifiers = modifiers or {}

    return function()
        hs.eventtap.event.newKeyEvent(modifiers, string.lower(key), true):post()
        hs.timer.usleep(1000)
        hs.eventtap.event.newKeyEvent(modifiers, string.lower(key), false):post()
    end
  end
  if _G.next(g_keyBinds) ~= nil then
    for _, val in pairs(g_keyBinds) do
      val:enable()
    end
  else
    -- vim
    g_keyBinds['h'] = hs.hotkey.bind({'ctrl'}, 'h', keyCode('left'),  nil, keyCode('left'))
    g_keyBinds['j'] = hs.hotkey.bind({'ctrl'}, 'j', keyCode('down'),  nil, keyCode('down'))
    g_keyBinds['k'] = hs.hotkey.bind({'ctrl'}, 'k', keyCode('up'),    nil, keyCode('up'))
    g_keyBinds['l'] = hs.hotkey.bind({'ctrl'}, 'l', keyCode('right'), nil, keyCode('right'))

    -- emacs
    g_keyBinds['b'] = hs.hotkey.bind({'ctrl'}, 'b', keyCode('left'),  nil, keyCode('left'))
    g_keyBinds['n'] = hs.hotkey.bind({'ctrl'}, 'n', keyCode('down'),  nil, keyCode('down'))
    g_keyBinds['p'] = hs.hotkey.bind({'ctrl'}, 'p', keyCode('up'),    nil, keyCode('up'))
    g_keyBinds['f'] = hs.hotkey.bind({'ctrl'}, 'f', keyCode('right'), nil, keyCode('right'))

    --g_keyBinds['a'] = hs.hotkey.bind({'ctrl'}, 'a', keyCode('home'), nil, keyCode('home'))
    --g_keyBinds['e'] = hs.hotkey.bind({'ctrl'}, 'e', keyCode('end'),   nil, keyCode('end'))
    g_keyBinds['w'] = hs.hotkey.bind({'ctrl'}, 'w', keyCode('delete', {'alt'}), nil, keyCode('delete', {'alt'}))
    g_keyBinds['u'] = hs.hotkey.bind({'ctrl'}, 'u', keyCode('delete', {'cmd'}), nil, keyCode('delete', {'cmd'}))
  end
end

function disableKeybind()
  for _, val in pairs(g_keyBinds) do
    val:disable()
  end
end

local g_disableApps = {
  '终端',
  'MacVim',
  'iTerm2',
  'iTerm',
  'Terminal',
  'Parallels Desktop',
  'VMware Fusion',
  'gonvim',
  'VimR',
  'Royal TSX',
  'Neovim',
  'TeamViewer',
  '屏幕共享',
  'Emacs',
  'Code', -- vscode
  'Oni',
  'goneovim',
  'kitty',
  'Alacritty',
  'Ghostty',
  'Neovide',
  'NoMachine',
  'WezTerm',
  'UTM',
  "Moonlight",
}

local g_disableApps_dict = {}
for _, app in pairs(g_disableApps) do
  g_disableApps_dict[app] = true
end

function isInDisableApp()
  local win = hs.window.focusedWindow()
  local appName = win:application():name()
  return g_disableApps_dict[appName] ~= nil
end

g_watchers = {}
function initDisableForApp()
  local watcher = hs.application.watcher.new(function(applicationName, eventType, application)
    if eventType == hs.application.watcher.activated then
      if g_disableApps_dict[applicationName] ~= nil then
        --print('activated and disableKeybind', applicationName, application:bundleID())
        disableKeybind()
        -- 只在特定 app 启用默认输入法
        toEnIM(true)
      else
        --print('activated and enableKeyBind', applicationName, application:bundleID())
        enableKeyBind()
      end
    end
  end)
  watcher:start()
  g_watchers['ok'] = watcher
end

-- 仅打印 warning 以上的 hotkey 日志
hs.hotkey.setLogLevel(2)
initDisableForApp()
enableKeyBind()

-- 切换到英文输入法
hs.hotkey.bind({}, hs.keycodes.map["f18"], nil, function()
  toEnIM()
end)

-- 切换到中文输入法
hs.hotkey.bind({}, hs.keycodes.map["f19"], nil, function()
  toZhIM()
end)

hs.urlevent.bind('toEnIM', function(eventName, params)
  toEnIM()
end)

hs.urlevent.bind('toZhIM', function(eventName, params)
  toZhIM()
end)

function resizeWindow(op, width, height)
  local win = hs.window.focusedWindow()
  local f = win:frame()

  if (width ~= nil and width > 0) then
    if (op == 'add') then
      f.w = f.w + width
    elseif (op == 'sub') then
      f.w = f.w - width
    else
      f.w = width
    end
  end
  if (height ~= nil and height > 0) then
    if (op == 'add') then
      f.h = f.h + height
    elseif (op == 'sub') then
      f.h = f.h - height
    else
      f.h = height
    end
  end
  win:setFrame(f)
end

hs.urlevent.bind("resizeWindow", function(eventName, params)
  local width = 0
  local height = 0
  local op = params['op']
  if (params['width'] ~= nil) then
    width = tonumber(params['width'])
  end
  if (params['height'] ~= nil) then
    height = tonumber(params['height'])
  end
  resizeWindow(op, width, height)
end)

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "R", nil, function()
  hs.reload()
end)

require('mylib/window-manager').setup()

hs.alert.show("Config of Hammerspoon loaded")

-- vim:set sts=2 sw=2 et:
