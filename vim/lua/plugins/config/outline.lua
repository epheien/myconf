local outline = require('outline')

local M = {}

local access_icons = {
  public = '○',
  protected = '■', -- ◉  <= 这个字符偏大, 字体需要改进
  private = '●',
  --public = '○',
  --protected = '◉',
  --private = '✖',
  --public = '🟢',
  --protected = '🟡',
  --private = '🔴',
}

local opts = {
  view = {
    filter = function(buf)
      local ft = vim.bo[buf].filetype
      if ft == 'qf' then
        return false
      end
      return vim.bo[buf].buflisted or ft == 'help'
    end,
  },
  providers = {
    priority = { 'lsp', 'coc', 'markdown', 'norg', 'man', 'ctags', 'treesitter' },
    ctags = {
      filetypes = {
        ['c++'] = {
          kinds = {},
        },
        markdown = {
          scope_sep = '""',
        },
      },
    },
  },
  outline_window = {
    width = 30,
    relative_width = false,
    focus_on_open = false,
    float = {
      win_config = function(cfg)
        local winid = vim.api.nvim_get_current_win()
        return {
          relative = 'win',
          border = 'single',
          title = ' Outline ',
          title_pos = 'center',
          win = winid,
          --col = vim.o.columns - cfg.width - 3, -- border 1+1, gap 1
          col = math.max(0, vim.api.nvim_win_get_width(winid) - cfg.width - 3),
        }
      end,
      win_options = {
        winhighlight = 'NormalFloat:Normal',
      },
    },
  },
  keymaps = {
    close = { 'q' },
    goto_location = { '<CR>', '<2-LeftMouse>' },
    fold_all = 'zM',
    unfold_all = 'zR',
    down_and_jump = {},
    up_and_jump = {},
    restore_location = {},
  },
  symbol_folding = {
    autofold_depth = 2,
  },
  outline_items = {
    auto_update_events = {
      follow = { 'CursorHold' },
    },
  },
  symbols = {
    icons = {
      Variable = { icon = '' },
      TypeAlias = { icon = '', hl = 'Type' },
      Fragment = { icon = '●' }, -- ''
      Null = { icon = '∅' },
    },
    icon_fetcher = function(kindstr, bufnr, symbol) ---@diagnostic disable-line
      local cfg = require('outline.config')
      local icon = cfg.o.symbols.icons[kindstr].icon
      if symbol and symbol.access then
        return icon .. ' ' .. access_icons[symbol.access]
      end
      return icon
    end,
    filter = {
      -- lua 总显示一些 if 语句很烦, 以下 filter 列表取自 aerial.nvim
      lua = {
        'Class',
        'Constructor',
        'Enum',
        'Function',
        'Interface',
        'Module',
        'Method',
        'Struct',
      },
    },
  },
}

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'Outline',
  callback = function()
    vim.keymap.set(
      'n',
      '<LeftRelease>',
      '<LeftRelease>:lua require("plugins.config.outline").check_mouse_click()<CR>',
      {
        silent = true,
        buffer = true,
      }
    )
  end,
})
function M.check_mouse_click()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local col = cursor[2]
  local line = vim.api.nvim_get_current_line()
  local icon_open = ' '
  local icon_close = ' '
  local open_match = vim.regex(icon_open):match_str(line)
  local close_match = vim.regex(icon_close):match_str(line)
  local gap = 3
  if open_match and (col >= open_match and col <= open_match + gap) then
    local key = vim.api.nvim_replace_termcodes('<Tab>', true, false, true)
    vim.api.nvim_feedkeys(key, '', true)
  elseif close_match and (col >= close_match and col <= close_match + gap) then
    local key = vim.api.nvim_replace_termcodes('<Tab>', true, false, true)
    vim.api.nvim_feedkeys(key, '', true)
  end
end

outline.setup(opts)

return M
