-- NOTE: 这里的键位绑定比 lazy 的插件配置加载之后, 也就是可能会覆盖 lazy 设置的绑定

local function map(mode, lhs, rhs, opts)
  -- defaults: remap = false
  local options = { silent = true }
  if opts then
    options = vim.tbl_deep_extend('force', options, opts)
  end
  vim.keymap.set(mode, lhs, rhs, options)
end

local nosilent = { silent = false }

map('n', 'j', 'gj')
map('n', 'k', 'gk')

map('n', '<RightRelease>', function() vim.cmd('call myrc#ContextPopup(1)') end)

-- 禁用这些鼠标的点击
map('n', '<RightMouse>', '<Nop>')
map('n', '<3-LeftMouse>', '<Nop>')
map('n', '<3-LeftMouse>', '<Nop>')
map('n', '<4-LeftMouse>', '<Nop>')
map('n', '<4-LeftMouse>', '<Nop>')

-- <CR> 来重复上一条命令，10秒内连续 <CR> 的话，无需确认
--map('n', '<CR>', function() vim.call('myrc#MyEnter') end)

map('i', '<Tab>', function() vim.call('myrc#SuperTab') end)
map('i', '<S-Tab>', function() vim.call('myrc#ShiftTab') end)

map('n', '<C-f>', function() vim.call('mydict#Search', vim.fn.expand('<cword>')) end)

map('n', '<C-f>', function() vim.call('mydict#Search', vim.fn.expand('<cword>')) end)
map('v', '<C-f>', 'y:call mydict#Search(@")<CR>')

map('n', '<C-]>', function() vim.call('myrc#Cstag') end)

map('n', '<M-h>', ':tabNext<CR>')
map('n', '<M-l>', ':tabnext<CR>')
map('n', '<M-j>', '<C-w>-')
map('n', '<M-k>', '<C-w>+')

-- Terminal mode mappings
map('t', '<M-h>', '<C-\\><C-n>:tabNext<CR>')
map('t', '<M-l>', '<C-\\><C-n>:tabnext<CR>')

-- Insert mode mappings
map('i', '<M-h>', '<C-\\><C-o>:tabNext<CR>')
map('i', '<M-l>', '<C-\\><C-o>:tabnext<CR>')

-- 最常用的复制粘贴
map('v', '<C-x>', '""x:call myrc#cby()<CR>')
map('v', '<C-c>', '""y:call myrc#cby()<CR>')
map('v', '<C-v>', '"_d:<C-u>call myrc#cbp()<CR>""gP')
map('n', '<C-v>', ':call myrc#cbp()<CR>""gP')
map(
  'i',
  '<C-v>',
  '<C-r>=myrc#prepIpaste()<CR><C-r>=myrc#cbp()<CR><C-r>"<C-r>=myrc#postIpaste()<CR>'
)
map('c', '<C-v>', '<C-r>=myrc#cbp()<CR><C-r>=myrc#_paste()<CR>')
map('t', '<C-v>', '<C-w>:call myrc#cbp()<CR><C-w>""')

-- Resize columns
map('n', '\\-', ':set columns-=30<CR>')
map('n', '\\=', ':set columns+=30<CR>')

-- Buffer delete
map('n', '\\d', ':call myrc#n_BufferDelete()<CR>')

-- Change local directory to file's directory
map('n', '\\h', ':lcd %:p:h <Bar> pwd<CR>', nosilent)

-- Save session
map('n', '\\]', ':mksession! vimp.vim<CR>', nosilent)

-- Scroll down
map('n', '<Space>', '3<C-e>')

-- Scroll up
map('n', ',', '3<C-y>')

-- Window navigation
map('n', '<C-h>', '<C-w>h')
map('n', '<C-j>', '<C-w>j')
map('n', '<C-k>', '<C-w>k')
map('n', '<C-l>', '<C-w>l')

-- Remap ; to :
map('n', ';', ':', { remap = true, silent = false })

-- Close window
map('n', 'gq', ':call myrc#close()<CR>')

map('n', 'T', function() vim.cmd.tag() end)

-- 交换 ' 和 `，因为 ` 比 ' 常用但太远
map('n', '\'', '`')
map('n', '`', '\'')
-- quickfix 跳转
map('n', ']q', ':cn<CR>')
map('n', '[q', ':cp<CR>')
-- diagnostic 跳转 (包装成函数避免初始化的时候载入 vim.diagnostic 模块)
map('n', ']w', function() return vim.diagnostic.goto_next() end)
map('n', '[w', function() return vim.diagnostic.goto_prev() end)

-- stty -ixon
map('n', '<C-s>', function()
  if vim.g.termdbg_running == 1 then
    vim.cmd('TStep')
  else
    vim.cmd.update()
  end
end)

