---@diagnostic disable: unused-local

local M = {}

-- NOTE: hs.hotkey.bind() 的参数需要仔细看文档
--  - 如果 (mods, key, func), 那么 pressedfn, releasefn, repeatfn 都是 func, 可能会出现奇怪的问题
--  - 如果 (mods, key, nil, func), 那么 releasefn 为 func, 另外2个是 nil

-- ctrl+cmd+i 显示当前窗口的信息
hs.hotkey.bind({ 'cmd', 'ctrl' }, 'i', nil, function()
  local win = hs.window.focusedWindow()
  local appName = win:application():name()
  local bundleID = win:application():bundleID()
  local f = win:frame()
  local seconds = 5
  local screen = hs.screen.mainScreen()
  hs.alert.show(string.format('%s (%s)', appName, bundleID), {}, screen, seconds)
  hs.alert.show(string.format('[%s, %s, %s, %s]', f.x, f.y, f.w, f.h), {}, screen, seconds)
  hs.alert.show(hs.keycodes.currentSourceID(), {}, screen, seconds)
end)

-- 需要使用这种按键方式才能避免各种副作用
-- NOTE: 选择“输入法”菜单中的下一个输入法 这个功能在删除再添加输入法后可恢复
local function toggleInputMethod()
  --hs.eventtap.keyStroke({}, hs.keycodes.map['f17'])
  --hs.eventtap.keyStroke({"ctrl"}, "space")
  if true then
    -- 使用 capslock 键切换
    hs.eventtap.event.newSystemKeyEvent('CAPS_LOCK', true):post()
    hs.timer.usleep(10000)
    hs.eventtap.event.newSystemKeyEvent('CAPS_LOCK', false):post()
  else
    -- NOTE: 使用 ctrl-space 快捷键的话, 可能会导致按下左 cmd 的时候弹出表情输入框
    hs.eventtap.event.newKeyEvent('cmd', true):post()
    hs.timer.usleep(10000)
    hs.eventtap.event.newKeyEvent('f17', true):post()
    hs.timer.usleep(10000)
    hs.eventtap.event.newKeyEvent('f17', false):post()
    hs.timer.usleep(10000)
    hs.eventtap.event.newKeyEvent('cmd', false):post()
  end
  --hs.alert.show("Toggle Input Method")
end

-- 纳秒级别的时间戳, 基于 hs.timer.absoluteTime()
-- 这个机制主要是避免短时间连续触发, 导致连续按F18/F19的时候, 一直切换输入法
M.lastToEnTs = 0 -- ns
M.lastToZhTs = 0 -- ns
M.imSwitchThresh = 1000000000 -- 单位纳秒
M.majorVersion = 10000 -- 此版本号之后 currentSourceID() 没有任何 BUG
-- com.apple.inputmethod.SCIM.ITABC       - 自带输入法
-- com.sogou.inputmethod.sogou.pinyin     - 搜狗输入法
-- com.tencent.inputmethod.wetype.pinyin  - 微信输入法
M.zhImName = 'com.tencent.inputmethod.wetype.pinyin'
-- 切换到英文输入法
-- force: 表示使用 currentSourceID() 函数切换
local function toEnIM(force)
  local now = hs.timer.absoluteTime() -- absolute time in nanoseconds since the last system boot.
  local diff = now - M.lastToEnTs
  --print("F18", string.format('%f, %f', g_lastToEn, now))
  if diff < M.imSwitchThresh then
    --print('bypass toEnIM', diff)
    return
  end

  if hs.keycodes.currentSourceID() ~= 'com.apple.keylayout.ABC' then
    if hs.host.operatingSystemVersion().major >= M.majorVersion or force then
      hs.keycodes.currentSourceID('com.apple.keylayout.ABC')
    else
      --hs.keycodes.currentSourceID('com.apple.keylayout.ABC')
      toggleInputMethod()
    end
    M.lastToEnTs = now
    M.lastToZhTs = 0
  end
  --hs.alert.show(hs.keycodes.currentMethod())
end

-- 切换到中文输入法
local function toZhIM()
  local now = hs.timer.absoluteTime()
  local diff = now - M.lastToZhTs
  --print("F19", string.format('%f, %f', M.lastToZhTs, now))
  if diff < M.imSwitchThresh then
    --print('bypass toZhIM', diff)
    return
  end

  if hs.keycodes.currentSourceID() == 'com.apple.keylayout.ABC' then
    -- BUG: 对于第三方的输入法, 使用 currentSourceID 函数来切换的话, 会出现奇怪的问题
    if hs.host.operatingSystemVersion().major >= M.majorVersion then
      hs.keycodes.currentSourceID(M.zhImName)
    else
      --hs.keycodes.currentSourceID(M.zhImName)
      toggleInputMethod()
    end
    M.lastToZhTs = now
    M.lastToEnTs = 0
  end
  --hs.alert.show(hs.keycodes.currentSourceID())
end

