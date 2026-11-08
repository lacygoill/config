-- Options {{{1

-- let us squash an unfocused window to 0 lines
vim.o.winminheight = 0

-- Mappings {{{1

vim.keymap.set('n', 'Z', '<C-W>',
  { desc = 'Z is a simpler prefix for window management' })

vim.keymap.set('n', 'zh', '<Cmd>setlocal nowrap | leftabove  vsplit | setlocal nowrap<CR>',
  { desc = 'split window on the left (and disable wrapping in both splits)' })
vim.keymap.set('n', 'zj', '<Cmd>belowright split<CR>', { desc = 'split window below' })
vim.keymap.set('n', 'zk', '<Cmd>aboveleft split<CR>', { desc = 'split window above' })
vim.keymap.set('n', 'zl', '<Cmd>setlocal nowrap | rightbelow vsplit | setlocal nowrap<CR>',
  { desc = 'split window on the right (and disable wrapping in both splits)' })

vim.keymap.set('n', '<C-H>', function() require('window').Navigate('h') end,
  { desc = 'focus window on the left' })
vim.keymap.set('n', '<C-J>', function() require('window').Navigate('j') end,
  { desc = 'focus window below' })
vim.keymap.set('n', '<C-K>', function() require('window').Navigate('k') end,
  { desc = 'focus window above' })
vim.keymap.set('n', '<C-L>', function() require('window').Navigate('l') end,
  { desc = 'focus window on the right' })

vim.keymap.set('n', '<Space>t', '<Cmd>execute v:count != 0 ? v:count .. "tabnew" : "tabnew"<CR>',
  { desc = 'open new tab page in {count} position (without a count, last one)' })
-- TODO: `:quit` is simplified from what we do in Vim.
vim.keymap.set('n', '<Space>q', '<Cmd>quit<CR>',
  { desc = ':quit, :quitall :close, :lclose, :pclose, ...' })
  --     # Our `SPC q` mapping is special, it creates a session file so that we can undo
  --     # the closing of the window. `ZQ` should behave in the same way.
  --
  --     nmap <unique> ZQ <Space>q
  --
  --     -- If we press `ZZ`, Vim will remap the keys into `C-w Z`, which doesn't do anything.
  --     -- We need to restore `ZZ` original behavior.
  --     nmap ZZ <Plug>(my-ZZ-update)<Plug>(my-quit)
  --     nnoremap <Plug>(my-ZZ-update) <ScriptCmd>update<CR>
vim.keymap.set('n', '<C-N>', '<Cmd>execute (v:count > 1 ? v:count : "") .. "tabnext"<CR>',
  { desc = 'focus next tab page' })
vim.keymap.set('n', '<C-P>', '<Cmd>tabprevious<CR>',
  { desc = 'focus previous tab page' })
