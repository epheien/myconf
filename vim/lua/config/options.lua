-- 由于安全原因, 直接禁用 modeline, 使用 securemodelines 替代
vim.o.modeline = false
-- 不强制在末尾添加换行符，兼容其他编辑器的行为
--vim.o.fixendofline = false
-- 主要是实现自动对齐大括号的缩进
vim.o.smartindent = true
vim.o.cindent = true
-- L0 - 输入 std: 的时候禁止缩进, 避免频繁的光标跳动
vim.opt.cinoptions:append({ '(0', 'Ws', 'L0', ':0', 'l1' })
vim.o.rulerformat = '%l/%L,%v'
--vim.cmd.syntax('on')
-- 扩大正则使用的内存, 至少 20MiB
vim.o.maxmempattern = 20000
-- 文件类型的检测
-- 为特定的文件类型允许插件文件的载入
-- 为特定的文件类型载入缩进文件
-- 这个命令触发载入 $VIMRUNTIME/filetype.vim
vim.cmd('filetype plugin indent on')
vim.o.number = true
vim.o.signcolumn = 'auto:9'
vim.o.fileencodings = 'utf-8,gbk,gb18030,ucs-bom,utf-16,cp936'
vim.o.fileformat = 'unix'
vim.o.fileformats = 'unix,dos'
vim.o.ignorecase = true
vim.o.smartcase = true
vim.opt.jumpoptions:append({ 'stack', 'view' })
-- nvim 没有删除对话框选项, 直接禁用算了
vim.o.swapfile = false
vim.o.mouse = 'a'

-- 缩进相关
vim.o.softtabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true

vim.o.selectmode = 'key'
vim.o.keymodel = 'startsel,stopsel'

vim.o.completeopt = 'menuone,noinsert'
vim.o.pumheight = 5

vim.g.mapleader = vim.api.nvim_replace_termcodes('<F12>', true, false, true)
-- 设置 vim 脚本的续行缩进
vim.g.vim_indent_cont = vim.fn.shiftwidth()
-- shell 文件格式语法类型默认为 bash
vim.g.is_bash = 1
-- 禁用 vim 文件类型的错误
vim.g.vimsyn_noerror = 1
-- 使用增强的 python 语法高亮的所有功能
vim.g.python_highlight_all = 1
-- 禁用很慢的语法
vim.g.python_slow_sync = 0
-- 对于 lisp，使用彩虹高亮括号匹配
vim.g.lisp_rainbow = 1
-- 基于 syntax 的 markdown 代码块高亮可用的语言类型
vim.g.markdown_fenced_languages = {'html', 'python', 'vim', 'lua', 'cpp', 'c', 'go'}
vim.g.markdown_syntax_conceal = 1

-- 设置折叠级别: 高于此级别的折叠会被关闭
vim.o.foldlevel = 10000
-- 允许光标移动到刚刚超过行尾字符之后的位置
vim.o.virtualedit = 'onemore,block'
vim.o.cc = '81,101'
vim.o.sessionoptions = 'buffers,curdir,folds,help,localoptions,tabpages,winsize,resize,terminal'
vim.o.wildignorecase = true

-- vim -d a b 启动的时候, 不设置 'list'
if not vim.o.diff then vim.o.list = true end

vim.o.listchars = 'tab:→ ,eol:¬'
vim.o.title = true
vim.o.tagcase = 'match' -- 标签文件一般是区分大小写的
vim.o.tabline = '%!myrc#MyTabLine()'

if vim.env.TERM_PROGRAM and
    vim.regex([=[\V\<iTerm\|\<tmux\|\<kitty\|\<alacritty]=]):match_str(vim.env.TERM_PROGRAM) then
  vim.o.termguicolors = true
end

-- 需要导出到子环境的环境变量
vim.env.VIM_SERVERNAME = vim.v.servername
vim.env.VIM_EXE = vim.v.progpath

-- scrollview
vim.api.nvim_set_hl(0, 'ScrollView', { link = 'PmenuThumb' })
vim.g.scrollview_auto_mouse = false

vim.g.gruvbox_italic = 0    -- gruvbox 主题的斜体设置, 中文无法显示斜体, 所以不用
vim.g.mkdp_auto_close = 0   -- markdown-preview 禁止自动关闭
vim.g.asyncrun_open = 5     -- asyncrun 自动打开 quickfix
