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

vim.opt.guicursor = {
  "n-v-c:block",
  "i-ci-ve:ver25",
  "r-cr:hor20",
  "o:hor50",
  "a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor",
  "sm:block-blinkwait175-blinkoff150-blinkon175",
}

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
vim.g.markdown_fenced_languages = { 'html', 'python', 'vim', 'lua', 'cpp', 'c', 'go' }
vim.g.markdown_syntax_conceal = 1

-- 设置折叠级别: 高于此级别的折叠会被关闭
vim.o.foldlevel = 10000
-- 允许光标移动到刚刚超过行尾字符之后的位置
vim.o.virtualedit = 'onemore,block'
vim.o.cc = '81,101'
vim.o.sessionoptions = 'buffers,curdir,folds,help,tabpages,winsize,localoptions'
vim.o.wildignorecase = true

-- vim -d a b 启动的时候, 不设置 'list'
if not vim.o.diff then vim.o.list = true end

vim.o.listchars = 'tab:→ ,eol:¬'
vim.o.title = true
vim.o.tagcase = 'match' -- 标签文件一般是区分大小写的
vim.o.tabline = '%!myrc#MyTabLine()'

if vim.env.TERM_PROGRAM and
    vim.regex([=[\V\<iTerm\|\<tmux\|\<kitty\|\<alacritty]=]):match_str(vim.env.TERM_PROGRAM or '') then
  vim.o.termguicolors = true
end

-- 需要导出到子环境的环境变量
vim.env.VIM_SERVERNAME = vim.v.servername
vim.env.VIM_EXE = vim.v.progpath

-- scrollview
vim.api.nvim_set_hl(0, 'ScrollView', { link = 'PmenuThumb' })
vim.g.scrollview_auto_mouse = false

vim.g.gruvbox_italic = 0  -- gruvbox 主题的斜体设置, 中文无法显示斜体, 所以不用
vim.g.mkdp_auto_close = 0 -- markdown-preview 禁止自动关闭
vim.g.asyncrun_open = 5   -- asyncrun 自动打开 quickfix

-- table-mode 兼容 markdown 表格格式
vim.g.table_mode_corner = '|'

-- gutentags
vim.cmd([[
let g:gutentags_define_advanced_commands = 1
let g:gutentags_file_list_command = 'cat gtags.files'
let g:gutentags_ctags_tagfile = 'gutags'
let g:gutentags_add_default_project_roots = 0
let g:gutentags_project_root = ['gtags.files']
let g:gutentags_auto_add_gtags_cscope = 0 " 这个必须设置为 0, 避免 nvim 报错
let g:gutentags_modules = []
if executable('ctags')
    let g:gutentags_modules += ['ctags']
endif
if executable('gtags-cscope') && executable('gtags')
    if has('nvim-0.9')
        let g:gutentags_modules += ['cscope_maps']
        let g:gutentags_cscope_executable_maps = 'gtags'
    else
        let g:gutentags_modules += ['gtags_cscope']
    endif
endif
" ctags 的一些参数
let g:gutentags_ctags_extra_args = ['--fields=+niazS', '--extra=+q']
]])

-- LeaderF
vim.cmd([[
" 长期缓存, 如保存到文件, 这样的话, 重开 vim 就不会重建缓存
let g:Lf_UseCache = 0
" 短期缓存, 会在内存缓存, 如果文件经常改动的话, 就不适合了
"let g:Lf_UseMemoryCache = 0
" 不使用版本控制机制，要的是简单粗暴直接磁盘搜索！
let g:Lf_UseVersionControlTool = 0
" Up 和 Down 使用 C-P 和 C-N
let g:Lf_CommandMap = {'<C-K>': ['<C-K>', '<Up>'], '<C-J>': ['<C-J>', '<Down>']}
if luaeval("require('utils').only_ascii()")
    let g:Lf_StlSeparator = { 'left': '', 'right': '', 'font': '' }
else
    let g:Lf_StlSeparator = { 'left': '', 'right': '', 'font': '' }
endif
let g:Lf_WindowPosition = 'popup'
]])

-- mark
vim.g.mwIgnoreCase = 0
vim.g.mwHistAdd = ''

-- vim-signature
vim.g.SignaturePeriodicRefresh = 0
vim.g.SignatureMap = {
  PlaceNextMark = "m,",
  PurgeMarks = "m<Space>",
  GotoNextSpotByPos = "<F2>",
  GotoPrevSpotByPos = "<S-F2>",
  ListBufferMarks = "m/",
}

-- NERD commenter
vim.g.NERDMenuMode = 0
vim.g.NERDCreateDefaultMappings = 0
vim.g.NERDCustomDelimiters = {
  python = {
    left = '#'
  }
}

-- neosnippet
---@diagnostic disable-next-line
vim.g['neosnippet#snippets_directory'] = vim.fs.joinpath(vim.fn.stdpath('config'), 'snippets')
-- ========== coc.nvim ==========
-- CocInstall coc-neosnippet
-- CocInstall coc-json
vim.g.coc_snippet_next = ''
vim.g.coc_snippet_prev = ''
---@diagnostic disable-next-line
vim.g.coc_data_home = vim.fs.joinpath(vim.fn.stdpath('config'), 'coc')
-- 补全后自动弹出函数参数提示
-- 一般按<CR>确认补全函数后, 会自动添加括号并让光标置于括号中
vim.cmd([[autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')]])

-- clang-format
-- NOTE: 不能指定 IndentWidth 和 UseTab, 因为插件自动设置了, 重复设置会出错!
vim.g['clang_format#code_style'] = 'llvm'
vim.g['clang_format#style_options'] = {
  AccessModifierOffset = -4,
  AllowShortFunctionsOnASingleLine = "Empty",
  AllowShortIfStatementsOnASingleLine = false,
  AlwaysBreakTemplateDeclarations = true,
  BinPackArguments = false,
  BinPackParameters = false,
  ColumnLimit = 100,
  DerivePointerAlignment = false,
  IncludeBlocks = "Preserve",
  IndentCaseLabels = false,
  PointerAlignment = "Left",
  ReflowComments = false,
  SortIncludes = true,
  SpacesBeforeTrailingComments = 1
}

local open_floating_preview = vim.lsp.util.open_floating_preview
---@diagnostic disable-next-line: duplicate-set-field
vim.lsp.util.open_floating_preview = function(contents, syntax, opts)
  local bak = vim.g.syntax_on
  vim.g.syntax_on = nil
  local floating_bufnr, floating_winnr = open_floating_preview(contents, syntax, opts)
  vim.g.syntax_on = bak
  if syntax == 'markdown' then vim.wo[floating_winnr].conceallevel = 2 end
  return floating_bufnr, floating_winnr
end

local nvim_open_win = vim.api.nvim_open_win
---@diagnostic disable-next-line: duplicate-set-field
vim.api.nvim_open_win = function(buffer, enter, config)
  if config.relative ~= '' then
    if config.title == 'Outline Status' or config.title == 'Outline Help' then
      config.border = 'none'
    end
  end
  return nvim_open_win(buffer, enter, config)
end
