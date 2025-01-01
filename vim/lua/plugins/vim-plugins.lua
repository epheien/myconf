local vim_plugins = {
  { 'tpope/vim-surround', event = 'VeryLazy' },
  {
    'yianwillis/vimcdoc',
    cmd = 'HelpfulVersion', -- 使用命令触发加载避免 lazy 报错
    config = function()
      vim.o.helplang = ''
    end,
  },
  { 'dstein64/vim-startuptime', cmd = 'StartupTime' },
  { 'sunaku/vim-dasht', cmd = 'Dasht' },
  { 'yuratomo/w3m.vim', cmd = 'W3m' },
  { 'Yggdroot/LeaderF', cmd = 'Leaderf' },
  { 'mbbill/undotree', cmd = 'UndotreeShow' },
  { 'dhruvasagar/vim-table-mode', cmd = 'TableModeToggle' },
  { 'skywind3000/asyncrun.vim', cmd = 'AsyncRun' },
  { 'kassio/neoterm', cmd = 'Tnew' },
  { 'epheien/vim-clang-format', cmd = 'ClangFormat' },
  --{ 'epheien/videm', cmd = 'VidemOpen' },
  { 'iamcco/markdown-preview.vim', ft = 'markdown' },
  { 'tweekmonster/helpful.vim', cmd = 'HelpfulVersion' },
}

return vim_plugins
