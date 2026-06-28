vim9script

import autoload '../../autoload/fz/git.vim'

nnoremap <buffer><nowait> <Space>fmm <ScriptCmd>git.Messages()<CR>

# Teardown {{{1

b:undo_ftplugin = (get(b:, 'undo_ftplugin') ?? 'execute')
    .. '| execute "nunmap <buffer> <Space>fmm"'
