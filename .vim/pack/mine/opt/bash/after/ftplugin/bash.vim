vim9script

import autoload 'bash.vim'
import autoload 'brackets/move.vim'

# Mappings {{{1

nnoremap <buffer><expr><nowait> =rb bash.BreakLongCmd()

map <buffer><nowait> ]m <Plug>(next-func-start)
map <buffer><nowait> [m <Plug>(prev-func-start)
noremap <buffer><expr> <Plug>(next-func-start) move.Regex('bash-func-start')
noremap <buffer><expr> <Plug>(prev-func-start) move.Regex('bash-func-start', false)

map <buffer><nowait> ]M <Plug>(next-func-end)
map <buffer><nowait> [M <Plug>(prev-func-end)
noremap <buffer><expr> <Plug>(next-func-end) move.Regex('bash-func-end')
noremap <buffer><expr> <Plug>(prev-func-end) move.Regex('bash-func-end', false)

try
    import autoload 'submode.vim'
    execute submode.Enter('bash-func-start', 'nx', 'br', ']m', '<Plug>(next-func-start)')
    execute submode.Enter('bash-func-start', 'nx', 'br', '[m', '<Plug>(prev-func-start)')
    execute submode.Enter('bash-func-end', 'nx', 'br', ']M', '<Plug>(next-func-end)')
    execute submode.Enter('bash-func-end', 'nx', 'br', '[M', '<Plug>(prev-func-end)')
# E1053: Could not import "submode.vim"
catch /^Vim\%((\a\+)\)\=:E1053:/
endtry

# Options {{{1

&l:shiftwidth = 2
&l:textwidth = 80
# When I press `K` on a command name, Vim starts `less(1)`.  I want to read the documentation in a Vim buffer!{{{
#
# The current behavior is due to these lines in the default zsh filetype plugin:
#
#     # $VIMRUNTIME/ftplugin/zsh.vim
#     setlocal keywordprg=:RunHelp
#     command! -buffer -nargs=1 RunHelp
#     \ silent execute '!zsh -ic "autoload -Uz run-help; run-help <args> 2>/dev/null | LESS= less"' | redraw!
#
# Solution1:
#
#     &l:keywordprg = ':Man'
#
# Solution2:
#
# In `less(1)`, press `E` (custom key binding) to read the contents of the pager
# in a Vim buffer.
#
# For the moment, I prefer the second solution, because it runs the zsh function
# `run-help` which – before printing a man  page – tries find a help file in
# case the argument is a builtin command name.
#}}}

# If you need a buggy shell script to test the linter:
#     $ echo 'echo `echo $i`' >/tmp/sh.sh
compiler shellcheck

# Variables {{{1

b:match_words ..= ',\%(^\s*\)\@<=function\>'
    .. ':\<return\>'
    .. ':\%(^\s*\)\@<=}\s*$'

# Teardown {{{1

b:undo_ftplugin = (get(b:, 'undo_ftplugin') ?? 'execute')
    .. '| call bash#UndoFtplugin()'
