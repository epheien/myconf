return {
  cmd = {
    'clangd',
    '--header-insertion=never', -- NOTE: 添加这个选项后, '•' 前缀变成了 ' ', 需要自己过滤掉
    --'--header-insertion-decorators',
  },
}
