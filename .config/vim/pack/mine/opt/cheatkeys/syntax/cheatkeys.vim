vim9script

if exists('b:current_syntax')
    finish
endif

syntax case ignore
syntax sync fromstart
var fmr_start: string
var fmr_end: string
[fmr_start, fmr_end] = &l:foldmarker
    ->split(',')
    ->map((_, v: string) => v .. '\d*')

syntax match cheatkeysDescr /\%1v.*\%40v./
# Why `\%<81v` instead of `\%80v`?{{{
#
# There could be no mode character in the 80th column.
# In which case, the command will end somewhere before the 80th column.
#}}}
syntax match cheatkeysCommand /\%41v.*\%<81v./ contains=cheatkeysMode,cheatkeysAngle,cheatkeysDblAngle
execute 'syntax match cheatkeysSection /^.*' .. fmr_start .. '$/ contains=cheatkeysDblAngle,cheatkeysFoldMarkerStart'
execute 'syntax match cheatkeysFoldMarkerStart /' .. fmr_start .. '/ contained conceal'
execute 'syntax match cheatkeysFoldMarkerEnd   /^' .. fmr_end .. '$/ conceal'

syntax match cheatkeysMode     /\C[NICVTOMG*]\+\%>80v/ contained
syntax match cheatkeysAngle    /‹[^›[:blank:]]\+›/ contained
syntax match cheatkeysDblAngle /«[^»[:blank:]]\+»/ contained
syntax match cheatkeysComment  /^#.*$/ contains=@Spell,cheatkeysDblAngle,cheatkeysFoldMarkerStart

highlight default link cheatkeysDescr Normal
highlight default link cheatkeysCommand Constant
highlight default link cheatkeysSection Title
highlight default link cheatkeysMode Type
highlight default link cheatkeysAngle Identifier
highlight default link cheatkeysDblAngle Label
highlight default link cheatkeysComment Comment

b:current_syntax = 'cheatkeys'