M.keyBinds = {}
local function initKeyBinds()
  local function keyCode(key, modifiers)
    return function()
      hs.eventtap.event.newKeyEvent(modifiers or {}, string.lower(key), true):post()
      hs.timer.usleep(1000)
      hs.eventtap.event.newKeyEvent(modifiers or {}, string.lower(key), false):post()
    end
  end
  -- vim
  M.keyBinds['h'] = hs.hotkey.new({ 'ctrl' }, 'h', keyCode('left'), nil, keyCode('left'))
  M.keyBinds['j'] = hs.hotkey.new({ 'ctrl' }, 'j', keyCode('down'), nil, keyCode('down'))
  M.keyBinds['k'] = hs.hotkey.new({ 'ctrl' }, 'k', keyCode('up'), nil, keyCode('up'))
  M.keyBinds['l'] = hs.hotkey.new({ 'ctrl' }, 'l', keyCode('right'), nil, keyCode('right'))

  -- emacs
  M.keyBinds['b'] = hs.hotkey.new({ 'ctrl' }, 'b', keyCode('left'), nil, keyCode('left'))
  M.keyBinds['n'] = hs.hotkey.new({ 'ctrl' }, 'n', keyCode('down'), nil, keyCode('down'))
  M.keyBinds['p'] = hs.hotkey.new({ 'ctrl' }, 'p', keyCode('up'), nil, keyCode('up'))
  M.keyBinds['f'] = hs.hotkey.new({ 'ctrl' }, 'f', keyCode('right'), nil, keyCode('right'))

  --M.keyBinds['a'] = hs.hotkey.new({'ctrl'}, 'a', keyCode('home'), nil, keyCode('home'))
  --M.keyBinds['e'] = hs.hotkey.new({'ctrl'}, 'e', keyCode('end'),   nil, keyCode('end'))
  M.keyBinds['w'] =
    hs.hotkey.new({ 'ctrl' }, 'w', keyCode('delete', { 'alt' }), nil, keyCode('delete', { 'alt' }))
  M.keyBinds['u'] =
    hs.hotkey.new({ 'ctrl' }, 'u', keyCode('delete', { 'cmd' }), nil, keyCode('delete', { 'cmd' }))
end

local function enableKeyBind()
  for _, val in pairs(M.keyBinds) do
    val:enable()
  end
end

local function disableKeyBind()
  for _, val in pairs(M.keyBinds) do
    val:disable()
  end
end

local keyBindExcludeApps = {
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
  'Moonlight',
  'Remote Desktop Manager',
  'aSPICE Pro',
}

M.keyBindExcludeAppsDict = {}
for _, app in pairs(keyBindExcludeApps) do
  M.keyBindExcludeAppsDict[app] = true
end

local function initKeyBindWatcher()
  local watcher = hs.application.watcher.new(function(applicationName, eventType, application)
    if eventType == hs.application.watcher.activated then
      if M.keyBindExcludeAppsDict[applicationName] then
        --print(string.format('%s(%s) activated and disableKeyBind', applicationName, application:bundleID()))
        disableKeyBind()
        -- 只在特定 app 启用默认输入法
        toEnIM(true)
      else
        --print(string.format('%s(%s) activated and enableKeyBind', applicationName, application:bundleID()))
        enableKeyBind()
      end
    end
  end)
  watcher:start()
  return watcher
end

-- 仅打印 warning 以上的 hotkey 日志
hs.hotkey.setLogLevel(2)
initKeyBinds()
M.keyBindsWatcher = initKeyBindWatcher()
enableKeyBind()

-- 切换到英文输入法
hs.hotkey.bind({}, hs.keycodes.map['f18'], nil, function() toEnIM() end)

-- 切换到中文输入法
hs.hotkey.bind({}, hs.keycodes.map['f19'], nil, function() toZhIM() end)

-- 导出 toEnIM
hs.urlevent.bind('toEnIM', function(eventName, params) toEnIM() end)

-- 导出 toZhIM
hs.urlevent.bind('toZhIM', function(eventName, params) toZhIM() end)

local function resizeWindow(op, width, height)
  local win = hs.window.focusedWindow()
  local f = win:frame()

  if width ~= nil and width > 0 then
    if op == 'add' then
      f.w = f.w + width
    elseif op == 'sub' then
      f.w = f.w - width
    else
      f.w = width
    end
  end
  if height ~= nil and height > 0 then
    if op == 'add' then
      f.h = f.h + height
    elseif op == 'sub' then
      f.h = f.h - height
    else
      f.h = height
    end
  end
  win:setFrame(f)
end

hs.urlevent.bind('resizeWindow', function(eventName, params)
  local width = 0
  local height = 0
  local op = params['op']
  if params['width'] ~= nil then
    width = tonumber(params['width'])
  end
  if params['height'] ~= nil then
    height = tonumber(params['height'])
  end
  resizeWindow(op, width, height)
end)

hs.hotkey.bind({ 'cmd', 'alt', 'ctrl' }, 'R', nil, function() hs.reload() end)

local function openNewWindow(appName)
  local app = hs.application.get(appName)

  -- 如果应用未运行，先启动
  if not app then
    hs.application.launchOrFocus(appName)
  else
    app:activate()
    --hs.timer.usleep(100000)
    -- 尝试使用快捷键
    hs.eventtap.keyStroke({ 'cmd' }, 'n')
  end
end

-- 导出 openNewWindow
hs.urlevent.bind('openNewWindow', function(eventName, params)
  if params.app then
    openNewWindow(params.app)
  end
end)

-- @ 支持 ssh 环境下的 nvim 通过 osc52 剪切板触发切换输入法
M.lastClipboardContent = ''
M.pasteboardWatcher = hs.pasteboard.watcher
  .new(function(str)
    --print('clipboard changed: ', string.format('"%s"', str))
    if str == 'toEnIM()' then
      toEnIM()
      -- 恢复为之前的内容; 会再次进入这个函数
      hs.pasteboard.setContents(M.lastClipboardContent)
      return
    end
    M.lastClipboardContent = str
  end)
  :start()

M.modules = {}
require('mylib/window-manager').setup()
M.modules['sidebar-fixer'] = require('mylib/sidebar-fixer')
-- NOTE: 处理还是不完美, 很多不能处理的情况, 不如不改算了
--M.modules['window-fixer'] = require('mylib/window-fixer')

-- 保持住这个脚本的对象避免被垃圾回收
MyConf = M

hs.alert.show('Config of Hammerspoon loaded')

-- vim:set sts=2 sw=2 et:
