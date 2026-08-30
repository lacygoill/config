vim9script

if exists('b:current_syntax')
    finish
endif

syntax iskeyword @,48-57,_,192-255,@-@

# A bunch of useful Awk keywords
# AWK ref. p. 188
syntax keyword awkStatement delete exit
syntax keyword awkStatement getline next
syntax keyword awkStatement print printf

syntax keyword awkFunction function return
highligh default link awkFunction Keyword

# GAWK ref. Chapter 7-9
syntax keyword awkStatement case default switch nextfile

# GAWK ref. Chapter 2.7, Including Other Files into Your Program
# GAWK ref. Chapter 2.8, Loading Dynamic Extensions into Your Program
# GAWK ref. Chapter 15, Namespaces
# Directives
syntax keyword awkStatement @include @load @namespace

# string functions
syntax keyword awkFunctionBuiltin gsub index length match split sprintf sub substr tolower toupper

# time functions
syntax keyword awkFunctionBuiltin mktime strftime systime

# arithmetic functions
syntax keyword awkFunctionBuiltin atan2 cos exp int log rand sin sqrt srand

syntax match awkFunctionUser /\<\h\w*(\@=/
import 'vim9SyntaxUtil.vim' as util
const Derive: func = util.Derive
Derive('awkFunctionUser', 'Function', {gui: {bold: true}, term: {bold: true}, cterm: {bold: true}})

syntax keyword awkConditional if else
syntax keyword awkRepeat while for do break continue

syntax keyword awkTodo contained TODO FIXME NOTE

syntax keyword awkPatterns BEGIN END BEGINFILE ENDFILE

syntax keyword awkVariables ARGC ARGV CONVFMT ENVIRON FILENAME FNR FS NF NR OFMT OFS ORS RLENGTH RS RSTART SUBSEP

# Arithmetic operators: +, and - take care of ++, and --
syntax match awkOperator #+\|-\|\*\|/\|%#
syntax match awkOperAssign #+=\|-=\|\*=\|/=\|%=\|=#
syntax match awkOperator /\^\|\^=/
syntax match awkOperator /[<>]=\=/

# Octal format character.
syntax match awkSpecialCharacter display contained /\\[0-7]\{1,3\}/
# Hex format character.
syntax match awkSpecialCharacter display contained /\\x[0-9A-Fa-f]\+/

syntax match awkFieldVars /\$\d\+/

# catch errors caused by wrong parenthesis
syntax region awkParen transparent start=/(/ end=/)/ contains=
    \ ALLBUT,
    \ awkParenError,
    \ awkSpecialCharacter,
    \ awkArrayArray,
    \ awkTodo,
    \ awkCharClass

syntax match awkParenError display /)/
#syn match awkInParen display contained /[{}]/

# 64 lines for complex &&'s, and ||'s in a big "if"
syntax sync ccomment awkParen maxlines=64

# Search strings
syntax region awkSearch oneline start="^[[:blank:]]*/"ms=e start="\(,\|!\=\~\)[ \t]*/"ms=e skip="\\\\\|\\/" end="/" contains=awkSpecialCharacter
syntax region awkSearch oneline start="[[:blank:]]*/"hs=e skip="\\\\\|\\/" end="/" contains=awkSpecialCharacter

syntax match awkCharClass contained "\[:[^:\]]*:\]"

# String and Character constants
# Highlight special characters (those which have a backslash) differently
syntax region awkString start=+"+ skip=+\\\\\|\\"+ end=+"+ contains=@Spell,awkSpecialCharacter,awkSpecialPrintf

# Some of these combinations may seem weird, but they work.
syntax match awkSpecialPrintf contained "%[-+ #]*\d*\.\=\d*[cdefgiosuxEGX%]"

# Numbers, allowing signs (both -, and +)
# Integer number.
syntax match awkNumber display "[+-]\=\<\d\+\>"
# Floating point number.
syntax match awkFloat display "[+-]\=\<\d\+\.\d+\>"
# Floating point number, starting with a dot.
syntax match awkFloat display "[+-]\=\<.\d+\>"
syntax case ignore
#floating point number, with dot, optional exponent
syntax match awkFloat display "\<\d\+\.\d*\(e[-+]\=\d\+\)\=\>"
#floating point number, starting with a dot, optional exponent
syntax match awkFloat display "\.\d\+\(e[-+]\=\d\+\)\=\>"
#floating point number, without dot, with exponent
syntax match awkFloat display "\<\d\+e[-+]\=\d\+\>"
syntax case match

#syn match awkIdentifier "\<[a-zA-Z_][a-zA-Z0-9_]*\>"

# Comparison expressions.
syntax match awkOper "==\|>=\|=>\|<=\|=<\|\!="
syntax match awkOper "\~\|\!\~"
# We assert the presence of a character after the colon, to not match this:{{{
#
#     switch (expr)
#     case "value":
#                 ^
#}}}
syntax match awkOper "?\|:.\@="
syntax keyword awkForIn in

# Boolean Logic (OR, AND, NOT)
syntax match awkBoolLogic "||\|&&\|\!=\@!"

# This is overridden by less-than & greater-than.
# Put this above those to override them.
# Put this in a 'match "\<printf\=\>.*;\="' to make it not override
# less/greater than (most of the time), but it won't work yet because
# keywords always have precedence over match & region.
# File I/O: (print foo, bar > "filename") & for nawk (getline < "filename")
#syn match awkFileIO contained ">"
#syn match awkFileIO contained "<"

# Expression separators: ';' and ','
syntax match awkSemicolon ";"

syntax match awkComment "#.*" contains=@Spell,awkTodo

syntax match awkLineSkip "\\$"

# Highlight array element's (recursive arrays allowed).
# Keeps nested array names' separate from normal array elements.
# Keeps numbers separate from normal array elements (variables).
syntax match awkArrayArray contained "[^][,[:blank:]]\+\["me=e-1
syntax region awkArray transparent start="\[" end="\]" contains=awkArray,awkArrayArray,awkNumber,awkFloat,awkFieldVars,awkFunctionBuiltin,awkString

# 10 should be enough.
# (for the few instances where it would be more than "oneline")
syntax sync ccomment awkArray maxlines=10

# Define the default highlighting.
highlight default link awkBoolLogic Operator
highlight default link awkCharClass awkNestRegExp
highlight default link awkComment Comment
highlight default link awkConditional Conditional
highlight default link awkOper Operator
highlight default link awkFieldVars Identifier
highlight default link awkFileIO Special
highlight default link awkFloat Float
highlight default link awkForIn awkRepeat
highlight default link awkFunctionBuiltin Function
highlight default link awkIdentifier Identifier
highlight default link awkLineSkip Special
highlight default link awkNestRegExp Keyword
highlight default link awkNumber Number
highlight default link awkOperAssign Identifier
highlight default link awkOperator Operator
highlight default link awkPatterns Title
highlight default link awkRepeat Repeat
highlight default link awkSearch String
highlight default link awkSemicolon Special
highlight default link awkSpecialCharacter Special
highlight default link awkSpecialPrintf Special
highlight default link awkStatement Statement
highlight default link awkString String
highlight default link awkTodo Todo
highlight default link awkVariables Identifier

# Change this if you want nested array names to be highlighted.
highlight default link awkArrayArray awkArray
highlight default link awkParenError awkError
highlight default link awkInParen awkError
highlight default link awkError Error

b:current_syntax = 'awk'
