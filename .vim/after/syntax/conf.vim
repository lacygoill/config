vim9script

syntax match confHexColor /#\x\{6}\>/
highlight default link confHexColor Constant

syntax match confNumber /\<\d\+\>/
highlight default link confNumber Number

if expand('%:p') == $LESSKEY->fnamemodify(':r')
    # From `man lesskey /DESCRIPTION`:{{{
    #
    #    > The  input  file consists of one or more sections.  Each section starts
    #    > with a line that identifies the type  of  section.   Possible  sections
    #    > are:
    #    >
    #    > #command
    #    >         Defines new command keys.
    #    >
    #    > #line-edit
    #    >         Defines new line-editing keys.
    #    >
    #    > #env   Defines environment variables.
    #    >
    #    > Blank  lines  and  lines which start with a pound sign (#) are ignored,
    #    > except for the special section header lines.
    #}}}
    syntax match confLessSection /^#\%(command\|line-edit\|env\)$/
    highlight default link confLessSection PreProc

elseif expand('%:p:t') == 'kitty.conf'
    syntax match kittyOptionName /^\s*[a-z0-9_]\+\s\@=/ nextgroup=@kittyOptionValue skipwhite
    syntax cluster kittyOptionValue contains=kittyNumberValue,kittyStringValue
    syntax match kittyStringValue /[^#[:blank:]].*$/ contained
    syntax match kittyNumberValue /\d\+\.\=\d*$/ contained

    syntax match kittyMapCmd /^\s*map\>/ nextgroup=kittyMapLhs skipwhite
    syntax match kittyMapLhs /\S\+/ contained contains=kittyMapDelimiter
    syntax match kittyMapDelimiter />/ contained

    highlight default link kittyOptionName Type
    highlight default link kittyStringValue String
    highlight default link kittyNumberValue Number
    highlight default link kittyMapCmd Statement
    highlight default link kittyMapLhs Special
    highlight default link kittyMapDelimiter Delimiter
endif
