-- 自用全局变量 `package_manager` `nodashboard` `my_colors_name`
-- pckr or lazy
vim.g.package_manager = 'lazy'
vim.g.my_colors_name = 'gruvbox' -- gruvbox | catppuccin

---@type string
local config_path = vim.fn.stdpath('config') ---@diagnostic disable-line
local loop = vim.uv or vim.loop

-- 非 macOS 系统, 可能会缺少一些插件, 改用 pckr.nvim, 因为 pckr.nvim 不报错
if
  vim.fn.has('mac') ~= 1
  and vim.g.package_manager == 'lazy'
  and not loop.fs_stat(config_path .. '/pack/pckr/opt/vimcdoc') ---@diagnostic disable-line
then
  vim.g.package_manager = 'pckr'
end

require('config.options')
require('config.autocmds')

local function load_config()
  require('config.keymaps')
  require('config.commands')

  require('config.float-help')
  require('config.mystl')
  require('config.alacritty-mouse-fix')
end

if vim.g.package_manager == 'lazy' then
  vim.api.nvim_create_autocmd('User', {
    pattern = 'VeryLazy',
    once = true,
    callback = load_config,
  })
else
  load_config()
end

-- 使用 packadd 加载 pckr.nvim
--  $ mkdir -pv ~/.config/nvim/pack/pckr/opt/
--  $ git clone --filter=blob:none https://github.com/epheien/pckr.nvim.git ~/.config/nvim/pack/pckr/opt/pckr.nvim
vim.opt.packpath:append(vim.fn.stdpath('config'))
---@diagnostic disable-next-line
local path = vim.fs.joinpath(
  config_path,
  'pack',
  'pckr',
  'opt',
  string.format('%s.nvim', vim.g.package_manager)
)
local msg = ''
if vim.g.package_manager == 'lazy' then
  msg = string.format(
    'Failed to init lazy.nvim, '
      .. 'try to run `git clone --filter=blob:none --branch=stable '
      .. 'https://github.com/folke/lazy.nvim.git %s`',
    path
  )
else
  msg = string.format(
    'Failed to init pckr.nvim, '
      .. 'try to run `git clone --filter=blob:none '
      .. 'https://github.com/epheien/pckr.nvim.git %s`',
    path
  )
end
assert((vim.uv or vim.loop).fs_stat(path), msg) ---@diagnostic disable-line
vim.opt.rtp:prepend(path)

