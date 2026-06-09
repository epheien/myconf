local M = {}

local enable_oscyank = false

local osc52 = require('mylib.osc52')

osc52.setup({
  silent = true,
  tmux_passthrough = true,
})

local function get_yankcmd()
  if vim.fn.has('mac') == 1 and vim.fn.executable('pbcopy') == 1 then
    return 'pbcopy'
  elseif
    (vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1)
    and vim.fn.executable('win32yank.exe') == 1
  then
    return 'win32yank.exe -i'
  end
  return ''
end

local function get_pastecmd()
  if vim.fn.has('mac') == 1 and vim.fn.executable('pbpaste') == 1 then
    return 'pbpaste'
  elseif
    (vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1)
    and vim.fn.executable('win32yank.exe') == 1
  then
    return 'win32yank.exe -o'
  end
  return ''
end

function M.enable_oscyank() enable_oscyank = true end

function M.disable_oscyank() enable_oscyank = false end

function M.cby()
  if vim.env.SSH_CONNECTION ~= nil or enable_oscyank then
    osc52.copy_visual()
    return
  end
  local cmd = get_yankcmd()
  if cmd == '' then
    return
  end
  vim.fn.system(cmd, vim.fn.getreg('"'))
end

function M.cbp()
  if vim.env.SSH_CONNECTION ~= nil or enable_oscyank then
    return ''
  end
  local cmd = get_pastecmd()
  if cmd == '' then
    return ''
  end
  vim.fn.setreg('"', vim.fn.system(cmd))
  return ''
end

return M
