vim9script noclear

if exists('loaded') | finish | endif
var loaded = true

import autoload '../autoload/switch.vim'

nnoremap <unique> <C-A> <ScriptCmd>switch.Replace()<CR>
nnoremap <unique> <C-X> <ScriptCmd>switch.Replace(false)<CR>

map <unique> s<C-A> <Plug>(next-switchable-token)
map <unique> s<C-X> <Plug>(prev-switchable-token)
noremap <Plug>(next-switchable-token) <ScriptCmd>switch.Jump()<CR>
noremap <Plug>(prev-switchable-token) <ScriptCmd>switch.Jump(false)<CR>
