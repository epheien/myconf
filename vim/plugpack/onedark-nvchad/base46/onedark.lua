-- Credits to original https://github.com/one-dark
-- This is modified version of it

local M = {}

M.base_30 = {
  white = "#abb2bf",
  darker_black = "#1b1f27",
  black = "#1e222a", --  nvim bg +030303
  black2 = "#252931", -- +030303
  one_bg = "#282c34", -- real bg of onedark +030303
  one_bg2 = "#353b45", -- +0D0F11
  one_bg3 = "#373b43", -- +01FFFE +02,+00,-02
  grey = "#42464e", -- +0b0b0b
  grey_fg = "#565c64", -- +141616
  grey_fg2 = "#6f737b", -- +191717
  light_grey = "#6f737b", -- +0
  red = "#e06c75",
  baby_pink = "#DE8C92",
  pink = "#ff75a0",
  line = "#31353d", -- for lines like vertsplit, black + 131313
  green = "#98c379",
  vibrant_green = "#7eca9c",
  nord_blue = "#81A1C1",
  blue = "#61afef",
  yellow = "#e7c787",
  sun = "#EBCB8B",
  purple = "#de98fd",
  dark_purple = "#c882e7",
  teal = "#519ABA",
  orange = "#fca2aa",
  cyan = "#a3b8ef",
  statusline_bg = "#22262e", -- black + 040404
  lightbg = "#2d3139", -- +0b0b0b
  pmenu_bg = "#61afef",
  folder_bg = "#61afef",
}

M.base_16 = {
  base00 = "#1e222a",
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

M = require("base46").override_theme(M, "onedark")

return M
