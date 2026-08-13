" Neovim 原生字体效果展示
"
" 推荐启动方式：
"   nvim -u NONE -S /Users/eph/bin/nvim-font-effects.vim
"
" 也可以在已有的 Neovim 中执行：
"   :source /Users/eph/bin/nvim-font-effects.vim

if !has('nvim')
  echoerr '此文件只能由 Neovim 加载'
  finish
endif

lua << EOF
vim.opt.termguicolors = true

local api = vim.api
local ns = api.nvim_create_namespace("font-effects-showcase")

local groups = {
  FontDemoTitle = {
    fg = "#89b4fa",
    bold = true,
  },
  FontDemoSection = {
    fg = "#cba6f7",
    bold = true,
    underline = true,
  },
  FontDemoHint = {
    fg = "#7f849c",
    italic = true,
  },
  FontDemoRegular = {
    fg = "#cdd6f4",
  },
  FontDemoBold = {
    fg = "#cdd6f4",
    bold = true,
  },
  FontDemoItalic = {
    fg = "#cdd6f4",
    italic = true,
  },
  FontDemoBoldItalic = {
    fg = "#f9e2af",
    bold = true,
    italic = true,
  },
  FontDemoUnderline = {
    fg = "#a6e3a1",
    sp = "#a6e3a1",
    underline = true,
  },
  FontDemoUnderdouble = {
    fg = "#94e2d5",
    sp = "#94e2d5",
    underdouble = true,
  },
  FontDemoUnderdotted = {
    fg = "#89dceb",
    sp = "#89dceb",
    underdotted = true,
  },
  FontDemoUnderdashed = {
    fg = "#74c7ec",
    sp = "#74c7ec",
    underdashed = true,
  },
  FontDemoUndercurl = {
    fg = "#fab387",
    sp = "#f38ba8",
    undercurl = true,
  },
  FontDemoStrike = {
    fg = "#bac2de",
    strikethrough = true,
  },
  FontDemoReverse = {
    fg = "#1e1e2e",
    bg = "#cba6f7",
    reverse = true,
  },
  FontDemoCombo = {
    fg = "#f5c2e7",
    sp = "#f38ba8",
    bold = true,
    italic = true,
    undercurl = true,
  },
  FontDemoStrikeUnderline = {
    fg = "#eba0ac",
    sp = "#a6e3a1",
    underline = true,
    strikethrough = true,
  },
  FontDemoRed = { fg = "#f38ba8", bold = true },
  FontDemoYellow = { fg = "#f9e2af", bold = true },
  FontDemoGreen = { fg = "#a6e3a1", bold = true },
  FontDemoBlue = { fg = "#89b4fa", bold = true },
  FontDemoMauve = { fg = "#cba6f7", bold = true },
}

for name, attrs in pairs(groups) do
  api.nvim_set_hl(0, name, attrs)
end

local rows = {
  { "Neovim 原生字体与文本效果展示", "FontDemoTitle" },
  { "本页面直接使用 highlight/extmark，不依赖 Markdown 或渲染插件。", "FontDemoHint" },
  { "", nil },

  { "基本字形", "FontDemoSection" },
  { "常规 Regular        ABC abc 0123  中文字体示例  Il1| O0", "FontDemoRegular" },
  { "粗体 Bold           ABC abc 0123  中文字体示例  Il1| O0", "FontDemoBold" },
  { "斜体 Italic         ABC abc 0123  中文字体示例  Il1| O0", "FontDemoItalic" },
  { "粗斜体 Bold Italic  ABC abc 0123  中文字体示例  Il1| O0", "FontDemoBoldItalic" },
  { "", nil },

  { "线条效果", "FontDemoSection" },
  { "单下划线 Underline       The quick brown fox / 下划线", "FontDemoUnderline" },
  { "双下划线 Underdouble     The quick brown fox / 双下划线", "FontDemoUnderdouble" },
  { "点下划线 Underdotted     The quick brown fox / 点下划线", "FontDemoUnderdotted" },
  { "虚线下划线 Underdashed   The quick brown fox / 虚线下划线", "FontDemoUnderdashed" },
  { "波浪下划线 Undercurl     The quick brown fox / 波浪下划线", "FontDemoUndercurl" },
  { "删除线 Strikethrough     The quick brown fox / 删除线", "FontDemoStrike" },
  { "反色 Reverse            The quick brown fox / 反色", "FontDemoReverse" },
  { "", nil },

  { "组合效果", "FontDemoSection" },
  { "粗体 + 斜体 + 波浪下划线", "FontDemoCombo" },
  { "单下划线 + 删除线", "FontDemoStrikeUnderline" },
  { "", nil },

  { "颜色检查", "FontDemoSection" },
  { "红色 Red", "FontDemoRed" },
  { "黄色 Yellow", "FontDemoYellow" },
  { "绿色 Green", "FontDemoGreen" },
  { "蓝色 Blue", "FontDemoBlue" },
  { "紫色 Mauve", "FontDemoMauve" },
  { "", nil },

  { "字符、连字与间距", "FontDemoSection" },
  { "中文：天地玄黄，宇宙洪荒。你好，Neovim！", "FontDemoRegular" },
  { "连字：->  =>  !=  ==  ===  <=  >=  ::  //  /* */  !==", "FontDemoRegular" },
  { "符号：← → ↑ ↓  ↔ ⇒  ∑ √ ∞ ≠ ≤ ≥ ± × ÷ ≈", "FontDemoRegular" },
  { "括号：() [] {} <>  （）【】「」『』", "FontDemoRegular" },
  { "边框：┌────┬────┐  ├────┼────┤  └────┴────┘", "FontDemoRegular" },
  { "圆角：╭────────╮  │ Neovim │  ╰────────╯", "FontDemoRegular" },
  { "", nil },
  { "按 q 关闭。若几种下划线看起来相同，说明终端不支持对应线型。", "FontDemoHint" },
}

local buf = api.nvim_create_buf(false, true)
api.nvim_buf_set_name(buf, "nvim-font-effects://" .. buf)

local text = {}
for index, row in ipairs(rows) do
  text[index] = row[1]
end
api.nvim_buf_set_lines(buf, 0, -1, false, text)

for index, row in ipairs(rows) do
  if row[2] and row[1] ~= "" then
    api.nvim_buf_set_extmark(buf, ns, index - 1, 0, {
      end_col = #row[1],
      hl_group = row[2],
      priority = 200,
    })
  end
end

vim.bo[buf].buftype = "nofile"
vim.bo[buf].bufhidden = "wipe"
vim.bo[buf].swapfile = false
vim.bo[buf].modifiable = false
vim.bo[buf].filetype = "font-effects"

api.nvim_set_current_buf(buf)
vim.wo.number = false
vim.wo.relativenumber = false
vim.wo.cursorline = false
vim.wo.cursorcolumn = false
vim.wo.signcolumn = "no"
vim.wo.foldcolumn = "0"
vim.wo.list = false
vim.wo.wrap = false

vim.keymap.set("n", "q", "<Cmd>bd!<CR>", {
  buffer = buf,
  silent = true,
  nowait = true,
  desc = "关闭字体效果展示",
})

api.nvim_win_set_cursor(0, { 1, 0 })
EOF
