-- I am using tab and leadmultispace in listchars to display the indent line. The chars for tab and
-- leadmultispace should be updated based on whether the indentation has been changed.
-- 1. If using space as indentation: set tab to a special character for denotation and
--    leadmultispace to the indent line character followed by multiple spaces whose amounts depends
--    on the number of spaces to use in each step of indent.
-- 2. If using tab as indentation: set leadmultispace to a special character for denotation and tab
--    to the indent line character.

local M = {}

local indentline_char = '│'

local exclude_filetypes = {
  'help',
  'NvimTree',
  'Outline',
  'neo-tree',
  'man',
  'TelescopeResults',
  'noice',
  'notify',
  'ConnManager',
  'snacks_notif',
  'Avante',
  'AvanteInput',
}

local excludes = {}
for _, ft in ipairs(exclude_filetypes) do
  excludes[ft] = true
end

local function indentchar_update(is_local, filetype)
  local tab
  local leadmultispace
  if vim.bo.buftype == 'terminal' or excludes[filetype or ''] then
    vim.b.miniindentscope_disable = true -- 同时禁用 mini.indentscope
    return
  end
  if vim.api.nvim_get_option_value('expandtab', {}) then
    -- For space indentation
    local spaces = vim.api.nvim_get_option_value('shiftwidth', {})
    -- If shiftwidth is 0, vim will use tabstop value
    if spaces == 0 then
      spaces = vim.api.nvim_get_option_value('tabstop', {})
    end
    tab = '› '
    leadmultispace = indentline_char .. string.rep(' ', spaces - 1)
  else
    -- For tab indentation
    tab = indentline_char .. ' '
    --leadmultispace = '␣'
  end

  -- Update
  local opt = is_local and vim.opt_local or vim.opt
  opt.listchars:append({ tab = tab })
  opt.listchars:append({ leadmultispace = leadmultispace })
end

M.indentchar_update = indentchar_update

return M
