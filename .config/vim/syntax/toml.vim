vim9script

if exists('b:current_syntax')
    finish
endif

# Alternative:
# https://github.com/cespare/vim-toml/blob/master/syntax/toml.vim

# Syntax Rules {{{1
# Start of line {{{2

# Whitelist of tokens which are allowed right at the start of a line.
syntax match tomlStartOfLine /^/
    \ nextgroup=
    \     tomlBareKey,
    \     tomlComment,
    \     tomlQuotedKey,
    \     tomlTable
    \ skipwhite

# Comment {{{2

if expand('%:t') == 'redshift.conf'
    syntax match tomlComment /;.*/ contained contains=@Spell,tomlTodo
else
    # https://toml.io/en/v1.0.0#comment
    syntax match tomlComment /#.*/ contained contains=@Spell,tomlTodo
    # inline comments
    syntax match tomlComment /#.*/ contains=@Spell,tomlTodo
endif

# Todo {{{2

syntax keyword tomlTodo TODO FIXME XXX BUG contained

# Assignment operator {{{2

syntax match tomlOperAssign /=/ contained nextgroup=@tomlValue skipwhite

# Value {{{2

syntax cluster tomlValue contains=
    \ tomlArray,
    \ tomlBasicString,
    \ tomlBoolean,
    \ tomlDate,
    \ tomlFloat,
    \ tomlInteger,
    \ tomlLiteralString,
    \ tomlMultiLineString,

# String {{{2
# https://toml.io/en/v1.0.0#string

syntax region tomlBasicString
    \ matchgroup=tomlDelim
    \ start=/"/
    \ skip=/\\\\\|\\"/
    \ end=/"/
    \ contained
    \ contains=tomlEscapeSequence
    \ oneline

syntax region tomlLiteralString
    \ matchgroup=tomlDelim
    \ start=/'/
    \ end=/'/
    \ contained
    \ oneline

# Order: Must be after `tomlLiteralString`.
# In the end pattern, the negative lookahead is necessary to support this:{{{
#
#                    the first quote is part of the multiline string;
#                    not of the end delimiter
#                                                                 ✘
#                                                                vvv
#     str7 = """"This," she said, "is just a pointless statement.""""
#                                                                 ^^^
#                                                                  ✔
#}}}
syntax region tomlMultiLineString
    \ matchgroup=tomlDelim
    \ start=/"""/
    \ skip=/\\\\\|\\"/
    \ end=/""""\@!/
    \ contained
    \ contains=tomlEscapeSequence,tomlLineEndingBackslash

syntax region tomlMultiLineString
    \ matchgroup=tomlDelim
    \ start=/'''/
    \ end=/''''\@!/
    \ contained

