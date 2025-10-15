return {
  {
    name = '  Open with nvim terminal',
    cmd = function() require('conn-manager').open({ open_with = '' }) end,
    rtxt = 'on',
  },
  {
    name = '  Open with nvim terminal in new tab',
    cmd = function() require('conn-manager').open({ open_with = 'tab' }) end,
    rtxt = 'ot',
  },
  {
    name = '  Open with Alacritty.app',
    cmd = function() require('conn-manager').open({ open_with = 'alacritty' }) end,
    rtxt = 'oa',
  },
  {
    name = '  Open with Kitty.app',
    cmd = function() require('conn-manager').open({ open_with = 'kitty' }) end,
    rtxt = 'ok',
  },
  { name = 'separator' },

  {
    name = '  Add node',
    cmd = require('conn-manager').add_node,
    rtxt = 'a',
  },
  {
    name = '  Add folder',
    cmd = require('conn-manager').add_folder,
    rtxt = 'A',
  },
  { name = 'separator' },

  {
    name = '  Edit node',
    cmd = require('conn-manager').modify,
    rtxt = 'r',
  },
  {
    name = '  Remove node',
    cmd = require('conn-manager').remove,
    rtxt = 'D',
  },
  { name = 'separator' },

  {
    name = '  Cut',
    cmd = require('conn-manager').cut_node,
    rtxt = 'x',
  },
  {
    name = '  Copy',
    cmd = require('conn-manager').copy_node,
    rtxt = 'c',
  },
  {
    name = '  Paste',
    cmd = function() require('conn-manager').paste_node() end,
    rtxt = 'p',
  },
  {
    name = '  Paste before node',
    cmd = function() require('conn-manager').paste_node(true) end,
    rtxt = 'P',
  },
}
