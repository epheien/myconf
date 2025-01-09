-- Credits to original https://github.com/one-dark
-- This is modified version of it

local M = {}

M.base_30 = {
  white         = "#abb2bf",

  -- 这几个基本配色已经稳定
  darker_black  = "#22262e", -- base -060606
  black         = "#282c34", -- nvim bg, +060606, **BASE** black
  black2        = "#30343c", -- +080808
  one_bg        = "#383c44", -- real bg of onedark, +080808

  one_bg2       = "#3b414b", -- +030507 (非必要, 仅用于插件) XXX: 忽略
  one_bg3       = "#3d4149", -- +01fffe +02,+00,-02 (LspReference{Text,Read,Write}) XXX: 忽略

  -- https://github.com/joshdick/onedark.vim/blob/390b893d361c356ac1b00778d849815f2aa44ae4/colors/onedark.vim#L40
  -- https://github.com/joshdick/onedark.vim/blob/390b893d361c356ac1b00778d849815f2aa44ae4/colors/onedark.vim#L42
  grey          = "#4b5263", -- LineNr, PmenuThumb
  grey_fg       = "#5c6370", -- 仅用于 @comment

  grey_fg2      = "#757981", -- 几乎无用, 仅用于 DapUIBreakpointsDisabledLine XXX: 忽略
  light_grey    = "#757981", -- Comment 等等

  line          = "#3b3f47", -- for lines like vertsplit (WinSeparator), black + 131313
  statusline_bg = "#2c3038", -- black +040404, 不使用这个颜色, XXX: 忽略
  lightbg       = "#373b43", -- statusline_bg +0b0b0b, 用 St_xxx 系列, XXX: 忽略

  red           = "#e06c75",
  baby_pink     = "#de8c92",
  pink          = "#ff75a0",
  green         = "#98c379",
  vibrant_green = "#7eca9c",
  nord_blue     = "#81a1c1",
  blue          = "#61afef",
  yellow        = "#e7c787",
  sun           = "#ebcb8b",
  purple        = "#de98fd",
  dark_purple   = "#c882e7",
  teal          = "#519aba",
  orange        = "#fca2aa",
  cyan          = "#a3b8ef",
  pmenu_bg      = "#61afef",
  folder_bg     = "#61afef",
}

-- base16 配置比较成熟, 一般不需要修改
M.base_16 = {
  base00 = "#282c34",
  base01 = "#353b45",
  base02 = "#3e4451",
  base03 = "#545862",
  base04 = "#565c64",
  base05 = "#abb2bf",
  base06 = "#b6bdca",
  base07 = "#c8ccd4",
  base08 = "#e06c75",
  base09 = "#d19a66",
  base0A = "#e5c07b",
  base0B = "#98c379",
  base0C = "#56b6c2",
  base0D = "#61afef",
  base0E = "#c678dd",
  base0F = "#be5046",
}

M.type = "dark"

return M
