vim9script

# TODO: Check whether some refactoring commands could be turned into operators.{{{
#
# ---
#
# Make sure that:
#
#    - all operators can be invoked via an Ex command
#    - the latter supports a bang
#    - without a bang, the refactored text is highlighted, and the command asks for your confirmation
#}}}

import autoload '../../autoload/vim.vim'
import autoload '../../autoload/vim/gf.vim'
import autoload '../../autoload/vim/refactor/bar.vim'
import autoload '../../autoload/vim/refactor/dot.vim'
import autoload '../../autoload/vim/refactor/heredoc.vim'
import autoload '../../autoload/vim/refactor/import.vim'
import autoload '../../autoload/vim/refactor/lambda.vim'
import autoload '../../autoload/vim/refactor/method/splitjoin.vim'
import autoload '../../autoload/vim/refactor/ternary.vim'
import autoload 'brackets/move.vim'

# Commands {{{1
# RefBar {{{2

command -bang -bar -buffer -nargs=? -complete=custom,bar.Complete RefBar {
    bar.Main('line', <q-args>, <bang>0)
}

# RefDot {{{2

# Refactor dot concatenation operator:{{{
#
#     a . b   →  a..b
#     a.b     →  a..b
#     a .. b  →  a..b
#}}}
command -bang -bar -buffer -range=% RefDot dot.Main(<bang>0, <line1>, <line2>)

# RefHeredoc {{{2

command -bang -bar -buffer -nargs=* -complete=custom,heredoc.Complete RefHeredoc {
    heredoc.Main('line', <q-args>, <bang>0)
}

# RefLambda {{{2

command -bang -bar -buffer RefLambda {
    lambda.Main('line', <bang>0)
}

# RefQuote {{{2

command -bar -buffer -range=% RefQuote :<line1>,<line2> substitute/"\(.\{-}\)"/'\1'/gce

# RefTernary {{{2
# Usage  {{{3

# Select an `if / else(if) / endif` block, and execute `:RefTernary`.
# It will perform this conversion:

#         if var == 1                 let val = var == 1
#             let val = 'foo'               \ ?     'foo'
#         elseif var == 2                   \ : var == 2
#             let val = 'bar'    →          \ ?     'bar'
#         else                              \ :     'baz'
#             let val = 'baz'
#         endif
#
# Or this one:
#
#     if s:has_flag_p(a:flags, 'u')
#         return a:mode .. 'unmap'
#     else
#         return a:mode .. (s:has_flag_p(a:flags, 'r') ? 'map' : 'noremap')
#     endif
#
#         →
#
#     return s:has_flag_p(a:flags, 'u')
#         \ ?     a:mode .. 'unmap'
#         \ :     a:mode .. (s:has_flag_p(a:flags, 'r') ? 'map' : 'noremap')

# Code  {{{3

command -bar -buffer -range RefTernary ternary.Main(<line1>, <line2>)
#}}}2
#}}}1
# Mappings {{{1

# Purpose: Handle `:import` and `:packadd` lines in a smarter way.{{{
#
# `:import` is followed by a filename or filepath.  Find it.
#
# `:packadd`  is  followed  by the  name  of  a  package,  which we  might  have
# configured in scripts under `~/.vim/plugin`.  Find it.
#
# ---
#
# We can't handle the `:import` lines simply by setting `'includeexpr'`, because
# the option would be ignored if:
#
#    - the name of the imported script is the same as the current one
#    - `'path'` includes the `.` item
#
# Indeed,  in that  case, Vim  finds the  current file,  and simply  reloads the
# buffer.
#}}}
# We use the `F` variants, instead of the `f` ones, because they're smarter.
nnoremap <buffer><nowait> gf <ScriptCmd>gf.Find('gF')<CR>
nnoremap <buffer><nowait> <C-W>f <ScriptCmd>gf.Find('<C-W>F')<CR>
nnoremap <buffer><nowait> <C-W>gf <ScriptCmd>gf.Find('<C-W>gF')<CR>

# support the case  where we don't release shift when  pressing `Zf` (which will
# be remapped into `<C-W>f`)
nmap <buffer><nowait> <C-W>F <C-W>f
nmap <buffer><nowait> <C-W>GF <C-W>gf

nnoremap <buffer><nowait> <C-]> <ScriptCmd>vim.JumpToTag()<CR>
nnoremap <buffer><nowait> -h <ScriptCmd>vim.GetHelpUrl()<CR>