syntax match tomlEscapeSequence /\\[btnfr"\\]/ contained
syntax match tomlEscapeSequence /\\u\x\{4}/ contained
syntax match tomlEscapeSequence /\\U\x\{8}/ contained

syntax match tomlLineEndingBackslash /\\$/ contained

# Key {{{2
# https://toml.io/en/v1.0.0#keys

# Order: This section must be after the one dedicated to strings.
# This  is to  support  a quoted  key  inside  an array;  the  latter should  be
# highlighted as a key; not as a string.

syntax match tomlBareKey /[-a-zA-Z0-9_]\+\%(\s*[=.]\)\@=/
    \ nextgroup=tomlDottedKey,tomlOperAssign
    \ skipwhite
    \ contained

syntax region tomlQuotedKey
    \ start=/"/
    \ skip=/\\\\\|\\"/
    \ end=/"\%(\s*[=.]\)\@=/
    \ contained
    \ nextgroup=tomlDottedKey,tomlOperAssign
    \ oneline
    \ skipwhite

syntax region tomlQuotedKey
    \ start=/'/
    \ end=/'\%(\s*[=.]\)\@=/
    \ contained
    \ nextgroup=tomlDottedKey,tomlOperAssign
    \ oneline
    \ skipwhite

syntax match tomlDottedKey /\./ contained nextgroup=tomlBareKey,tomlQuotedKey

# Integer {{{2

# https://toml.io/en/v1.0.0#integer
syntax match tomlInteger /[-+]\=[1-9][0-9_]*\|\<[-+]\=0\>/ contained
syntax match tomlInteger /0x\x\%(\x\|_\)*/ contained
syntax match tomlInteger /0o\o\%(\o\|_\)*/ contained
syntax match tomlInteger /0b[01][01_]*/ contained

# Float {{{2

# https://toml.io/en/v1.0.0#float
syntax match tomlFloat /[-+]\=\d[0-9_]*\.\@=/ nextgroup=tomlFloatExponent,tomlFloatFractional
syntax match tomlFloat /[-+]\=\<\%(inf\|nan\)\>/
syntax match tomlFloatFractional /\.\d[0-9_]*/ contained nextgroup=tomlFloatExponent
syntax match tomlFloatExponent /[eE][-+]\=\d[0-9_]*/ contained

# Boolean {{{2

# https://toml.io/en/v1.0.0#boolean
syntax keyword tomlBoolean true false contained

# Date {{{2

# https://toml.io/en/v1.0.0#local-date
syntax match tomlDate /\d\{4}-\d\d-\d\d/ contained

# https://toml.io/en/v1.0.0#local-time
syntax match tomlDate /\d\d:\d\d:\d\d\%(\.\d\+\)\=/ contained

# https://toml.io/en/v1.0.0#offset-date-time
# https://toml.io/en/v1.0.0#local-date-time
execute 'syntax match tomlDate'
    .. ' /'
    # local date
    .. '\d\{4}-\d\d-\d\d'
    # delimiter between date and time
    .. '[T ]'
    # local time, with optional fractional seconds
    .. '\d\d:\d\d:\d\d\%(\.\d\+\)\='
    # a possible offset
    .. '\%('
    # “zero hour offset” also known as “Zulu time” (UTC)
    ..     'Z'
    # “hour:minutes” offset
    ..     '\|' .. '[+-]\d\d:\d\d'
    .. '\)\='
    .. '/'
    .. ' contained'

# Array {{{2

# https://toml.io/en/v1.0.0#array
syntax region tomlArray
    \ start=/\[/
    \ end=/]/
    \ contained
    \ contains=
    \     @tomlValue,
    \     tomlBareKey,
    \     tomlComment,
    \     tomlInlineTable,
    \     tomlQuotedKey

# Table {{{2

# https://toml.io/en/v1.0.0#table
syntax region tomlTable start=/\[/ end=/]/ oneline

# https://toml.io/en/v1.0.0#array-of-tables
syntax region tomlArrayOfTables start=/\[\[/ end=/]]/ oneline

# https://toml.io/en/v1.0.0#inline-table
syntax region tomlInlineTable start=/{/ end=/}/
    \ contains=
    \     @tomlValue,
    \     tomlInlineTable,
    \     tomlBareKey,
    \     tomlQuotedKey
    \ oneline

# Syncing {{{2

syntax sync minlines=200
#}}}1
# Highlight groups {{{1

highlight default link tomlArrayOfTables tomlTable
highlight default link tomlBareKey Identifier
highlight default link tomlBasicString String
highlight default link tomlBoolean Boolean
highlight default link tomlComment Comment
highlight default link tomlDate Constant
highlight default link tomlDelim Delimiter
highlight default link tomlEscapeSequence SpecialChar
highlight default link tomlFloat Number
highlight default link tomlFloatExponent Number
highlight default link tomlFloatFractional Number
highlight default link tomlInteger Number
highlight default link tomlLineEndingBackslash SpecialChar
highlight default link tomlLiteralString String
highlight default link tomlMultiLineString String
highlight default link tomlQuotedKey Identifier
highlight default link tomlTable Title
highlight default link tomlTodo Todo
#}}}1

b:current_syntax = 'toml'
