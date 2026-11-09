-- 浮窗的 markdown 文件类型的窗口支持 q 退出
if vim.fn.empty(vim.api.nvim_win_get_config(0).relative) ~= 1 then
  vim.keymap.set('n', 'q', '<C-w>q', { buffer = true })
end

vim.keymap.set('n', 'gx', function()
  local row = vim.api.nvim_win_get_cursor(0)[1] - 1
  vim.treesitter.get_parser(0, 'markdown'):parse({ row, row + 1 })
  local node = vim.treesitter.get_node({ ignore_injections = false })
  local target
  while node do
    if node:type() == 'link_destination' then
      target = vim.treesitter.get_node_text(node, 0)
      break
    end
    -- 光标在链接文字上时，取同一个链接中的目标路径。
    for child in node:iter_children() do
      if child:type() == 'link_destination' then
        target = vim.treesitter.get_node_text(child, 0)
        break
      end
    end
    if target then
      break
    end
    node = node:parent()
  end
  target = (target or vim.fn.expand('<cfile>')):gsub('^<(.*)>$', '%1')
  if target == '' then
    return
  end

  -- 页内标题仍交给 markdown.nvim，网址仍使用系统浏览器。
  if target:sub(1, 1) == '#' then
    require('markdown.link').follow()
    return
  end
  if (target:match('^%a[%w+.-]*:') and not target:match('^file:')) or target:match('^www%.') then
    local _, err = vim.ui.open(target)
    if err then
      vim.notify(err, vim.log.levels.WARN)
    end
    return
  end

  local path, anchor = target:match('^([^#]+)#?(.*)$')
  if path:match('^file:') then
    path = vim.uri_to_fname(path)
  else
    path = path:gsub('\\(%p)', '%1')
    path = path:gsub('%%(%x%x)', function(hex) return string.char(tonumber(hex, 16)) end)
  end
  path = vim.fs.normalize(path, { expand_env = false })
  if path:sub(1, 1) ~= '/' then
    local dir = vim.fs.dirname(vim.api.nvim_buf_get_name(0)) or vim.fn.getcwd()
    path = vim.fs.normalize(dir .. '/' .. path, { expand_env = false })
  end
  if vim.fn.filereadable(path) == 0 and vim.fn.isdirectory(path) == 0 then
    vim.notify('File not found: ' .. path, vim.log.levels.WARN)
    return
  end
  vim.cmd.edit(vim.fn.fnameescape(path))

  if anchor ~= '' and vim.bo.filetype == 'markdown' then
    local tree = vim.treesitter.get_parser(0, 'markdown'):parse()[1]
    local query = vim.treesitter.query.parse(
      'markdown',
      [[
      (atx_heading (inline) @heading)
      (setext_heading (_ (inline) @heading))
    ]]
    )
    anchor = anchor:gsub('%%(%x%x)', function(hex) return string.char(tonumber(hex, 16)) end)
    for _, heading in query:iter_captures(tree:root(), 0) do
      local _, slug =
        require('markdown.link').get_heading_link(vim.treesitter.get_node_text(heading, 0))
      if slug == anchor then
        vim.api.nvim_win_set_cursor(0, { heading:start() + 1, 0 })
        break
      end
    end
  end
end, { buffer = true, silent = true, desc = 'Open Markdown link under cursor' })
vim.b.undo_ftplugin = (vim.b.undo_ftplugin or '') .. '|silent! nunmap <buffer> gx'
