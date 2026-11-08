vim9script

# We maintain our own version because of a few bugs in the original script:
# https://github.com/vim/vim/pull/11759
# https://github.com/vim/vim/pull/12068

if exists('b:did_indent')
    finish
endif

b:did_indent = true
b:undo_indent = 'set indentexpr< indentkeys<'

import autoload '../autoload/luaindent.vim'

setlocal indentexpr=luaindent.Expr()
setlocal indentkeys+=0=end,0=until
