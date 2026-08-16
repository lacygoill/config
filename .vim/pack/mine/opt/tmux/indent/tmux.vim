vim9script

if exists('b:did_indent')
    finish
endif

import autoload '../autoload/tmux/indent.vim'

&l:indentexpr = 'indent.Expr()'
&l:indentkeys = 'o'

# Teardown {{{1

b:undo_indent = (get(b:, 'undo_indent') ?? 'execute')
    .. '| set indentkeys< indentexpr<'

b:did_indent = true
