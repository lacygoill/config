vim9script

# We only want to handle *bash* scripts.
# Let the default syntax plugin handle all the other ones.
if exists('b:current_syntax')
|| (getline(1) !~ '\<bash\>' && &filetype != 'bash' && search('```bash', 'cn') <= 0)
    finish
endif

import 'bashLanguage.vim' as lang
import 'vim9SyntaxUtil.vim'
const Derive: func = vim9SyntaxUtil.Derive

# TODO: Highlight user function calls (and definitions).
# Use text properties.

# bash syntax is case sensitive
syntax case match

# ? {{{1

syntax match bshStartOfLine /^/ nextgroup=bshMayBeCmd skipwhite
syntax match bshMayBeCmd /\%(\<\l\+\_s\)\@=/ contained nextgroup=@bshIsCmd
syntax match bshMayBeCmd /\%(\[\[\=\s\)\@=/ contained nextgroup=@bshIsCmd
syntax match bshPipe /||\@!&\=/ skipwhite nextgroup=bshMayBeCmd
syntax cluster bshIsCmd contains=
    \ bshBreakContinue,
    \ bshCase,
    \ bshCaseEnd,
    \ bshDeclare,
    \ bshDone,
    \ bshFor,
    \ bshIf,
    \ bshReturnExit,
    \ bshTest,
    \ bshWhile
syntax match bshCmdSep /;/ nextgroup=bshMayBeCmd skipwhite

syntax keyword bshDeclare declare local readonly export contained
highlight default link bshDeclare Identifier

# Need to match in any position; for example:
#
#     printf '%s' "$buf" | { xsel --input --clipboard ;}
#                          ^
syntax match bshGroupCommandStart /{/ nextgroup=bshMayBeCmd skipwhite
syntax match bshGroupCommandEnd /}/

#     sudo mv /etc/apt/sources.list{,.bak}
#                                  ^^    ^
syntax region bshBraceExpansion
    \ matchgroup=Delimiter
    \ start=/{\%(\S*,\S*}\)\@=/
    \ end=/}/
    \ contains=bshBraceExpansion,bshBraceExpansionComma
    \ oneline
syntax match bshBraceExpansionComma /,/ contained
highlight default link bshBraceExpansionComma Delimiter

#     echo {1..9}
#          ^ ^^ ^
syntax region bshBraceExpansion
    \ matchgroup=Delimiter
    \ start=/{\%(\S*[^.]\.\.[^.]\S*}\)\@=/
    \ end=/}/
    \ contains=bshBraceExpansion,bshBraceExpansionDotDot
    \ oneline
syntax match bshBraceExpansionDotDot /\.\./ contained
highlight default link bshBraceExpansionDotDot Delimiter

syntax region bshArithmeticExpansion
    \ matchgroup=PreProc
    \ start=/$\=((/
    \ end=/))/
    \ contains=
    \     bshArithmeticAssignment,
    \     bshArithmeticOperators,
    \     bshCmdSub,
    \     bshNumber,
    \     bshParameterExpansion,
    \     bshParameterSubscript,
    \     bshVariableSpecial
    \ nextgroup=bshForDo
    \ oneline
    \ skipwhite

syntax match bshArithmeticOperators /++\=\|--\=/ contained
syntax match bshArithmeticOperators /[!~]/ contained
syntax match bshArithmeticOperators /\*\*/ contained
syntax match bshArithmeticOperators /[*/%]/ contained
syntax match bshArithmeticOperators /<<\|>>/ contained
syntax match bshArithmeticOperators /<=\=\|>=\=/ contained
syntax match bshArithmeticOperators /[=!]=/ contained
syntax match bshArithmeticOperators /[&^|]/ contained
syntax match bshArithmeticOperators /&&\|||/ contained
syntax match bshArithmeticAssignment /==\@!\|[-*/%+&^|]=\|<<=\|>>=/ contained

syntax keyword bshDone done contained

# NOTE: We no longer highlight builtins.{{{
#
# They're tricky to match consistently.  For  example, you would need to match
# `read` here:
#
#     IFS=: read -r _command hint modifier <<<"$statement"
#           ^--^
#
# Besides, the fact that a word is a builtin is not very meaningful.
#}}}
# That said, if you need a list of them:
#
#     $ compgen -A builtin | grep -v 'declare\|export\|local\|readonly'

