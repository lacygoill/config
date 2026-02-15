vim9script

if exists('b:current_syntax')
    finish
endif

syntax match naviComment /^;.*$/
syntax match naviExtension /^@\s.*$/

syntax match naviTags /^%\s.*/
syntax match naviCommandDescription /^#.*$/ contains=@Spell,naviCommandDescriptionTooLong
# I think fzf ignores text which is not displayed in the window.{{{
#
# This can  prevent you from  finding a shell  snippet after typing  some text
# which is too far away from the start of the line.
#
# Let's make  sure that  we are  aware of  this pitfall,  whenever we  write a
# command description which is too long.
#}}}
# Warning: The number might need to be updated.{{{
#
# Right now, it seems the limit is a bit after the 100th character.
# In the past, it was a bit after the 80th character.
# The difference between now and then is that we no longer display the snippet
# column:
#
#     # ~/.config/navi/config.yaml
#     snippet:
#       width_percentage: 0
#                         ^
#       min_width: 0
#                  ^
#
# But we might change yet again the width of the columns.
# If so, find out empirically how far  `fzf(1)` can match our input query, and
# update the number here accordingly.
#}}}
syntax match naviCommandDescriptionTooLong  /\%97c.*$/ contains=@Spell contained
# Warning: Do *not* change the name of this syntax group.{{{
#
# We assume  that it has  this particular name in  `vim-doc` (so that  the `K`
# mapping works as expected on the name of a shell command).
#}}}
syntax match naviCommandShell /^[^;%@#$].*/ contains=@naviShell,naviArgumentPlaceHolder,naviCommentShell
# Warning: Do *not* rename the name of this syntax group like this: `naviShellComment`{{{
#
# We need it  to start with `naviComment`  for custom styles to  be applied in
# shell comments (in addition to navi comments).
#}}}
syntax match naviCommentShell /^\s\+#.*$/ contains=@Spell

syntax match naviArgumentPlaceHolder /<\w\%(\w\|-\)*>/ contained contains=naviArgumentDelimiter
syntax match naviArgumentDelimiter /[<>]/ contained
syntax match naviArgumentLeader /^\$/ nextgroup=naviArgumentIdentifier skipwhite
syntax match naviArgumentIdentifier /\w\%(\w\|-\)*/ contained nextgroup=naviArgumentValue
# `end=/[^\\]$/`: support line continuation.
# `keepend`: don't let a contained match (string, argument reference) obscure a match for the end pattern.{{{
#
# For example:
#
#     $ unit: systemctl list-unit-files --no-legend --plain | awk '{ print $1 }'
#                                                                 ^------------^
#
# Here, we don't want the trailing string to prevent the navi argument's value
# from ending.  Otherwise, the next line would be wrongly consumed.
#}}}
syntax region naviArgumentValue
    \ start=/:/
    \ end=/[^\\]$/
    \ contained
    \ contains=naviArgumentReference,naviArgumentString
    \ keepend
syntax match naviArgumentReference /$\%(\d\+\>\)\@!\w\%(\w\|-\)*/ contained
# You can reference a previously supplied navi argument (`$arg`) only inside a
# double-quoted  string.  I  guess  navi  merely sets  a  variable inside  the
# shell's environment;  it doesn't  expand `$arg`  itself before  invoking the
# shell.
syntax region naviArgumentString
    \ start=/"/
    \ skip=/\\\\\|\\"/
    \ end=/"/
    \ contains=naviArgumentReference
    \ keepend
    \ oneline
syntax region naviArgumentString
    \ start=/'/
    \ skip=/\\\\\|\\'/
    \ end=/'/
    \ keepend
    \ oneline

syntax keyword naviTodo TODO FIXME

highlight default link naviArgumentDelimiter Delimiter
highlight default link naviArgumentIdentifier Identifier
highlight default link naviArgumentLeader PreProc
highlight default link naviArgumentPlaceHolder Identifier
highlight default link naviArgumentReference PreProc
highlight default link naviArgumentString String
highlight default link naviCommandDescription String
highlight default link naviCommandDescriptionTooLong SpellRare
highlight default link naviComment Comment
highlight default link naviCommentShell Comment
highlight default link naviExtension Include
highlight default link naviTags Tag
highlight default link naviTodo Todo

b:current_syntax = 'navi'
