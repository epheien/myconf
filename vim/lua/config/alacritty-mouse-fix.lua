-- 手动修正 Alacritty 终端模拟器鼠标点击时, 光标仍然闪烁的问题
local inited_on_key = false
local stop_on_key = false
local cursor_blinkon_opt = { "n-v-c:block", "i-ci-ve:ver25", "r-cr:hor20", "o:hor50",
  "a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor", "sm:block-blinkwait175-blinkoff150-blinkon175" }
local cursor_blinkoff_opt = { "n-v-c:block", "i-ci-ve:ver25", "r-cr:hor20", "o:hor50",
  "a:Cursor/lCursor", "sm:block-blinkwait175-blinkoff150-blinkon175" }
local setup_on_key = function()
  if inited_on_key then
    stop_on_key = false
    return
  end
  inited_on_key = true
  local prs = vim.keycode("<LeftMouse>")
  local rel = vim.keycode("<LeftRelease>")
  vim.on_key(function(k)
    if stop_on_key then
      return
    end
    if k == prs then
      vim.opt.guicursor = cursor_blinkoff_opt
    elseif k == rel then
      vim.opt.guicursor = cursor_blinkon_opt
    end
  end)
end
vim.api.nvim_create_user_command('FixMouseClick', function() setup_on_key() end, { nargs = 0 })
vim.api.nvim_create_user_command('StopFixMouseClick', function()
  stop_on_key = true
  vim.opt.guicursor = cursor_blinkon_opt
end, { nargs = 0 })
-- 暂时所知仅 Alacritty 需要修正
local TERM_PROGRAM = os.getenv('TERM_PROGRAM')
if not (TERM_PROGRAM == 'kitty' or TERM_PROGRAM == 'iTerm' or
      TERM_PROGRAM == 'Apple_Terminal' or vim.fn.has('gui_running') == 1) then
  setup_on_key()
end