-- 终端模拟器键位绑定
map('t', '<C-y><C-y>', '<C-\\><C-n>')
map('t', '<C-\\><C-\\>', '<C-\\><C-n>')
map('t', '<C-\\>:', '<C-\\><C-n>:')
map('t', '<C-h>', '<C-\\><C-n><C-w>h')
map('t', '<C-j>', '<C-\\><C-n><C-w>j')
map('t', '<C-k>', '<C-\\><C-n><C-w>k')
map('t', '<C-l>', '<C-\\><C-n><C-w>l')
map('t', '<C-v>', '<C-\\><C-n>"+pa')

-- 命令行模式，包括搜索时
map('c', '<C-h>', '<Left>', nosilent)
map('c', '<C-j>', '<Down>', nosilent)
map('c', '<C-k>', '<Up>', nosilent)
map('c', '<C-l>', '<Right>', nosilent)
map('c', '<C-b>', '<Left>', nosilent)
map('c', '<C-f>', '<Right>', nosilent)
map('c', '<C-a>', '<Home>', nosilent)
map('c', '<C-d>', '<Del>', nosilent)

map('v', '<C-s>', '<C-c>:update<CR>')
map('v', '$', '$h')
map('s', '<BS>', '<BS>i')

map('x', ';', ':', { silent = false })
map('x', '<Space>', '3j')
map('x', ',', '3k')
map('x', '(', 'di()<ESC>Pl')
map('x', '[', 'di[]<ESC>Pl')
map('x', '{', 'di{}<ESC>Pl')
map('x', '\'', 'di\'\'<ESC>Pl')
map('x', '"', 'di""<ESC>Pl')
-- C 文件的 #if 0 段落注释
map('x', '0', '<C-c>:call myrc#MacroComment()<CR>')

map('n', '\\f', ':Telescope find_files<CR>')
map('n', '\\e', ':Leaderf cmdHistory --regexMode<CR>')
map('n', '\\b', ':Telescope buffers<CR>')
map('n', '\\t', ':Leaderf bufTag<CR>')
map('n', '\\T', ':Telescope tags<CR>')
map('n', '\\g', ':Telescope tags<CR>')
map('n', '\\/', ':Telescope current_buffer_fuzzy_find<CR>')

map('i', '<C-h>', '<Left>', { remap = true })
map('i', '<C-j>', '<Down>', { remap = true })
map('i', '<C-k>', '<Up>', { remap = true })
map('i', '<C-l>', '<Right>', { remap = true })
map('i', '<C-b>', '<Left>', { remap = true })
map('i', '<C-f>', '<Right>', { remap = true })
map('i', '<C-p>', '<Up>', { remap = true })
map('i', '<C-n>', '<Down>', { remap = true })

map('i', '<C-s>', '<ESC>:update<CR>')
map('i', '<C-o>', '<End><CR>')
-- 不能使用 <C-\><C-o>O, 因为可能会导致多余的缩进
map('i', '<C-z>', '<Esc>O')
map('i', '<C-a>', '<Home>')
map('i', '<C-d>', '<Del>')

map('x', '<C-n>', '<Plug>NERDCommenterToggle', { remap = true })
map('n', '<C-n>', function()
  if vim.g.termdbg_running == 1 then
    vim.cmd('TNext')
  else
    vim.cmd('NERDCommenter') -- load NERDCommenter by pckr.nvim
    local key = vim.api.nvim_replace_termcodes('<Plug>NERDCommenterToggle', true, false, true)
    vim.api.nvim_feedkeys(key, 'm', false)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Down>', true, false, true), 'n', false)
  end
end, { remap = true })

