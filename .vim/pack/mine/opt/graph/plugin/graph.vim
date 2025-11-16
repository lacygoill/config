vim9script noclear

if exists('loaded') | finish | endif
var loaded = true

nnoremap <unique> ge <ScriptCmd>graph#edit_diagram()<CR>
xnoremap <unique> ge <C-\><C-N><ScriptCmd>graph#create_diagram()<CR>
