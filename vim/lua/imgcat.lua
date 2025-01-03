vim.opt_global.shortmess:append('I')
vim.cmd('setl buftype=nofile')
vim.cmd('ImageRender')
vim.cmd('set laststatus=0')
vim.cmd('nnoremap <silent> q <Cmd>q<CR>')

local image = require("image")

local M = {}

function M.imgcat(fname)
  ---- from a file (absolute path)
  local img = image.from_file(fname, {
    window = vim.fn.win_getid(), -- optional, binds image to a window and its bounds
    --buffer = 1000, -- optional, binds image to a buffer (paired with window binding)
    with_virtual_padding = true, -- optional, pads vertically with extmarks, defaults to false

    -- optional, binds image to an extmark which it follows. Forced to be true when
    -- `with_virtual_padding` is true. defaults to false.
    inline = true,

    -- geometry (optional)
    x = 0,
    y = -1, -- BUG: 0 的话会有一个空行, -1 可用
    width = vim.opt_global.columns:get() - 4,
    height = vim.opt_global.lines:get() - 1,
  })

  img:render() -- render image
end

return M
