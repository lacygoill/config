vim9script noclear

if exists('loaded') | finish | endif
var loaded = true

import autoload '../autoload/bulletList.vim'

nnoremap <expr><unique> m* bulletList.Unordered()
nnoremap <expr><unique> m** bulletList.Unordered() .. '_'
xnoremap <expr><unique> m* bulletList.Unordered()

nnoremap <expr><unique> m# bulletList.Ordered()
nnoremap <expr><unique> m## bulletList.Ordered() .. '_'
xnoremap <expr><unique> m# bulletList.Ordered()