vim.api.nvim_create_autocmd('ColorScheme', {
  -- 修改一些插件的高亮组, 需要插件初始化的时候用了 default 属性
  callback = function(event) ---@diagnostic disable-line
    if vim.g.colors_name == 'gruvbox' then
      -- 这个配色默认情况下，字符串和函数共用一个配色，要换掉！
      vim.api.nvim_set_hl(0, 'String', { link = 'Constant' })
      -- 终端下的光标颜色貌似不受主题的控制，受制于终端自身的设置
      vim.api.nvim_set_hl(0, 'Cursor', {})
      vim.api.nvim_set_hl(0, 'Cursor', { fg = 'black', bg = 'yellow', ctermfg = 16, ctermbg = 226 })
      vim.api.nvim_set_hl(0, 'Todo', {})
      -- stylua: ignore
      vim.api.nvim_set_hl(0, 'Todo', { fg = 'orangered', bg = 'yellow2', ctermfg = 202, ctermbg = 226 })

      vim.api.nvim_set_hl(0, 'Search', {})
      -- stylua: ignore
      vim.api.nvim_set_hl(0, 'Search', { fg = 'gray80', bg = '#445599', ctermfg = 252, ctermbg = 61 })
      vim.api.nvim_set_hl(0, 'Directory', { fg = '#8094b4', bold = true })
      vim.api.nvim_set_hl(0, 'FoldColumn', { bg = 'NONE', ctermbg = 'NONE' })

      -- tagbar 配色
      vim.api.nvim_set_hl(0, 'TagbarAccessPublic', { link = 'GruvboxAqua' })
      vim.api.nvim_set_hl(0, 'TagbarAccessProtected', { link = 'GruvboxPurple' })
      vim.api.nvim_set_hl(0, 'TagbarAccessPrivate', { link = 'GruvboxRed' })
      vim.api.nvim_set_hl(0, 'TagbarSignature', { link = 'Normal' })
      vim.api.nvim_set_hl(0, 'TagbarKind', { link = 'Constant' })

      vim.api.nvim_set_hl(0, 'CurSearch', { link = 'Search' })
      vim.api.nvim_set_hl(0, 'FloatBorder', { link = 'WinSeparator' })
      vim.api.nvim_set_hl(0, 'SpecialKey', { link = 'Special' })
      vim.api.nvim_set_hl(0, 'SignColumn', { bg = 'NONE', ctermbg = 'NONE' })

      -- GitGutter
      vim.api.nvim_set_hl(0, 'GitGutterAdd', { link = 'GruvboxGreen' })
      vim.api.nvim_set_hl(0, 'GitGutterChange', { link = 'GruvboxAqua' })
      vim.api.nvim_set_hl(0, 'GitGutterDelete', { link = 'GruvboxRed' })
      vim.api.nvim_set_hl(0, 'GitGutterChangeDelete', { link = 'GruvboxYellow' })

      -- Signature
      vim.api.nvim_set_hl(0, 'SignatureMarkText', { link = 'GruvboxBlue' })
      vim.api.nvim_set_hl(0, 'SignatureMarkerText', { link = 'GruvboxPurple' })

      -- edgy.nvim
      vim.api.nvim_set_hl(0, 'EdgyNormal', { link = 'Normal' })
      -- scrollview
      vim.api.nvim_set_hl(0, 'ScrollView', { link = 'PmenuThumb' })
      vim.api.nvim_set_hl(0, 'ScrollViewDiagnosticsHint', { link = 'DiagnosticHint' })
      vim.api.nvim_set_hl(0, 'ScrollViewDiagnosticsInfo', { link = 'DiagnosticInfo' })
      vim.api.nvim_set_hl(0, 'ScrollViewDiagnosticsWarn', { link = 'DiagnosticWarn' })
      vim.api.nvim_set_hl(0, 'ScrollViewDiagnosticsError', { link = 'DiagnosticError' })
      vim.api.nvim_set_hl(0, 'ScrollViewHover', { link = 'PmenuSel' })
      vim.api.nvim_set_hl(0, 'ScrollViewRestricted', { link = 'ScrollView' })
      -- telescope
      vim.api.nvim_set_hl(0, 'TelescopeBorder', { link = 'WinSeparator', force = true })
      vim.api.nvim_set_hl(0, 'TelescopeTitle', { link = 'Title', force = true })
      vim.api.nvim_set_hl(0, 'TelescopeSelection', { link = 'CursorLine' })
      -- nvim-cmp
      vim.api.nvim_set_hl(0, 'CmpItemAbbrMatch', { link = 'SpecialChar' })
      vim.api.nvim_set_hl(0, 'CmpItemAbbrMatchFuzzy', { link = 'SpecialChar' })
      vim.api.nvim_set_hl(0, 'CmpItemMenu', { link = 'String' })
      vim.api.nvim_set_hl(0, 'CmpItemKind', { link = 'Identifier' })
      -- snacks
      vim.api.nvim_set_hl(0, 'SnacksDashboardHeader', { link = 'Directory' })
      vim.api.nvim_set_hl(0, 'SnacksDashboardDesc', { link = 'Normal' })
      -- neo-tree
      vim.api.nvim_set_hl(0, 'NeoTreeDirectoryIcon', { fg = '#8094b4', ctermfg = 12 })
      vim.api.nvim_set_hl(0, 'NeoTreeDirectoryName', { link = 'Title' })
      vim.api.nvim_set_hl(0, 'NeoTreeRootName', { bold = true })
      local opts = vim.api.nvim_get_hl(0, { name = 'NeoTreeGitUntracked' })
      opts.italic = false ---@diagnostic disable-line
      vim.api.nvim_set_hl(0, 'NeoTreeGitUntracked', opts) ---@diagnostic disable-line
      -- nvim-tree 的 ? 浮窗使用了 border, 所以需要修改背景色
      vim.api.nvim_set_hl(0, 'NvimTreeNormalFloat', { link = 'Normal' })
      vim.api.nvim_set_hl(0, 'NvimTreeFolderName', { link = 'Title' })
      vim.api.nvim_set_hl(0, 'NvimTreeOpenedFolderName', { link = 'Title' })
      vim.api.nvim_set_hl(0, 'NvimTreeSymlinkFolderName', { link = 'Title' })
    end
  end,
})

