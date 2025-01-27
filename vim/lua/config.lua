-- 自用全局变量 `package_manager` `nodashboard` `my_colors_name`
-- pckr or lazy
vim.g.package_manager = 'lazy'
vim.g.enable_noice = false
if not vim.g.my_colors_name then
  vim.g.my_colors_name = 'onedark-nvchad' -- gruvbox | catppuccin | tokyonight | onedark-nvchad
end
if not vim.g.nodashboard then
  vim.g.nodashboard = true
end

---@type string
local config_path = vim.fn.stdpath('config') --[[@as string]]
local loop = vim.uv or vim.loop

-- base46 主题引擎缓存目录
--vim.g.base46_cache = config_path .. '/base46_cache/'

-- 简易覆盖 vim.notify, 用来避免 hit enter 信息, 例如 lazy.nvim 启动时的警告
vim.notify = function(msg, level, opts) ---@diagnostic disable-line
  print(string.format('[%s]', tostring(level)), msg)
  vim.cmd.redraw() -- 避免 hit enter
end

require('config.options')
require('config.autocmds')

local function load_config()
  require('config.keymaps')
  require('config.commands')

  require('config.float-help')
  require('config.mystl')
  require('config.alacritty-mouse-fix')
  if vim.g.enable_noice then
    require('extmark-ruler').setup()
  end
end

vim.api.nvim_create_autocmd('User', {
  pattern = 'VeryLazy',
  once = true,
  callback = load_config,
})

vim.opt.packpath:append(config_path)
local path = vim.fs.joinpath(config_path, 'lazy', 'lazy.nvim')
local msg = string.format(
  'Failed to init lazy.nvim, try to run:\n'
    .. '`git clone --filter=blob:none --branch=stable https://github.com/folke/lazy.nvim.git %s`',
  path
)
assert(loop.fs_stat(path), msg) ---@diagnostic disable-line
vim.opt.rtp:prepend(path)

-- base46 二进制主题
if vim.g.base46_cache and vim.g.my_colors_name == 'base46' then
  dofile(vim.g.base46_cache .. 'defaults')
  local function load_base46_colors()
    for _, v in ipairs(vim.fn.readdir(vim.g.base46_cache)) do
      if v ~= 'defaults' and v ~= 'statusline' then
        dofile(vim.g.base46_cache .. v)
      end
    end
  end
  if vim.fn.argc(-1) > 0 then
    load_base46_colors()
  else
    vim.api.nvim_create_autocmd('User', {
      pattern = 'VeryLazy',
      once = true,
      callback = load_base46_colors,
    })
  end
  vim.g.colors_name = 'base46'
  vim.api.nvim_exec_autocmds('ColorScheme', { modeline = false, pattern = vim.g.colors_name })
end

require('lazy').setup({
  spec = { import = 'plugins' },
  root = vim.fs.joinpath(config_path, 'lazy'),
  rocks = {
    enabled = false,
  },
  install = {
    missing = false,
  },
  checker = { enable = false, frequency = math.huge },
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
--vim.api.nvim_set_hl(0, 'LazyNormal', { link = 'Normal' })
