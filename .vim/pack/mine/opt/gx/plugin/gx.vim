vim9script noclear

if exists('loaded') | finish | endif
var loaded = true

import autoload '../autoload/gx.vim'

# The default `gx` command, installed by the netrw plugin, doesn't open a link
# correctly when it's inside a man page.  So, I implement my own solution.

nnoremap <unique> gx <ScriptCmd>gx.Open()<CR>
xnoremap <unique> gx <ScriptCmd>gx.Open()<CR>

# Also, install a `gX` mapping opening the url under the cursor in `w3m` inside
# a tmux pane.
# Idea:
# We  could  use  `gx`  for  the  two mappings,  and  make  the  function  react
# differently depending on `v:count`.
nnoremap <unique> gX <ScriptCmd>gx.Open(true)<CR>
xnoremap <unique> gX <ScriptCmd>gx.Open(true)<CR>
