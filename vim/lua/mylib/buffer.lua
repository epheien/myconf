local M = {}

---把 nvim_echo 的参数写到缓冲区的某一行中
---@param ns_id any
---@param bufnr integer
---@param lnum integer
---@param messages table[]
---@param bang boolean
local function echo_to_buffer(ns_id, bufnr, lnum, messages, bang)
  -- 初始化当前行和列的位置
  local row = math.max(lnum - 1, 0)
  local col = 0

  -- 遍历消息列表
  for _, message in ipairs(messages) do
    -- 获取消息的文本和高亮组
    local text = message[1]
    local hl_group = message[2]

    -- 将消息文本写入缓冲区
    vim.api.nvim_buf_set_text(bufnr, row, col, row, col, { text })

    -- 获取写入的文本的长度
    local text_length = #text

    -- 如果指定了高亮组, 则为写入的文本设置 extmark
    if hl_group then
      vim.api.nvim_buf_set_extmark(bufnr, ns_id, row, col, {
        end_row = row,
        end_col = col + text_length,
        hl_group = hl_group,
      })
    end

    -- 更新列的位置,移动到下一个消息的开始位置
    col = col + text_length
  end

  -- 如果设置了 bang, 则将光标移动到消息的开头
  if bang then
    vim.api.nvim_win_set_cursor(0, { row + 1, 0 })
  end
end

M.echo_to_buffer = echo_to_buffer

return M
