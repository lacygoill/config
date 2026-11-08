vim9script

if exists('b:did_ftplugin')
    finish
endif
b:did_ftplugin = true

import autoload '../autoload/tmux.vim'

&l:commentstring = '# %s'

nnoremap <buffer><expr><nowait> g"  tmux.FilterOp()
nnoremap <buffer><expr><nowait> g"" tmux.FilterOp() .. '_'
xnoremap <buffer><expr><nowait> g"  tmux.FilterOp()

compiler tmux

# Teardown {{{1

b:undo_ftplugin = (get(b:, 'undo_ftplugin') ?? 'execute')
    .. '| call tmux#UndoFtplugin()'
