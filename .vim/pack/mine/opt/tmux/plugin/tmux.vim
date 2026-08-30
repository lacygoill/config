vim9script noclear

if exists('loaded') | finish | endif
var loaded = true

import 'lg/mapping.vim'
import autoload '../autoload/tmux.vim'
import autoload '../autoload/tmux/run.vim'

# This command can be useful when we need to find a small MRE out of a big plugin.{{{
#
# As an example, it can be used like this:
#
#     autocmd BufWritePost <buffer> TmuxRunThis vim -S /tmp/bug.vim
#}}}
command -nargs=1 TmuxRunThis run.Command(<q-args>)

nnoremap <unique> <Bar><Bar> <ScriptCmd>run.Command()<CR>
xnoremap <unique> <Bar><Bar> <ScriptCmd>run.Command()<CR>

execute mapping.Meta('nnoremap <unique> <M-P> <ScriptCmd>tmux.PutPreviousPane()<CR>')