if expand('%:p') =~ '/syntax/\f\+\.vim$'
    nnoremap <buffer><nowait> gd <ScriptCmd>vim.JumpToSyntaxDefinition()<CR>
endif

map <buffer><nowait> ]m <Plug>(next-function-start)
map <buffer><nowait> [m <Plug>(prev-function-start)
noremap <buffer><expr> <Plug>(next-function-start) move.Regex('def')
noremap <buffer><expr> <Plug>(prev-function-start) move.Regex('def', false)

map <buffer><nowait> ]M <Plug>(next-function-end)
map <buffer><nowait> [M <Plug>(prev-function-end)
noremap <buffer><expr> <Plug>(next-function-end) move.Regex('enddef')
noremap <buffer><expr> <Plug>(prev-function-end) move.Regex('enddef', false)

try
    import autoload 'submode.vim'
    execute submode.Enter('functions-start', 'nx', 'br', ']m', '<Plug>(next-function-start)')
    execute submode.Enter('functions-start', 'nx', 'br', '[m', '<Plug>(prev-function-start)')
    execute submode.Enter('functions-end', 'nx', 'br', ']M', '<Plug>(next-function-end)')
    execute submode.Enter('functions-end', 'nx', 'br', '[M', '<Plug>(prev-function-end)')
# E1053: Could not import "submode.vim"
catch /^Vim\%((\a\+)\)\=:E1053:/
endtry

# TODO: When should we install visual mappings?

nnoremap <buffer><expr><nowait> =rb bar.Main()

# We use `=` as a prefix in visual mode.  That breaks `:help v_=`.{{{
#
# And  if  we  instinctively  press  `==`, the  indentation  will  be  correctly
# performed, but the trailing equal will remain in the typeahead buffer, waiting
# for  us  to  type a  motion  or  text-object.   That  means the  next  key  is
# interpreted as a motion or text-object, which is confusing.
#
# Let's fix all of this.
#}}}
xnoremap <buffer><nowait> == =

# TODO: should we turn those into operators (same thing for `=rq` and maybe `=rt`)?
nnoremap <buffer><nowait> =rd <ScriptCmd>RefDot<CR>
xnoremap <buffer><nowait> =rd <C-\><C-N><ScriptCmd>:* RefDot<CR>

nnoremap <buffer><expr><nowait> =rh heredoc.Main()
nnoremap <buffer><expr><nowait> =ri import.Main()
nnoremap <buffer><expr><nowait> =rl lambda.Main()
# TODO: Merge `=rL` with `=rl`.{{{
#
# When pressing `=rl` on an eval string, it should be refactored into a legacy lambda.
# When pressing `=rl` on a legacy lambda, it should be refactored into a Vim9 lambda.
#
# You'll need to merge `lambda.New()` with `splitjoin.Main()`.
#}}}
nnoremap <buffer><expr><nowait> =rL lambda.New()
nnoremap <buffer><expr><nowait> =r- splitjoin.Main()

nnoremap <buffer><nowait> =rq <ScriptCmd>RefQuote<CR>
xnoremap <buffer><nowait> =rq <C-\><C-N><ScriptCmd>:* RefQuote<CR>

xnoremap <buffer><nowait> =rt <C-\><C-N><ScriptCmd>:* RefTernary<CR>

# Options {{{1
# commentstring {{{2

if "\n" .. getline(1, 10)->join('\n') =~ '\n\s*vim9\%[script]\>'
    &l:commentstring = '#%s'
    &l:comments =
        # support formatting dashed lists in comments
        'sO:# -,mO:#  ,eO:##'
         .. ',:#'
endif

# define {{{2

&l:define = '^\s*\C\%(def\|fu\%[nction]\)!\=\s'

# formatlistpat {{{2

&l:formatlistpat = '^\s*#\=\s*\%(\d\+[.)]\|[-*+]\)\s\+'
#                                ├──────┘  ├───┘
#                                │         └ recognize unordered lists
#                                └ recognize numbered lists

# omnifunc {{{2

&l:omnifunc = vim.Complete
# }}}1
# Variables {{{1

b:mc_chain =<< trim END
    file
    keyn
    omni
    tags
    ulti
    abbr
    C-n
    dict
END

# Teardown {{{1

b:undo_ftplugin = (get(b:, 'undo_ftplugin') ?? 'execute')
    .. '| call vim#UndoFtplugin()'
