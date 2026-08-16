vim9script

# The default syntax plugin wrongly highlights the word `display`:{{{
#
#     syntax keyword xdefaultsTodo contained TODO FIXME XXX display
#                                                           ^-----^
#}}}
syntax clear xdefaultsTodo
syntax keyword xdefaultsTodo contained TODO FIXME XXX

#     ! support \
#     multiline \
#     comment
syntax region xdefaultsComment start=/^!.*\\$/ end=/[^\\]$/ contains=@Spell,xdefaultsTodo

# The "translations" resource seems to be special.{{{
#
# For some reason, this doesn't work:
#
#              ✘
#     v-----------------v
#     XTerm*.translations: #override \
#     ...
#
# We need to write this instead:
#
#                ✔
#     v----------------------v
#     XTerm.VT100.translations: #override \
#     ...
#}}}
syntax match xdefaultsError /^xterm\*\.translations:\c/
highlight default link xdefaultsError ErrorMsg

# If we write some commented  code which accidentally contains `/*`, `xrdb(1)`
# will wrongly think it's the start of a C-style comment.
# This could cause an error:
#
#     !     error: unterminated comment
#
# Let us know so that we remember to write `*/` at the end of the comment.
syntax match xdefaultsCStyleComment +/\*+ containedin=ALL
syntax match xdefaultsCStyleComment +\*/+ containedin=ALL
highlight default link xdefaultsCStyleComment SpellRare