-- 直接用内置的 packadd 初始化主题
if vim.g.my_colors_name == 'gruvbox' and pcall(vim.cmd.packadd, 'gruvbox.nvim') then
  require('gruvbox').setup({
    bold = true,
    italic = {
      strings = false,
      emphasis = false,
      comments = false,
      operators = false,
      folds = false,
    },
    terminal_colors = vim.fn.has('gui_running') == 1,
  })
  if vim.env.TERM_PROGRAM ~= 'Apple_Terminal' then
    vim.o.background = 'dark'
    require('gruvbox').load()
    vim.api.nvim_exec_autocmds('ColorScheme', { modeline = false })
  end
  -- TODO: 放到 ColorScheme callback
  -- gruvbox.nvim 的这几个配色要覆盖掉
  local names = {
    'GruvboxRedSign',
    'GruvboxGreenSign',
    'GruvboxYellowSign',
    'GruvboxBlueSign',
    'GruvboxPurpleSign',
    'GruvboxAquaSign',
    'GruvboxOrangeSign',
  }
  for _, name in ipairs(names) do
    local opts = vim.api.nvim_get_hl(0, { name = name, link = false })
    if not vim.tbl_isempty(opts) then
      opts.bg = nil
      vim.api.nvim_set_hl(0, name, opts) ---@diagnostic disable-line
    end
  end
  -- 修改 treesiter 部分配色
  vim.api.nvim_set_hl(0, '@variable', {})
  vim.api.nvim_set_hl(0, '@constructor', { link = '@function' })
  vim.api.nvim_set_hl(0, 'markdownCodeBlock', { link = 'markdownCode' })
  vim.api.nvim_set_hl(0, 'markdownCode', { link = 'String' })
  vim.api.nvim_set_hl(0, 'markdownCodeDelimiter', { link = 'Delimiter' })
  vim.api.nvim_set_hl(0, 'markdownOrderedListMarker', { link = 'markdownListMarker' })
  vim.api.nvim_set_hl(0, 'markdownListMarker', { link = 'Tag' })
end

if vim.g.package_manager == 'pckr' then
  require('utils').add_plugins(require('plugins'))
else
  require('lazy').setup({
    spec = { import = 'plugins' },
    root = vim.fn.stdpath('config') .. '/pack/pckr/opt',
    rocks = {
      enabled = false,
    },
    install = {
      missing = false,
    },
    checker = { enable = false },
    change_detection = { enabled = false },
    performance = {
      rtp = {
        -- disable some rtp plugins
        disabled_plugins = {
          --'gzip',
          -- "matchit",
          -- "matchparen",
          -- "netrwPlugin",
          'tarPlugin',
          'tohtml',
          'tutor',
          'zipPlugin',
          'spellfile',
        },
      },
    },
  })
  -- 定制部分高亮组
  vim.api.nvim_set_hl(0, 'LazyNormal', { link = 'Normal' })
end
