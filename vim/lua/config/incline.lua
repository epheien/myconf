-- incline setup {{{
local InclineNormalNC = {
    guifg = '#282828',
    guibg = '#6a6a6a',
    --guifg = '#969696',
    --guibg = '#585858',
    ctermfg = '235',
    ctermbg = '242',
}
local InclineNormal = {
  guifg = '#282828',
  guibg = '#8ac6f2',
  ctermfg = '235',
  ctermbg = '117',
  --guifg = '#444444',
  --guibg = '#9999ff',
  --ctermfg = '238',
  --ctermbg = '105',
}
local mode_table = {
  ['n']      = 'NORMAL',
  ['no']     = 'O-PENDING',
  ['nov']    = 'O-PENDING',
  ['noV']    = 'O-PENDING',
  ['no\22'] = 'O-PENDING',
  ['niI']    = 'NORMAL',
  ['niR']    = 'NORMAL',
  ['niV']    = 'NORMAL',
  ['nt']     = 'NORMAL',
  ['ntT']    = 'NORMAL',
  ['v']      = 'VISUAL',
  ['vs']     = 'VISUAL',
  ['V']      = 'V-LINE',
  ['Vs']     = 'V-LINE',
  ['\22']   = 'V-BLOCK',
  ['\22s']  = 'V-BLOCK',
  ['s']      = 'SELECT',
  ['S']      = 'S-LINE',
  ['\19']   = 'S-BLOCK',
  ['i']      = 'INSERT',
  ['ic']     = 'INSERT',
  ['ix']     = 'INSERT',
  ['R']      = 'REPLACE',
  ['Rc']     = 'REPLACE',
  ['Rx']     = 'REPLACE',
  ['Rv']     = 'V-REPLACE',
  ['Rvc']    = 'V-REPLACE',
  ['Rvx']    = 'V-REPLACE',
  ['c']      = 'COMMAND',
  ['cv']     = 'EX',
  ['ce']     = 'EX',
  ['r']      = 'REPLACE',
  ['rm']     = 'MORE',
  ['r?']     = 'CONFIRM',
  ['!']      = 'SHELL',
  ['t']      = 'TERMINAL',
}
local function slim_mode(mode)
  local dash_pos = mode:find("-")
  if not dash_pos then return mode:sub(1, 1) end
  return mode:sub(1, 1) .. mode:sub(dash_pos + 1, dash_pos + 1)
end
local function make_mode_display(m)
  local group = 'InclineNormalMode'
  local mode = mode_table[m]
  if m == 'n' then
    -- 用默认值
  elseif mode == 'INSERT' then
    group = 'InclineInsertMode'
  elseif mode == 'TERMINAL' then
    group = 'InclineTerminalMode'
  elseif mode == 'VISUAL' or mode == 'V-LINE' or mode == 'V-BLOCK' then
    group = 'InclineVisualMode'
  elseif mode == 'SELECT' or mode == 'S-LINE' or mode == 'S-BLOCK' then
    group = 'InclineSelectMode'
  elseif mode == 'REPLACE' or mode == 'V-REPLACE' then
    group = 'InclineReplaceMode'
  else
    -- 兜底用默认值
  end
  return {
    string.format(' %s ', slim_mode(mode)),
    group = group,
  }
end
local function setup_incline()
  vim.opt.laststatus = 3
  -- 生成需要用到的高亮组
  --vim.cmd([[hi InclineNormalMode guifg=#282828 guibg=#E0E000 ctermfg=235 ctermbg=184]])
  vim.api.nvim_set_hl(0, 'InclineNormalMode', {fg='#282828', bg='#E0E000', ctermfg=235, ctermbg=184})
  vim.cmd([[hi! InclineInsertMode ctermfg=235 ctermbg=119 guifg=#282828 guibg=#95e454]])
  vim.cmd([[hi! InclineTerminalMode ctermfg=235 ctermbg=119 guifg=#282828 guibg=#95e454]])
  vim.cmd([[hi! InclineVisualMode ctermfg=235 ctermbg=216 guifg=#282828 guibg=#f2c68a]])
  vim.cmd([[hi! InclineSelectMode ctermfg=235 ctermbg=216 guifg=#282828 guibg=#f2c68a]])
  vim.cmd([[hi! InclineReplaceMode ctermfg=235 ctermbg=203 guifg=#282828 guibg=#e5786d]])
  -- set noshowmode
  vim.o.showmode = false
  require('incline').setup({
    debounce_threshold = {
      falling = 50,
      rising = 10
    },
    hide = {
      cursorline = false,
      focused_win = false,
      only_win = false
    },
    highlight = {
      groups = {
        InclineNormal = InclineNormal,
        InclineNormalNC = InclineNormalNC,
      }
    },
    ignore = {
      buftypes = {},
      filetypes = {},
      floating_wins = true,
      unlisted_buffers = false,
      wintypes = {}
    },
    window = {
      margin = {
        horizontal = 0,
        vertical = 0
      },
      options = {
        signcolumn = "no",
        wrap = false
      },
      overlap = {
        borders = true,
        statusline = true,
        tabline = false,
        winbar = false
      },
      padding = 0,
      padding_char = " ",
      placement = {
        horizontal = "left",
        vertical = "bottom"
      },
      width = "fit",
      winhighlight = {
        active = {
          EndOfBuffer = "None",
          Normal = "InclineNormal",
          Search = "None"
        },
        inactive = {
          EndOfBuffer = "None",
          Normal = "InclineNormalNC",
          Search = "None"
        }
      },
      zindex = 1, -- 最小的 zindex, 以避免遮盖其他窗口
    },
    render = function(props)
      local filename = vim.api.nvim_eval_statusline('%f', {winid = props.win})['str']
      local mode = {}
      local mod = vim.api.nvim_eval_statusline('%m%r', {winid = props.win})['str']
      local active = (vim.api.nvim_tabpage_get_win(0) == props.win)
      local left_icon = ' '
      local trail_icon = ' '
      local mode_padding = ''
      -- 全局的背景色
      local guibg = '#282828'
      local ctermbg = 235
      --    
      local trail_glyph = ''
      if require('utils').only_ascii() then trail_glyph = '' end
      if active then
        --left_icon = {'', guibg = guibg, guifg = InclineNormal.guibg, ctermbg = ctermbg, ctermfg = InclineNormal.ctermbg}
        trail_icon = {trail_glyph, guibg = guibg, guifg = InclineNormal.guibg, ctermbg = ctermbg, ctermfg = InclineNormal.ctermbg}
        mode = make_mode_display(vim.fn.mode())
        if #mode ~= 0 then mode_padding = ' '; left_icon = '' end
      else
        --left_icon = {'', guibg = guibg, guifg = InclineNormalNC.guibg, ctermbg = ctermbg, ctermfg = InclineNormalNC.ctermbg}
        trail_icon = {trail_glyph, guibg = guibg, guifg = InclineNormalNC.guibg, ctermbg = ctermbg, ctermfg = InclineNormalNC.ctermbg}
      end
      if mod ~= '' then
        mod = ' ' .. mod
      end
      local result = {
        left_icon,
        mode,
        mode_padding,
        filename,
        mod,
      }

      -- 简单地添加 ruler 信息
      local ruler = vim.api.nvim_eval_statusline(' %l/%L,%v ', {winid = props.win})['str']
      ruler = ' │' .. ruler
      table.insert(result, ruler)

      table.insert(result, trail_icon)
      return result
    end,
  })
end
-- }}}

return setup_incline
