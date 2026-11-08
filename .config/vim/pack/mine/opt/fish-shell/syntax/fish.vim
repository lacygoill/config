vim9script

if exists('b:current_syntax')
    finish
endif

import autoload '../autoload/fish.vim'
# Don't "fix" anything if  we're included in a different type  of file (e.g. a
# non-fenced markdown codeblock).
if &filetype == 'fish'
    fish.FixEndBuiltinHighlight()
endif

syntax case match
syntax iskeyword @,48-57,-,_,/

syntax cluster fishKeyword contains=fishBlock,fishFunction,fishConditional,
            \ fishRepeat,fishControl,fishOperator,fishCommand
syntax match fishBlock '^\s*\%(begin\|end\)\>'
syntax match fishBlock '\%(; \)\@2<=\%(begin\|end\)\>'
syntax keyword fishConditional if else switch case test
syntax keyword fishRepeat while for in break continue
syntax keyword fishControl return exit
syntax keyword fishOperator and or not

# http://fishshell.com/docs/current/commands.html
syntax keyword fishCommand abbr alias argparse bg block breakpoint
            \ builtin cd cdh command commandline complete contains[] count dirh dirs
            \ disown echo emit eval exec fg fish fish_breakpoint_prompt fish_config
            \ fish_git_prompt fish_hg_prompt fish_indent fish_key_reader
            \ fish_mode_prompt fish_opt fish_prompt fish_right_prompt
            \ fish_svn_prompt fish_update_completions fish_vcs_prompt funced funcsave
            \ functions help history isatty jobs math nextd open popd prevd printf
            \ prompt_pwd psub pushd pwd random read realpath set set_color source
            \ status suspend time trap type ulimit umask vared wait
syntax match fishCommand /\v<string%(\s+%(collect|escape|join|join0|length|lower
            \ |match|repeat|replace|shorten|split|split0|sub|trim|unescape|upper))=>/

syntax keyword fishFunction function nextgroup=fishFunctionName skipwhite
syntax match fishFunctionName '[^[:space:]/()-][^[:space:]/()]*' contained
            \ contains=fishString,fishDeref

# Asserting the presence of a trailing whitespace prevents many false positive.{{{
#
# For example, you might call a function with a hyphen in its name.
# This hyphen is not an arithmetic operator.
#}}}
syntax match fishOperator '\s\@1<=[-+*/%!]\s\@='
# `=` is a special case.{{{
#
# I think there are fewer false positives.
# Besides, we want it to be highlighted in long options assignments:
#
#     $ cmd --option=value
#                   ^
#}}}
syntax match fishOperator /=/
syntax match fishOperator '!=\|&&\|||\|\.\.'

syntax match fishComment /#.*/ contains=fishTodo,@Spell
syntax keyword fishTodo NOTE TODO FIXME contained
syntax match fishSpecial /[\()]/
syntax match fishSpecial /\\\$/
syntax match fishOption /\<[+-][[:alnum:]-_]\+\>/

syntax match fishNumber /\<[+-]\=\%\(\d+\.\)\=\d\+\>/

syntax match fishDeref /\$\+[[:alnum:]_]\+/ nextgroup=fishDerefExtension
syntax region fishDerefExtension
    \ matchgroup=fishDelimiter
    \ start=/\[/
    \ end=/\]/
    \ contained
    \ contains=fishCommandSubstitution,fishDeref,fishNumber,fishOperator
# Don't make `fishDelimiter` contained.{{{
#
# We want to match these brackets too:
#
#     set -f --erase cmd[1]
#                       ^ ^
#}}}
syntax match fishDelimiter /[[\]]/

syntax match fishSingleQuoteEscape /\\[\\']/ contained
# Don't include a newline in the match:
# https://github.com/vim/vim/issues/11007
syntax match fishDoubleQuoteEscape /\\[\\"$]\|\\\n\@=/ contained
syntax cluster fishStringEscape contains=fishSingleQuoteEscape,fishDoubleQuoteEscape

syntax region fishString start=/'/ skip=/\\[\\']/ end=/'/ contains=fishSingleQuoteEscape
syntax region fishString start=/"/ skip=/\\[\\"]/ end=/"/ contains=fishDoubleQuoteEscape,fishDeref,fishCommandSubstitution

