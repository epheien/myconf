hs.hotkey.bind({"cmd", "ctrl"}, "i", function()
  local win = hs.window.focusedWindow()
  local appName = win:application():name()
  local bundleID = win:application():bundleID()
  local f = win:frame()
  local delay = 10
  hs.alert.show(appName, nil, nil, delay)
  hs.alert.show(string.format('%s %s', bundleID, f), nil, nil, delay)
end)

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

    g_keyBinds['a'] = hs.hotkey.bind({'ctrl'}, 'a', keyCode('home'), nil, keyCode('home'))
    g_keyBinds['e'] = hs.hotkey.bind({'ctrl'}, 'e', keyCode('end'),   nil, keyCode('end'))
    g_keyBinds['w'] = hs.hotkey.bind({'ctrl'}, 'w', keyCode('delete', {'alt'}), nil, keyCode('delete', {'alt'}))
    g_keyBinds['u'] = hs.hotkey.bind({'ctrl'}, 'u', keyCode('delete', {'cmd'}), nil, keyCode('delete', {'cmd'}))
  end
end

function disableKeybind()
  for _, val in pairs(g_keyBinds) do
    val:disable()
  end
end

g_disableApps = {
  '终端',
  'MacVim',
  'iTerm2',
  'iTerm',
  'Terminal',
  'Parallels Desktop',
  'gonvim',
}

g_disableApps_dict = {}
for _, app in pairs(g_disableApps) do
  g_disableApps_dict[app] = true
end
g_watchers = {}
function initDisableForApp()
  local watcher = hs.application.watcher.new(function(applicationName, eventType, application)
    if eventType == hs.application.watcher.activated then
      if g_disableApps_dict[applicationName] ~= nil then
        print('activated and disableKeybind', applicationName, application:bundleID())
        disableKeybind()
      else
        print('activated and enableKeyBind', applicationName, application:bundleID())
        enableKeyBind()
      end
    end
  end)
  watcher:start()
  g_watchers['ok'] = watcher
end

initDisableForApp()
enableKeyBind()

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "R", function()
  hs.reload()
end)
hs.alert.show("Config of Hammerspoon loaded")

-- vim:set sts=2 sw=2 et:
