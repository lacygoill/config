vim9script

if exists('b:did_ftplugin')
    finish
endif
b:did_ftplugin = true

import autoload '../autoload/fish.vim'
import autoload 'brackets/move.vim'

# Options {{{1

&l:comments = ':#'
&l:commentstring = '#%s'
&l:define = '^\\s*function\\>'
&l:include = '^\\s*\\.\\>'
# adding `-` is useful to complete options
&l:iskeyword = '@,48-57,_,-'
&l:keywordprg = ':Man'
# It seems 4 is the most widely used value (enforced by `fish_indent`).
&l:shiftwidth = 4

setlocal formatoptions+=jn1
setlocal formatoptions-=t
setlocal suffixesadd^=.fish

if executable('fish') > 0
    # Do not set `'formatprg'` to `fish_indent`.{{{
    #
    # It might seem to make sense, because `fish_indent` is also documented as
    # a “prettifier” tool (aka a  formatter).  And indeed, it also formats
    # the  code;  for example,  if  you  have 2  commands  on  a single  line,
    # separated by a semicolon, the tool will split them on separate lines.
    #
    # However, it would affect the `gq` operator, which we often use to format
    # comments.  And the tool sets the indentation level of commented lines to
    # 0, which is not what we want.
    #}}}
    &l:equalprg = 'fish_indent'
    &l:omnifunc = fish.Complete
endif

# In the shell, if we press `C-x C-e` to edit a long navi snippet, fold it.{{{
#
# On `    # some comment` and `    # ---`:
#
#     command
#         # some comment
#         # ...
#         # ---
#         # ...
#}}}
if expand('%:t') == 'command-line.fish'
        || expand('%:p:h:h:h:t') == 'cyclic-completions'
    &l:foldexpr = 'fish.FoldExpr()'
    &l:foldmethod = 'expr'
    &l:foldtext = 'fish.FoldText()'
endif

# We need to set a compiler for our custom lints to be used when we press `|c`.
compiler none

# Mappings {{{1

map <buffer><nowait> ]m <Plug>(next-function-start)
map <buffer><nowait> [m <Plug>(prev-function-start)
noremap <buffer><expr> <Plug>(next-function-start) move.Regex('fish-func-start')
noremap <buffer><expr> <Plug>(prev-function-start) move.Regex('fish-func-start', false)

map <buffer><nowait> ]M <Plug>(next-function-end)
map <buffer><nowait> [M <Plug>(prev-function-end)
noremap <buffer><expr> <Plug>(next-function-end) move.Regex('fish-func-end')
noremap <buffer><expr> <Plug>(prev-function-end) move.Regex('fish-func-end', false)

try
    import autoload 'submode.vim'
    execute submode.Enter('functions-start', 'nx', 'br', ']m', '<Plug>(next-function-start)')
    execute submode.Enter('functions-start', 'nx', 'br', '[m', '<Plug>(prev-function-start)')
    execute submode.Enter('functions-end', 'nx', 'br', ']M', '<Plug>(next-function-end)')
    execute submode.Enter('functions-end', 'nx', 'br', '[M', '<Plug>(prev-function-end)')
# E1053: Could not import "submode.vim"
catch /^Vim\%((\a\+)\)\=:E1053:/
endtry

# Variables {{{1

b:match_ignorecase = 0
# `end` is ambiguous.  It can terminate several blocks.
# That makes it difficult to jump from `end` to the right statement, simply with
# regexes.  We use a function to be able to use a more complex logic.
b:match_words = 'FishGetMatchWords()'
if !exists('*FishGetMatchWords')
    def g:FishGetMatchWords(): string
        return fish.GetMatchWords()
    enddef
endif
b:match_skip = 's:comment\|string\|deref'

b:mc_chain =<< trim END
    file
    omni
    keyn
    tags
    ulti
    abbr
    C-n
    dict
END
# }}}1

b:undo_ftplugin = (get(b:, 'undo_ftplugin') ?? 'execute')
    .. '| call fish#UndoFtplugin()'
