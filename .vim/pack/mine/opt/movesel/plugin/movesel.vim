vim9script noclear

if exists('loaded') | finish | endif
var loaded = true

import 'lg/mapping.vim'
import autoload '../autoload/movesel.vim'

# Originally forked from:
# https://github.com/zirrostig/vim-schlepp

# Alternative plugins:
#
# https://github.com/t9md/vim-textmanip
# https://github.com/matze/vim-move

# Movement

# Do not use `C-[hjkl]`!{{{
#
# They are too easily pressed by accident  in visual-block mode, when we want to
# expand  the selection  and release  CTRL  a little  too late;  which leads  to
# unexpected motions of text.
#}}}
execute mapping.Meta('xnoremap <unique> <M-K> <ScriptCmd>movesel.Move("up")<CR>')
execute mapping.Meta('xnoremap <unique> <M-J> <ScriptCmd>movesel.Move("down")<CR>')
execute mapping.Meta('xnoremap <unique> <M-H> <ScriptCmd>movesel.Move("left")<CR>')
execute mapping.Meta('xnoremap <unique> <M-L> <ScriptCmd>movesel.Move("right")<CR>')

# Duplication

xnoremap <unique> mdk <ScriptCmd>movesel.Duplicate('up')<CR>
xnoremap <unique> mdj <ScriptCmd>movesel.Duplicate('down')<CR>
# works only on visual blocks
xnoremap <unique> mdh <ScriptCmd>movesel.Duplicate('left')<CR>
xnoremap <unique> mdl <ScriptCmd>movesel.Duplicate('right')<CR>
