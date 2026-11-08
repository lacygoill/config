vim9script

g:current_compiler = 'desktop-file-validate'

# Unfortunately,  the output  of  `desktop-file-validate(1)`  can not  produce
# valid quickfix entries, because the line number is missing:
#
#     /path/to/file.desktop: error: ...
#
#     CompilerSet errorformat=%f:\ %trror:\ %m
#                             ^--------------^
#                              %l is missing

CompilerSet makeprg=desktop-file-validate\ %p:%S
