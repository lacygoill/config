vim9script noclear

if exists('loaded') | finish | endif
var loaded = true

import autoload '../autoload/columnObject.vim'

xnoremap <unique> io <C-\><C-N><ScriptCmd>columnObject.Main('iw')<CR>
xnoremap <unique> iO <C-\><C-N><ScriptCmd>columnObject.Main('iW')<CR>
xnoremap <unique> ao <C-\><C-N><ScriptCmd>columnObject.Main('aw')<CR>
xnoremap <unique> aO <C-\><C-N><ScriptCmd>columnObject.Main('aW')<CR>

onoremap <unique> io <ScriptCmd>columnObject.Main('iw')<CR>
onoremap <unique> iO <ScriptCmd>columnObject.Main('iW')<CR>
onoremap <unique> ao <ScriptCmd>columnObject.Main('aw')<CR>
onoremap <unique> aO <ScriptCmd>columnObject.Main('aW')<CR>
