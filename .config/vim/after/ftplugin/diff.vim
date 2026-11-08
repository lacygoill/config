vim9script

import autoload 'fold/foldtext.vim'

&l:foldmethod = 'expr'
&l:foldexpr = 'DiffFoldExpr()'
&l:foldtext = 'foldtext.Get()'

def DiffFoldExpr(): string
    if getline(v:lnum) =~ '^diff '
        return '>1'
    endif
    return '1'
enddef

b:undo_ftplugin = (get(b:, 'undo_ftplugin') ?? 'execute')
    .. ' | set foldexpr< foldmethod< foldtext<'
