return {
  'dhananjaylatkar/cscope_maps.nvim',
  cmd = { 'Cs', 'Cstag' },
  opts = {
    disable_maps = true,
    skip_input_prompt = false,
    prefix = '',
    cscope = {
      db_file = './GTAGS',
      exec = 'gtags-cscope',
      skip_picker_for_single_result = true
    }
  }
}
