-- source init-nvim.vim
local loop = vim.uv or vim.loop
---@diagnostic disable-next-line
local init_nvim = vim.fs.joinpath(vim.fn.stdpath('config'), 'init-nvim.vim')
if loop.fs_stat(init_nvim) then vim.cmd.source(init_nvim) end ---@diagnostic disable-line