syntax match fishCharacter /\v\\[0abefnrtv *?~%#{}\[\]<>&;"']|\\[xX][0-9a-f]{1,2}|\\o[0-7]{1,2}|\\u[0-9a-f]{1,4}|\\U[0-9a-f]{1,8}|\\c[a-z]/
syntax match fishCharacter /\v\\e[a-zA-Z0-9]/

# Highlight LHS of key binding.{{{
#
# Otherwise, we might get a distracting highlighting:
#
#     bind \e\[Z '__expand_glob'
#          ^---^
#     bind \c^ 'cd -; commandline --function repaint'
#          ^^^
#}}}
syntax match fishBind /^\s*bind\>/ nextgroup=fishBindLHS skipwhite
syntax match fishBindLHS /\S\+/ contained contains=fishBindSpecialKey nextgroup=fishBindRhs skipwhite
    # Order: keep this rule after the previous one.
    syntax match fishBindLHS /''\|' '/ contained contains=fishString nextgroup=fishBindRhs skipwhite
# The RHS might be a string.  It's fine.  Let's ignore it.
syntax match fishBindRhs /[^'"[:blank:]]\S*/ contained
# control, meta, enter, tab
syntax match fishBindSpecialKey /\\[ce].\|\\[rt]\|\\[[:punct:]]\|\\x\x\x/ contained contains=fishBindSpecialKey
#                                                 ^-----------^  ^-----^
#                                bind \e\{ complete-into-braces  for things like \x20 (space)
#                                        ^

# Order: Needs to be after `fishBind*` rules.{{{
#
# Otherwise, when you restart Vim with a fish file:
#
#     E409: Unknown group name: fishBind.*
#}}}
syntax region fishCommandSubstitution
    \ matchgroup=PreProc
    \ start=/$(/
    \ end=/\\\@1<!)/
    \ contains=@fishCommandSubstitutionList

syntax cluster fishCommandSubstitutionList contains=
    \ fishBlock,
    \ fishCharacter,
    \ fishCommand,
    \ fishCommandSubstitution,
    \ fishComment,
    \ fishConditional,
    \ fishControl,
    \ fishDelimiter,
    \ fishDeref,
    \ fishDerefExtension,
    \ fishDoubleQuoteEscape,
    \ fishFunction,
    \ fishNumber,
    \ fishOperator,
    \ fishOption,
    \ fishRedirection,
    \ fishRepeat,
    \ fishSingleQuoteEscape,
    \ fishSpecial,
    \ fishString,
    \ fishTodo

syntax match fishRedirection /\d*\%([><]\|>>\)\%(\s*["[:fname:]]\)\@=/
syntax match fishRedirection /\d*\%([><]\|>>\)&\d\+/

# https://github.com/vim/vim/issues/11007#issuecomment-1274367618
syntax sync minlines=60

highlight default link fishBind fishCommand
highlight default link fishBindSpecialKey fishSpecial
highlight default link fishBlock fishKeyword
highlight default link fishCharacter Special
highlight default link fishCommand Statement
highlight default link fishComment Comment
highlight default link fishConditional Conditional
highlight default link fishControl Keyword
highlight default link fishDelimiter Delimiter
highlight default link fishDeref Identifier
highlight default link fishDoubleQuoteEscape Special
highlight default link fishFunction fishKeyword
highlight default link fishFunctionName Function
highlight default link fishKeyword Keyword
highlight default link fishNumber Number
highlight default link fishOperator Operator
highlight default link fishOption Constant
highlight default link fishRedirection fishOperator
highlight default link fishRepeat Repeat
highlight default link fishSingleQuoteEscape Special
highlight default link fishSpecial Special
highlight default link fishString String
highlight default link fishTodo Todo

b:current_syntax = 'fish'
