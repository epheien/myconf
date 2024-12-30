do return end -- bypass

if vim.fn.has('nvim-0.10') == 1 then
  return {
    "folke/noice.nvim",
    requires = { 'MunifTanjim/nui.nvim', 'rcarriga/nvim-notify' },
    config = function() require('config/noice') end,
  }
end
