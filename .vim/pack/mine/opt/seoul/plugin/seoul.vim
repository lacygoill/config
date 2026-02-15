vim9script noclear

if exists('loaded') | finish | endif
var loaded = true

import autoload '../autoload/seoul.vim'

nmap [ol <Plug>([ol)
nmap ]ol <Plug>(]ol)

nnoremap <Plug>([ol) <ScriptCmd>seoul.NextLevel()<CR>
nnoremap <Plug>(]ol) <ScriptCmd>seoul.NextLevel(true)<CR>
