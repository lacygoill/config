vim9script

import autoload 'fex.vim'

# Options {{{1

&l:statusline = '%!g:statusline_winid == win_getid() ? "%#StatusLineArgList#%a%* %y %F%<%=%l/%L " : "%y %F"'
# in a squashed dirvish window, displaying the line/column position is useless (noise)

# Mappings {{{1
# -m {{{2

nnoremap <buffer><nowait> -m <ScriptCmd>fex.PrintMetadata()<CR>
xnoremap <buffer><nowait> -m <C-\><C-N><ScriptCmd>fex.PrintMetadata()<CR>
nnoremap <buffer><nowait> -M <ScriptCmd>fex.PrintMetadata(true)<CR>

# C-n  C-p {{{2

# Dirvish installs the mappings `C-n` and `C-p` to preview the contents
# of the previous/next file or directory.
# It clashes with our own `C-n` and `C-p` to move across tabpages.
# Besides, we'll use `}` and `{` instead.

nunmap <buffer> <C-N>
nunmap <buffer> <C-P>

# gh {{{2

# Map `gh` to toggle dot-prefixed entries.
nnoremap <buffer><nowait> gh <ScriptCmd>fex.ToggleDotEntries()<CR>

# h    l {{{2

nmap <buffer><nowait><silent> h <Plug>(dirvish_up)
nmap <buffer><nowait><silent> l <CR>

# p ) ( {{{2

nnoremap <buffer><nowait> p <ScriptCmd>fex.Preview()<CR>
nnoremap <buffer><nowait> ) j<ScriptCmd>fex.Preview()<CR>
nnoremap <buffer><nowait> ( k<ScriptCmd>fex.Preview()<CR>

# q {{{2

nmap <buffer><nowait><silent> q <Plug>(dirvish_quit)

# tp {{{2

nnoremap <buffer><nowait> tp <ScriptCmd>fex.TrashPut()<CR>
#}}}1
# Teardown {{{1

b:undo_ftplugin = (get(b:, 'undo_ftplugin') ?? 'execute')
    .. '| call plugin#dirvish#UndoFtplugin()'
