vim9script noclear

if exists('loaded') | finish | endif
var loaded = true

import autoload '../autoload/doc/cmd.vim'
import autoload '../autoload/doc/mapping.vim'

nnoremap <unique> K <ScriptCmd>mapping.Main()<CR>
# How is the visual mapping useful?{{{
#
# The normal mode  mapping works only if the documentation  command is contained
# in a codespan or codeblock; the visual mapping lifts that restriction.
#
# It's also useful to get the description of a shell command via `explain-shell`.
#}}}
xnoremap <unique> K <C-\><C-N><ScriptCmd>mapping.Main('vis')<CR>

command -bar -nargs=1 ExplainShell cmd.ExplainShell(<q-args>)
cnoreabbrev <expr> es getcmdtype() =~ '[:>]' && getcmdpos() == len('es') + 1
    \ ? 'ExplainShell'
    \ : 'es'

command -bar CtlSeqs cmd.CtlSeqs()
command -bar -nargs=? -complete=shellcmd Info cmd.Info(<q-args>)
command -bar -nargs=* Doc cmd.Doc(<f-args>)

command -bar FoldInfo cmd.FoldInfo()