# TODO:
#
#                        ✘
#                bshHereDocLiteral
#                v------v
#     tee <<'EOF' | wc -l
#     a
#     b
#     c
#     EOF
syntax region bshHereDocLiteral
    \ matchgroup=Operator
    \ start=/\%(\d\+\)\=<<-\=\s*\(['"]\)\z(\w\+\)\1.\{-}\ze|\=/
    \ end=/^\t*\z1$/

syntax region bshHereDocExpanded
    \ matchgroup=Operator
    \ start=/\%(\d\+\)\=<<-\=\s*\z(\w\+\).\{-}\ze|\=/
    \ contains=bshArithmeticExpansion,bshCmdSub,bshEscapedMetacharacter,bshParameterExpansion
    \ end=/^\t*\z1$/

syntax match bshEscapedMetacharacter /\\[$`\\]/ contained

if search('<<-\=\s*''AWK''', 'cn') > 0
    unlet! b:current_syntax
    syntax include @bshAwkScript syntax/awk.vim
    syntax region bshHereDocLiteralAwk
        \ matchgroup=Operator
        \ start=/\%(\d\+\)\=<<-\=\s*'AWK'.\{-}\ze|\=/
        \ end=/^\t*AWK$/
        \ contains=@bshAwkScript
endif

# Control Operators {{{1

syntax match bshControlOperator /&&\|||/ nextgroup=bshMayBeCmd skipwhite
syntax match bshReservedWordBang /!=\@!/ nextgroup=bshMayBeCmd skipwhite

#     control operator
#            A token that performs a control function.  It is one of the fol‐
#            lowing symbols:
#            || & && ; ;; ;& ;;& ( ) | |& <newline>
#
# We still need to handle:
#
#     &
#     ;
#     ;;
#     ;&
#     ;;&
#     ( )

# Tests {{{1

syntax match bshTest /\[\[\=\s\@=/ contained nextgroup=bshTestFileOperator skipwhite
syntax keyword bshTest test contained nextgroup=bshTestFileOperator skipwhite
syntax match bshTestFileOperator /-[abcdefgGhkLNOprsStuwx]\s\@=/ contained skipwhite
syntax match bshTestBracketLastArgument /\s\]\]\=/ skipwhite

# Functions: {{{1

syntax match bshFunction /^\s*\w\%(\w\|-\)*\s*()\_s*{/hs=e-3

syntax match bshFunctionKeyword /^\s*function\>/ nextgroup=bshFunction skipwhite
syntax match bshFunction /\w\%(\w\|-\)*\s*()\_s*{/hs=e-3 contained

# Options: {{{1

syntax match bshOption /\_s\@1<=[-+][-_a-zA-Z0-9#@]\+/
syntax match bshOption /\_s\@1<=--[^[:blank:]$=`'"|);]\+/

# File Redirection Highlighted As Operators: {{{1

#                                                  >$some_var
#                                                  vv
syntax match bshRedirection /\d*\%([><]\|>>\)\s*\%(\$\|\f\+\|"\|[<>](\)\@=/
#                                                               ^---^
#                                                               < <(process substitution)
#                                                               > >(process substitution)
syntax match bshRedirection /\d*\%([><]\|>>\)&\d\+/
syntax match bshRedirection /<<</

# Operators: {{{1

syntax match bshOperator /[!&;|]/ contained
syntax match bshOperator /\[[[^:]\|\]]/ contained

# `==`, `!=` glob comparison
syntax match bshOperator /[!=]=/ nextgroup=bshPattern skipwhite
# `=~` regex comparison
syntax match bshOperator /=\~\s\@=/ nextgroup=bshPattern skipwhite

# The pattern cannot start with an unescaped comment leader/tilde.{{{
#
# Hence why we disallow `#` and `~` at the start.
#}}}
# We match contained strings because those can be used to escape characters which are special in a regex.{{{
#
# Like `.` and `*`.
#
#    > Any part of the pattern may be quoted to force the quoted portion to be
#    > matched as a string.
#
# Source: `man bash /SHELL GRAMMAR/;/Compound Commands/;/=\~`
#
# Remember that  in the shell,  "quoted" is  another way of  saying "escaped".
# But using quotes as an escape  mechanism is specific to the shell.  Usually,
# in a regex, the only way to  escape a metacharacter is the backslash.  Since
# we're not used to such a syntax, we want to be made aware of a metacharacter
# losing its special meaning in that way.
#
# We also need to match strings to prevent spurious errors:
#
#                  this should not be highlighted as an error by bshPatternUnescaped
#                  v
#     [[ $var =~ a' 'b ]]
#     [[ $var =~ a'<'b ]]
#                  ^
#}}}
syntax region bshPattern
    \ start=/[^[:blank:]#~]/
    \ end=/\%(\s\%(]]\|||\|&&\)\)\@=/
    \ contained
    \ contains=bshParameterExpansion,bshString,bshExSingleQuote,bshPatternUnescaped,bshPatternEscapedQuote
    \ keepend
    \ oneline

# Some characters need to be escaped because they're special to the shell.{{{
#
# Bad:
#
#                 ✘
#                 v
#     [[ $var =~ a b ]]
#     [[ $var =~ a<b ]]
#                 ^
#                 ✘
#
# Good:
#
#                 ✔
#                 vv
#     [[ $var =~ a\ b ]]
#     [[ $var =~ a\<b ]]
#                 ^^
#                 ✔
#
# Don't try to write a custom lint  for that pitfall.  It's way too complex to
# handle, which is probably why shellcheck can't explain why it fails to parse
# a test containing such an error.
#}}}
syntax match bshPatternUnescaped /\\\@1<![ <>&;`]/ contained
highlight default link bshPatternUnescaped Error

# To prevent a string from matching when its starting quote is escaped.
syntax match bshPatternEscapedQuote /\\['"]/ contained

# Loops: for, while, until, select {{{1

# TODO: Either this rule should be moved in  a different fold, or the fold title
# should be changed.
syntax keyword bshIf if then elif else fi contained nextgroup=bshTest skipwhite

syntax keyword bshFor for select contained nextgroup=bshForName,bshArithmeticExpansion skipwhite
syntax match bshForName /\h\w*/ contained nextgroup=bshForIn skipwhite
syntax keyword bshForIn in contained nextgroup=bshForWords skipwhite
syntax match bshForWords /[^;]\+/ contained transparent nextgroup=bshForDo
syntax match bshForDo /;\s*do\>/hs=s+1 contained
syntax keyword bshBreakContinue break continue contained

syntax keyword bshWhile while until contained nextgroup=bshTest skipwhite
syntax match bshWhileDo /;\s*do\>/hs=s+1

# Case: case...esac {{{1

# case block
syntax keyword bshCase case contained nextgroup=bshCaseWord skipwhite
syntax match bshCaseWord /.*\%(\<in\>\)\@=/ contained nextgroup=bshCaseIn skipwhite transparent
syntax keyword bshCaseIn in contained
# TODO: Use text properties to confine the match to a `case` block.{{{
#
# ATM, our regex wrongly matches:
#
#     # from: /usr/share/doc/bubblewrap/examples/bubblewrap-shell.sh
#     (exec bwrap --ro-bind /usr /usr \
#           ...
#           /bin/sh) \
#                  ^
#                  ✘
#}}}
var bshCasePattern: string = '^\%(\s*\)\@>'
    # Ignore a closing paren at the start of a commented line.{{{
    #
    # I  know it  doesn't  make sense  to  write such  a  parenthesis, but  in
    # practice that often happens briefly  while we're editing a comment.  And
    # when it does, the wrong syntax highlighting is distracting.
    #}}}
    .. '\%(# \)\@!'
    .. '\%('
    # We disallow an open parenthesis because it breaks way too many other syntaxes{{{
    #
    # Arrays,   arithmetic   expansions,    command   substitutions,   process
    # substitutions, ....
    #}}}
    #   Which means that you can't embed arithmetic expansions, command substitutions, and process substitutions.{{{
    #
    # Even though they're allowed here.
    #
    # If you try, they will be correctly highlighted, but not contained inside
    # `bshCasePattern`, and the ending `)` will not be highlighted.
    #
    # In any case, IMO, using those syntaxes inside a `case` pattern makes the
    # code hard to read.  You can still assign their output to a variable, and
    # refer to it inside your pattern.
    #}}}
    ..     '[^([:blank:]]'
    # Occasionally, we might need to match an open parenthesis.  In that case,
    # let us write `[(]`.
    ..     '\|' .. '(]'
    # Support extended pattern matching operators enabled by `$ shopt -s extglob`.
    # `man bash /EXPANSION/;/Pathname Expansion/;/Pattern Matching/;/extglob`
    ..     '\|' .. '[!?@+*]('
    # Inside a case pattern, most spaces must be escaped.{{{
    #
    #       a b)
    #        ^
    #        ✘
    #
    # Witout, an error would be given:
    #
    #     syntax error near unexpected token `b'
    #     `  a b)'
    #}}}
    ..     '\|' .. '\\\@1<=\s'
    # Spaces around a bar used as an alternation are allowed though.{{{
    #
    #       a | b)
    #        ^ ^
    #        ✔ ✔
    #}}}
    ..     '\|' .. '|\@1<=\s'
    ..     '\|' .. '\s|\@='
    .. '\)\+'
    # Trailing whitespace  is allowed  too.  Also, technically,  whitespace is
    # not  required after  the parenthesis,  but it  might help  against false
    # positives.
    .. '\%(\s*)\_s\)\@='
execute 'syntax match bshCasePattern'
    .. ' /' .. bshCasePattern .. '/'
    .. ' nextgroup=bshCaseParen'
    .. ' skipwhite'
    .. ' contains=bshCasePatternAlternation,bshParameterExpansion'

syntax match bshCasePatternAlternation /|/ contained
syntax match bshCaseParen /)\_s\@=/ contained
syntax match bshCaseOperator /;;&\|;[;&]/
syntax keyword bshCaseEnd esac

# Parameter Expansion {{{1

# matching `$#` prevents a comment from being wrongly matched
syntax match bshParameterExpansion /\\\@1<!$\%(\w\+\|[$#@*!?]\)\@=/
    \ nextgroup=bshParameterName,bshVariableSpecialReference
syntax match bshParameterName /\w\+\|[$#@*!?]/ contained
highlight default link bshParameterName bshParameterExpansion

# `extend`: to correctly highlight this:
#
#     "${myhash["$key"]}"
#                     ^^
syntax region bshParameterExpansion
    \ matchgroup=Delimiter
    \ start=/\\\@1<!${/
    \ skip=/\\}/
    \ end=/}/
    \ contains=bshParameter,bshParameterBang,bshParameterNumberSign,bshVariableSpecialReference
    \ extend

syntax match bshParameter /\%(${\)\@2<=\%(\w\+\|[$#@*!?]\)/
    \ contained
    \ nextgroup=
    \     bshParameterCaseModification,
    \     bshParameterIfUnset,
    \     bshParameterRemovePrefixOrSuffix,
    \     bshParameterSubscript,
    \     bshParameterSubstitutionPattern,
    \     bshParameterSubstring,
    \     bshParameterTransformation
    # Order: This rule must  come *after* `bshParameter`, for  `${HOME}` to be
    # highlighted as a special variable, and not a regular one.
    #
    # Alternatively, you  could add  `contains=bshVariableSpecialReference` to
    # the `bshParameter`  match, but it  seems inefficient to  uselessly match
    # the latter, just to match the former.
    execute $'syntax match bshVariableSpecialReference /\<\%({lang.special_variables}\)\>/'
        .. ' contained nextgroup=bshParameterSubscript'

#     ${parameter:-word}
#     ${parameter:=word}
#     ${parameter:?word}
#     ${parameter:+word}
syntax match bshParameterIfUnset /:[-=?+]/ contained nextgroup=bshParameterDefaultValue
# `bshExSingleQuote,bshSpecial` for something like `${1:-$'\n'}`.
syntax match bshParameterDefaultValue /[^}]*/ contained contains=bshParameterExpansion,bshExSingleQuote,bshSpecial

#     ${parameter:offset}
#     ${parameter:offset:length}
syntax match bshParameterSubstring /:\d\@=/ contained nextgroup=bshParameterOffsetOrLength
syntax match bshParameterOffsetOrLength /\d\+/ contained nextgroup=bshParameterSubstring

#     ${parameter#word}
#     ${parameter##word}
#     ${parameter%word}
#     ${parameter%%word}
syntax match bshParameterRemovePrefixOrSuffix /##\=\|%%\=/ contained nextgroup=bshParameterPrefixOrSuffix
#                                                                                             v
#                                                     printf '%s\n' "${passphrase#"$DELIMITER"}"
#                                                                                        v----v
syntax match bshParameterPrefixOrSuffix /[^}]*/ contained contains=bshParameterExpansion extend
#                                                         ^----------------------------^
#                                              printf '%s\n' "${passphrase#${DELIMITER}}"
#                                                                          ^----------^

#     ${parameter/pattern/string}
#                ^
#     # replace only first occurrence
#
#     ${parameter//pattern/string}
#                ^^
#     # replace all occurrences
syntax region bshParameterSubstitutionPattern
    \ matchgroup=Delimiter
    \ start='//\='
    \ skip='\\/'
    \ end='/'
    \ contains=bshParameterExpansion,bshExSingleQuote
    \ contained
    \ nextgroup=bshParameterSubstitutionReplacement
    \ oneline
syntax match bshParameterSubstitutionReplacement +\%(\\}\|[^}]\)*+ contained contains=bshParameterExpansion

#     ${parameter^pattern}
#     ${parameter^^pattern}
#     ${parameter,pattern}
#     ${parameter,,pattern}
syntax match bshParameterCaseModification /\^\^\=\|,,\=/ contained nextgroup=bshParameterSubstitutionReplacement

#     ${name[subscript]}
syntax region bshParameterSubscript
    \ matchgroup=Delimiter
    \ start=/\[/
    \ end=/\]/
    \ contained
    \ contains=bshNumber,bshString,bshArithmeticExpansion,bshParameterExpansion,bshParameterSubscriptSpecial
    \ nextgroup=bshParameterRemovePrefixOrSuffix,bshParameterSubstitutionPattern,bshParameterSubstring,bshVarAssign

#     ${name[@]}
#     ${name[*]}
syntax match bshParameterSubscriptSpecial /\[\@<=[*@]\]\@=/ contained

#     ${parameter@Q}
#     ${parameter@E}
#     ${parameter@P}
#     ${parameter@A}
#     ${parameter@a}
syntax match bshParameterTransformation /@/ contained nextgroup=bshParameterTransformationOperator
syntax match bshParameterTransformationOperator /[QEPAa]/ contained

#     ${!prefix*}
#     ${!prefix@}
syntax match bshParameterBang /\%(${\)\@2<=!/
    \ contained
    \ nextgroup=bshParameterArrayKeys,bshParameterMatchingPrefix
syntax match bshParameterMatchingPrefix /\w\+[*@]\@=/ contained nextgroup=bshParameterMatchingPrefixHow
syntax match bshParameterMatchingPrefixHow /[*@]/ contained
#     ${!name[@]}
#     ${!name[*]}
syntax match bshParameterArrayKeys /\w\+\%(\[[@*]\]\)\@=/
    \ contained
    \ contains=bshVariableSpecialReference
    \ nextgroup=bshParameterArrayKeysHow
syntax region bshParameterArrayKeysHow matchgroup=Delimiter start=/\[/ end=/\]/ contained

#     ${#parameter}
syntax match bshParameterNumberSign /\%(${\)\@2<=#/
    \ contained
    \ nextgroup=bshParameterLength
# `nextgroup=bshParameterSubscript` because of:
#    > ${#name[subscript]} expands to the length of ${name[subscript]}
syntax match bshParameterLength /\w\+/
    \ contained
    \ contains=bshVariableSpecialReference
    \ nextgroup=bshParameterSubscript

# Command/Process Substitution {{{1

# A command substitution might contain a double-quoted string.{{{
#
# But usually, a command substitution is itself inside a double-quoted string.
# We don't want a double quote from a nested string to prematurely terminate the
# command substitution:
#
#     start of the outer string
#     v
#     "$(... "inner string" ...)"
#            ^            ^
#            those do not terminate the outer string
#
# That's why we need the `extend` argument here.
#}}}
syntax region bshCmdSub
    \ matchgroup=bshCmdSubRegion
    \ start=/\\\@1<!\$((\@!/
    \ skip=/\\\\\|\\./
    \ end=/)/
    \ contains=@bshCmdSubList
    \ extend

syntax region bshCmdSub
    \ matchgroup=bshCmdSubRegion
    \ start=/\\\@1<!`/
    \ skip=/\\\\\|\\./
    \ end=/\\\@1<!`/
    \ contains=@bshCmdSubList
    \ extend

syntax region bshProcessSub
    \ matchgroup=bshCmdSubRegion
    \ start=/[<>](/
    \ skip=/\\\\\|\\./
    \ end=/)/
    \ contains=@bshCmdSubList
    \ extend

syntax cluster bshCmdSubList contains=
    \ bshArithmeticExpansion,
    \ bshCmdSub,
    \ bshComment,
    \ bshControlOperator,
    \ bshExSingleQuote,
    \ bshHereDocExpanded,
    \ bshHereDocLiteral,
    \ bshMayBeCmd,
    \ bshNumber,
    \ bshOption,
    \ bshParameterExpansion,
    \ bshProcessSub,
    \ bshRedirection,
    \ bshString,
    \ bshTestBracketLastArgument,
    \ bshVariableSpecial

syntax match bshSource /^\.\s/
syntax match bshSource /\s\.\s/

# String And Character Constants: {{{1

# A number  followed by `>`  or `<` is part  of a redirection  operator (which
# should  have priority  when highlighting  the  number, because  it's a  more
# meaningful token).
syntax match bshNumber /\_[ (]\@1<=\<\d\+\>[><]\@!\|\[\@1<=-\=\d\+\]\@=/
syntax match bshNumber /\_[ (]\@1<=\<-\=\d\+\%(\.\d\+\)*\>/
syntax match bshSpecial /[^\\]\(\\\\\)*\zs\\\o\o\o\|\\x\x\x\|\\u\x\{4}\|\\c[^"]\|\\[abefnrtv]/ contained
syntax match bshSpecial /^\(\\\\\)*\zs\\\o\o\o\|\\x\x\x\|\\c[^"]\|\\[abefnrtv]/ contained
syntax region bshExSingleQuote matchgroup=bshQuote start=/\$'/ skip=/\\\\\|\\./ end=/'/ contains=bshStringSpecial,bshSpecial nextgroup=bshSpecialNxt
syntax region bshExDoubleQuote matchgroup=bshQuote start=/\$"/ skip=/\\\\\|\\.\|\\"/ end=/"/ contains=bshStringSpecial,bshSpecial nextgroup=bshSpecialNxt

syntax region bshString
    \ start=/"/
    \ skip=/\\\\\|\\"/
    \ end=/"/
    \ keepend
    \ contains=bshCmdSub,bshParameterExpansion,bshArithmeticExpansion
syntax region bshString start=/'/ skip=/'\\''/ end=/'/ keepend

syntax match bshStringSpecial /[^[:print:][:blank:]]/ contained
syntax match bshStringSpecial /[^\\]\zs\%(\\\\\)*\(\\[\\"'`$()#]\)\+/
syntax match bshSpecial /^\%(\\\\\)*\\[\\"'`$()#]/
syntax match bshSpecialNxt contained /\\[\\"'`$()#]/

# Comments: {{{1

syntax match bshComment /#.*$/  contains=bshTodo,@Spell
syntax match bshTodo contained /\<\%(FIXME\|TODO\|NOTE\)\ze:\=\>/

# Identifiers: {{{1

# `man bash /^\s*ARITHMETIC EVALUATION$/;/^\s*assignment$`:
#     = *= /= %= += -= <<= >>= &= ^= |=
var assignment_pat: string = '[-+*/%&^|]\==\|<<=\|>>='

#     array[idx]=...
#          ^---^
var subscript: string = '\[[^]]*\]'

execute $'syntax match bshVariablePosition /\<\%(\h\w*\%({subscript}\)\={assignment_pat}\)\@=/ nextgroup=bshVariable,bshVariableSpecial'
execute $'syntax match bshVariable /\h\w*/ contained nextgroup=bshVarAssign,bshParameterSubscript'
execute $'syntax match bshVariableSpecial /\<\%({lang.special_variables}\)\>/ contained nextgroup=bshVarAssign,bshParameterSubscript'
execute $'syntax match bshVarAssign /{assignment_pat}/ contained nextgroup=bshExDoubleQuote,bshSingleQuote,bshExSingleQuote'

# Additional sh Keywords: {{{1

syntax keyword bshReturnExit contained exit return
syntax keyword bshConditional contained elif else then

# Sync {{{1

syntax sync minlines=100

# This fixes some issue caused by a multiline string:{{{
#
#     x="$(
#         ...
#     )"
#}}}
syntax sync match bshSync grouphere NONE /^dummy pattern$/

# Default Highlighting: {{{1
# NOTE: All our highlight groups must be prefixed with `bsh`, not `sh`, nor `bash`.{{{
#
# Otherwise, there would be conflicts with the default `sh.vim` syntax plugin.
#
# For example, suppose  the first shell script that you  open uses `#!/bin/sh`
# as  a shebang.   Vim  will source  `$VIMRUNTIME/syntax/sh.vim`, which  might
# define `bashSpecialVariables`:
#
#     hi def link bashSpecialVariables	shShellVariables
#
# Later, if  your own  bash syntax script  tries to reset  this HG,  using the
# `default` argument (so that it survives a `:highlight clear`), it will fail.
#}}}

highlight default link bshCmdSubRegion PreProc
highlight default link bshEscapedMetacharacter Special
highlight default link bshExSingleQuote bshSingleQuote
highlight default link bshFunction Delimiter
highlight default link bshOption Constant
highlight default link bshSingleQuote bshString
highlight default link bshSource bshOperator
highlight default link bshSpecialNxt bshSpecial
highlight default link bshStringSpecial bshSpecial

highlight default link bshVariableSpecial Italic

highlight default link bshComment Comment
highlight default link bshConditional Conditional
highlight default link bshNumber Number
highlight default link bshOperator Operator
highlight default link bshRepeat Repeat
highlight default link bshSpecial Special
highlight default link bshString String
highlight default link bshTodo Todo

highlight default link bshArithmeticAssignment Identifier
highlight default link bshArithmeticOperators bshOperator
highlight default link bshBreakContinue Repeat
highlight default link bshCase bshConditional
highlight default link bshCaseEnd bshCase
highlight default link bshCaseIn bshConditional
highlight default link bshCaseOperator bshCase
highlight default link bshCaseParen bshConditional
highlight default link bshCasePatternAlternation bshSpecial
highlight default link bshControlOperator bshOperator
highlight default link bshDone bshRepeat
highlight default link bshFor bshRepeat
highlight default link bshForDo bshRepeat
highlight default link bshForIn bshRepeat
highlight default link bshGroupCommandStart bshFunction
highlight default link bshGroupCommandEnd bshFunction
highlight default link bshFunctionKeyword Keyword
highlight default link bshHereDocExpanded bshString
highlight default link bshHereDocLiteral bshString
highlight default link bshIf bshConditional
highlight default link bshParameter Identifier
highlight default link bshQuote bshString
highlight default link bshRedirection bshOperator
highlight default link bshReservedWordBang bshOperator
highlight default link bshReturnExit bshFunctionKeyword
highlight default link bshTest bshConditional
highlight default link bshTestBracketLastArgument bshTest
highlight default link bshVarAssign Identifier
highlight default link bshWhile bshRepeat
highlight default link bshWhileDo bshWhile

highlight default link bshParameterArrayKeys Identifier
highlight default link bshParameterArrayKeysHow PreProc
highlight default link bshParameterBang Operator
highlight default link bshParameterCaseModification Delimiter
highlight default link bshParameterDefaultValue String
highlight default link bshParameterExpansion Identifier
highlight default link bshParameterIfUnset Delimiter
highlight default link bshParameterLength Identifier
highlight default link bshParameterMatchingPrefix Identifier
highlight default link bshParameterMatchingPrefixHow PreProc
highlight default link bshParameterNumberSign Operator
highlight default link bshParameterOffsetOrLength Number
highlight default link bshParameterSubstitutionReplacement String
highlight default link bshParameterPrefixOrSuffix String
highlight default link bshParameterRemovePrefixOrSuffix Delimiter
highlight default link bshParameterSubscriptSpecial PreProc
highlight default link bshParameterSubstitutionPattern String
highlight default link bshParameterSubstring Delimiter
highlight default link bshParameterTransformation Delimiter
highlight default link bshParameterTransformationOperator Operator

# This block must come at the very end.{{{
#
# Otherwise,  the  first  time  we  load  a bash  script,  our  HGs  might  be
# unexpectedly derived from cleared HGs.
#}}}
if hlget('bshVariableSpecialReference')->get(0, {})->get('cleared')
    Derive('bshVariableSpecialReference', 'bshParameterName',
        {gui: {italic: true}, term: {italic: true}, cterm: {italic: true}})
endif

b:current_syntax = 'bash'
