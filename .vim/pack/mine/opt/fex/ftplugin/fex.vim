vim9script

if exists('b:did_ftplugin')
    finish
endif

import autoload '../autoload/fex.vim'
import autoload '../autoload/fex/tree.vim'

# Options {{{1

&l:bufhidden = 'delete'
&l:buftype = 'nofile'
&l:buflisted = false
&l:cursorline = true
&l:swapfile = false
&l:winfixwidth = true
&l:wrap = false

&l:concealcursor = 'nc'
&l:conceallevel = 3
&l:foldexpr = 'tree.FoldExpr()'
&l:foldmethod = 'expr'
&l:foldtext = 'tree.FoldText()'
tree.FoldLevel()

&l:statusline = '%!g:statusline_winid == win_getid()'
    .. ' ? "%y %{fex#statusline#Curdir()}%<%=%l/%L "'
    .. ' : "%y %{fex#statusline#Curdir()}"'

# Mappings {{{1

# FIXME: Press `C-s` twice.  The second time, a vertical split is created.
# Nothing should happen.
# If the file is already displayed in the tab page, don't open it.
#
# Also, there is  an issue in the  function; `wincmd p` will not  always give us
# the desired result (we want a new  large horizontal split; not a vertical one,
# which we would probably get if the  previous window is a vertical split opened
# via `C-w f`).
nnoremap <buffer><nowait> <C-S> <ScriptCmd>tree.Edit()<CR>
nnoremap <buffer><nowait> <C-W>F <ScriptCmd>tree.Split()<CR>
nnoremap <buffer><nowait> <C-W>f <ScriptCmd>tree.Split()<CR>
nnoremap <buffer><nowait> <C-W>gf <ScriptCmd>tree.Split(true)<CR>

nnoremap <buffer><nowait> ( k<ScriptCmd>tree.Preview()<CR>
nnoremap <buffer><nowait> ) j<ScriptCmd>tree.Preview()<CR>
nnoremap <buffer><nowait> [[ <ScriptCmd>search('.*/$', 'b')<CR>
nnoremap <buffer><nowait> ]] <ScriptCmd>search('.*/$')<CR>

nnoremap <buffer><nowait> -M <ScriptCmd>fex.PrintMetadata(true)<CR>
nnoremap <buffer><nowait> -m <ScriptCmd>fex.PrintMetadata()<CR>
xnoremap <buffer><nowait> -m <C-\><C-N><ScriptCmd>fex.PrintMetadata()<CR>

nnoremap <buffer><nowait> R <ScriptCmd>tree.Reload()<CR>
nnoremap <buffer><nowait> g? <ScriptCmd>tree.DisplayHelp()<CR>
nnoremap <buffer><nowait> gh <ScriptCmd>tree.ToggleDotEntries()<CR>

nnoremap <buffer><nowait> [[ <ScriptCmd>tree.RelativeDir('parent')<CR>
nnoremap <buffer><nowait> ]] <ScriptCmd>tree.RelativeDir('child')<CR>
nnoremap <buffer><nowait> p <ScriptCmd>tree.Preview()<CR>
nnoremap <buffer><nowait> q <ScriptCmd>tree.Close()<CR>

# Variables {{{1

b:did_ftplugin = true

# Teardown {{{1

b:undo_ftplugin = (get(b:, 'undo_ftplugin') ?? 'execute')
    .. '| call fex#UndoFtplugin()'
