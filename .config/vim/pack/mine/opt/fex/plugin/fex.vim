vim9script noclear

if exists('loaded') | finish | endif
var loaded = true

import autoload '../autoload/fex.vim'
import autoload '../autoload/fex/tree.vim'

# Autocommand {{{1

augroup MyFex
    autocmd!
    autocmd BufNewFile /tmp/*/fex* expand('<afile>:p')->tree.Populate()
augroup END

# Command {{{1

command -bang -nargs=? -complete=file Tree tree.Open(<q-args>, <bang>0)

# Mappings {{{1

nnoremap <unique> -T <ScriptCmd>Tree<CR>
# TODO: If you press `-t` several times in the same tab page, several `fex` windows are opened.{{{
#
# I think it would be better if there was always at most one window.
# IOW, try to close an existing window before opening a new one.
#
# ---
#
# The same issue  applies to `-T`; although, for some  reason, to reproduce, you
# need to  always press `-T`  from a regular buffer,  because if you  press `-T`
# from a `fex` buffer, an error is given:
#
#     /tmp/v3cl1c7/366/fex/home/user/.vim/pack/mine/opt/fex/ is not a directory
#}}}
nnoremap <unique> -t <ScriptCmd>execute 'Tree ' .. getcwd()<CR>
nnoremap <unique> -- <ScriptCmd>fex.DirvishUp()<CR>
