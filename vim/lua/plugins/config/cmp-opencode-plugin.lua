local M = {}

local source = {}

function source.new() return setmetatable({}, { __index = source }) end

function source:get_trigger_characters() return { '@' } end

function source:is_available()
  return vim.g.loaded_opencode_plugin and vim.bo.filetype == 'DressingInput'
end

function source:complete(params, callback)
  local line = params.context.cursor_line

  local col = params.context.cursor.col
  local before_cursor = line:sub(1, col - 1)

  local trigger_chars = table.concat(vim.tbl_map(vim.pesc, self:get_trigger_characters()), '')
  local _trigger_char, trigger_match =
    before_cursor:match('.*([' .. trigger_chars .. '])([%w_%-%.]*)')

  if not trigger_match then
    callback({ items = {}, isIncomplete = false })
    return
  end

  local items = {}

  for placeholder in pairs(require('opencode.config').opts.contexts) do
    --- @type lsp.CompletionItem
    local item = {
      label = placeholder,
    }
    table.insert(items, item)
  end

  callback({ items = items, isIncomplete = true })
end

function M.setup()
  local ok, cmp = pcall(require, 'cmp')
  if not ok then
    return false
  end

  cmp.register_source('cmp_opencode_plugin', source.new())

  --local config = cmp.get_config()
  --local sources = vim.deepcopy(config.sources or {})
  --cmp.setup.filetype({ "DressingInput" }, {
  --  sources = vim.list_extend(sources, {
  --    {
  --      name = "cmp_opencode_plugin",
  --      keyword_length = 1,
  --      options = {},
  --    },
  --  }),
  --})

  return true
end

return M