-- termdbg
map('n', '<C-p>', [[:exec 'TSendCommand p' expand('<cword>')<CR>]])
map('v', '<C-p>', [[y:exec 'TSendCommand p' @"<CR>]])
-- 参考 magic keyboard 的媒体按键, F8 暂停用于 step, F9 下一曲用于 next
map('n', '<F9>', ':TNext<CR>')
map('n', '<F8>', ':TStep<CR>')
-- 快捷键来自 vscode 的调试器
map('n', '<F10>', ':TNext<CR>')
map('n', '<F11>', ':TStep<CR>')

map({ 'n', 'x' }, [[\\]], '<Plug>MarkSet', { remap = true })
map('n', [[\c]], ':noh<CR><Plug>MarkAllClear', { remap = true })
map('n', '*', '<Plug>MarkSearchCurrentNext', { remap = true })
map('n', '#', '<Plug>MarkSearchCurrentPrev', { remap = true })
map('n', '<Leader>*', '<Plug>MarkSearchNext', { remap = true })
map('n', '<Leader>#', '<Plug>MarkSearchPrev', { remap = true })
map('n', '<2-LeftMouse>', function() vim.call('myrc#MouseMark') end)

local cscmd = 'Cs'
map(
  'n',
  '<C-\\>s',
  string.format(':%s find s <C-R>=fnameescape(expand(\'<cword>\'))<CR><CR>', cscmd)
)
map(
  'n',
  '<C-\\>g',
  string.format(':%s find g <C-R>=fnameescape(expand(\'<cword>\'))<CR><CR>', cscmd)
)
map(
  'n',
  '<C-\\>c',
  string.format(':%s find c <C-R>=fnameescape(expand(\'<cword>\'))<CR><CR>', cscmd)
)
map(
  'n',
  '<C-\\>t',
  string.format(':%s find t <C-R>=fnameescape(expand(\'<cword>\'))<CR><CR>', cscmd)
)
map(
  'n',
  '<C-\\>e',
  string.format(':%s find e <C-R>=fnameescape(expand(\'<cword>\'))<CR><CR>', cscmd)
)
map(
  'n',
  '<C-\\>f',
  string.format(':%s find f <C-R>=fnameescape(expand(\'<cfile>\'))<CR><CR>', cscmd)
)
map(
  'n',
  '<C-\\>i',
  string.format(':%s find i ^<C-R>=fnameescape(expand(\'<cfile>\'))<CR>$<CR>', cscmd)
)
map(
  'n',
  '<C-\\>d',
  string.format(':%s find d <C-R>=fnameescape(expand(\'<cword>\'))<CR><CR>', cscmd)
)
map(
  'n',
  '<C-\\>a',
  string.format(':%s find a <C-R>=fnameescape(expand(\'<cword>\'))<CR><CR>', cscmd)
)

map('n', 'K', function() vim.call('myrc#ShowDocumentation') end)

map('i', '<C-g>', '<C-r>=myrc#i_InsertHGuard()<CR>', nosilent)
map('i', '<CR>', function() vim.call('myrc#SmartEnter') end)

map('i', '<C-e>', 'myrc#i_CTRL_E()', { expr = true })
-- 切换光标前的单词的大小写
map('i', '<C-y>', [=[pumvisible()?"\<C-y>":"\<C-r>=myrc#ToggleCase()\<CR>"]=], { expr = true })

-- 选择后立即搜索
map(
  'x',
  '/',
  [[y:let @" = substitute(@", '\\', '\\\\', "g")<CR>:let @" = substitute(@", '\/', '\\\/', "g")<CR>/\V<C-r>"<CR>N]]
)

map('i', ';', function()
  local line = vim.api.nvim_get_current_line()
  local pos = vim.api.nvim_win_get_cursor(0)
  if
    not vim.regex([[^\s*for\>]]):match_str(line or '')
    and string.sub(line, pos[2] + 1, pos[2] + 1) == ')'
  then
    return '<Right>;'
  else
    return ';'
  end
end, { expr = true })

-- 未用到
--vim.cmd([[
--for n in ['', 'l', 't']
--  for i in range(13, 24)
--    execute printf('%smap <F%s> <S-F%s>', n, i, i-12)
--  endfor
--endfor
--]])

-- 增强 <C-g> 显示的信息 {{{
vim.keymap.set('n', '<C-g>', function()
  local msg_list = {}
  local fname = vim.fn.expand('%:p')
  table.insert(msg_list, fname ~= '' and fname or vim.api.nvim_eval_statusline('%f', {}).str)
  if vim.api.nvim_eval_statusline('%w', {}).str ~= '' then
    table.insert(msg_list, vim.api.nvim_eval_statusline('%w', {}).str)
  end
  if vim.o.readonly then
    table.insert(msg_list, '[RO]')
  end
  if vim.o.filetype ~= '' then
    table.insert(msg_list, string.format('[%s]', vim.o.filetype))
  end
  if vim.o.fileformat ~= '' then
    table.insert(msg_list, string.format('[%s]', vim.o.fileformat))
  end
  if vim.o.fileencoding ~= '' then
    table.insert(msg_list, string.format('[%s]', vim.o.fileencoding))
  end
  if fname ~= '' and vim.fn.filereadable(fname) == 1 then
    table.insert(msg_list, vim.fn.strftime('%Y-%m-%d %H:%M:%S', vim.fn.getftime(fname)))
  end
  vim.cmd.echo(vim.fn.string(vim.fn.join(msg_list, ' ')))

  if vim.g.outline_loaded == 1 then
    local outline = require('outline') ---@diagnostic disable-line: different-requires
    if outline.is_open() then
      outline.follow_cursor({ focus_outline = false })
    end
  end
end)
-- }}}

-- vim:set fdm=marker fen fdl=0:
