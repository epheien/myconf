vim.opt.runtimepath:prepend(vim.fn.getcwd())

local texttable = require('mylib.texttable')

local function assert_equal(expected, actual)
  if not vim.deep_equal(expected, actual) then
    error(string.format('expected %s, got %s', vim.inspect(expected), vim.inspect(actual)))
  end
end

local function assert_contains(haystack, needle)
  if not string.find(haystack, needle, 1, true) then
    error(string.format('expected %q to contain %q', haystack, needle))
  end
end

local function assert_not_contains(haystack, needle)
  if string.find(haystack, needle, 1, true) then
    error(string.format('expected %q not to contain %q', haystack, needle))
  end
end

local function make_table(title)
  return {
    title = title,
    remark = '',
    cols = { 'name' },
    rows = { { title } },
  }
end

local tests = {}

tests['parses comma-separated filter input'] = function()
  assert_equal({ 'hello', 'world' }, texttable.parse_title_filters('hello, world'))
end

tests['render_status hides only tables whose title exactly matches any filter'] = function()
  local fname = vim.fn.tempname()
  vim.fn.writefile({
    vim.json.encode(make_table('hello')),
    vim.json.encode(make_table('hello status')),
    'plain text stays',
    vim.json.encode(make_table('world')),
    vim.json.encode(make_table('world table')),
    vim.json.encode(make_table('visible table')),
  }, fname)

  local content = table.concat(texttable.render_status(fname, { filters = { 'hello', 'world' } }), '\n')

  assert_not_contains(content, '===== hello =====')
  assert_not_contains(content, '===== world =====')
  assert_contains(content, '===== hello status =====')
  assert_contains(content, '===== world table =====')
  assert_contains(content, '===== visible table =====')
  assert_contains(content, 'plain text stays')
end

tests['buffer_render_status hides exact title matches and displays active filters'] = function()
  local buf = vim.api.nvim_create_buf(false, true)
  texttable.buffer_render_status(buf, make_table('hidden table'), {
    filters = { 'hidden table', 'another table' },
  })

  local content = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), '\n')

  assert_contains(content, '当前时间:')
  assert_contains(content, '过滤标题: hidden table,another table')
  assert_not_contains(content, '===== hidden table =====')
  vim.api.nvim_buf_delete(buf, { force = true })
end

tests['filter prompt defaults to filters supplied through render opts'] = function()
  local buf = vim.api.nvim_create_buf(false, true)
  local captured_default
  local old_input = vim.fn.input
  vim.fn.input = function(_, default)
    captured_default = default
    return default
  end

  texttable.buffer_render_status(buf, make_table('visible table'), {
    filters = { 'hidden table' },
  })
  texttable.prompt_title_filters(buf, make_table('visible table'))

  vim.fn.input = old_input
  vim.api.nvim_buf_delete(buf, { force = true })
  assert_equal('hidden table', captured_default)
end

local failures = {}

for name, fn in pairs(tests) do
  local ok, err = pcall(fn)
  if not ok then
    table.insert(failures, string.format('%s: %s', name, err))
  end
end

if #failures > 0 then
  error(table.concat(failures, '\n'))
end
