local group = vim.api.nvim_create_augroup('PiTerminalScroll', { clear = true })

local attached = {}

local function scroll_to_bottom(buf)
  if not vim.api.nvim_buf_is_valid(buf) then
    return
  end

  local line_count = vim.api.nvim_buf_line_count(buf)

  -- 当前光标所在的窗口是 buf 的窗口时不强制滚动，避免打扰用户操作
  local current_win = vim.api.nvim_get_current_win()

  for _, win in ipairs(vim.fn.win_findbuf(buf)) do
    if win ~= current_win and vim.api.nvim_win_is_valid(win) then
      pcall(vim.api.nvim_win_call, win, function()
        vim.api.nvim_win_set_cursor(win, {
          math.max(line_count, 1),
          0,
        })

        vim.cmd('silent! normal! zb')
      end)
    end
  end
end

local function attach_pi_terminal(buf)
  if not vim.api.nvim_buf_is_valid(buf) then
    return
  end

  if vim.bo[buf].buftype ~= 'terminal' then
    vim.notify('当前 buffer 不是 terminal', vim.log.levels.WARN)
    return
  end

  if attached[buf] then
    return
  end

  local state = {
    scroll_scheduled = false,
  }

  attached[buf] = state

  local ok = vim.api.nvim_buf_attach(buf, false, {
    on_lines = function(_, changed_buf, _, _, old_lastline, new_lastline)
      if attached[changed_buf] ~= state then
        return
      end

      -- 忽略等长的行内容更新，例如：
      --
      -- 50 50
      -- 51 51
      --
      -- 响应新增或删除行，例如：
      --
      -- 1 0
      -- 2 1
      -- 3 2
      if new_lastline == old_lastline then
        return
      end

      -- throttle，而不是等待回调完全停止的 debounce。
      if state.scroll_scheduled then
        return
      end

      state.scroll_scheduled = true

      vim.defer_fn(function()
        state.scroll_scheduled = false

        if attached[changed_buf] ~= state then
          return
        end

        scroll_to_bottom(changed_buf)
      end, 10)
    end,

    on_detach = function(_, detached_buf) attached[detached_buf] = nil end,
  })

  if not ok then
    attached[buf] = nil

    vim.notify('无法监听 terminal buffer', vim.log.levels.ERROR)
  end
end

local function is_direct_pi_terminal(buf)
  local name = vim.api.nvim_buf_get_name(buf)
  local command = name:match('//%d+:(.*)$')

  if not command then
    return false
  end

  local executable = command:match('^%s*(%S+)')

  if not executable then
    return false
  end

  executable = vim.fn.fnamemodify(executable, ':t')

  return executable == 'pi'
end

vim.api.nvim_create_autocmd('TermOpen', {
  group = group,
  callback = function(ev)
    if is_direct_pi_terminal(ev.buf) then
      vim.api.nvim_buf_set_var(ev.buf, 'buf_name', 'pi') -- 让 mystl 精简 statusline
      attach_pi_terminal(ev.buf)
    end
  end,
})

vim.api.nvim_create_user_command(
  'PiAttachCurrentTerm',
  function() attach_pi_terminal(vim.api.nvim_get_current_buf()) end,
  {
    desc = '为当前 Pi terminal 启用自动滚动',
  }
)

vim.api.nvim_create_user_command(
  'PiScrollBottom',
  function() scroll_to_bottom(vim.api.nvim_get_current_buf()) end,
  {
    desc = '将当前 terminal 滚动到底部',
  }
)
