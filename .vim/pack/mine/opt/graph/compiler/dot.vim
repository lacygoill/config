vim9script

g:current_compiler = 'dot'

# adapted from $VIMRUNTIME/compiler/dot.vim
CompilerSet makeprg=dot\ -T$*\ %:p:S\ -o\ %:p:r:S.$*

# Original_value:
#     setlocal errorformat=%EError:\ %f:%l:%m,%+Ccontext:\ %.%#,%WWarning:\ %m
#
#             from https://github.com/wannesm/wmgraphviz.vim/blob/eff46932ef8324ab605c18619e94f6b631d805e2/ftplugin/dot.vim#L560

CompilerSet errorformat=%+EError:\ %f:\ %.%#\ %l\ %.%#
#                       ^^^             ^--^
#                        |              stands for the regex .*
#                        |
#                        + start of a multi-line error message
#
#                          It  works  even though,  atm,  our  error messages  are  not
#                          multi-line, which  seems to indicate  that %E can work  on a
#                          single line error message too.
#
#                          The `+` includes the whole matching line in the %m error string.
#                          It works even  though we don't use any `%m`,  which seems to
#                          indicate that you don't need a `%m` in a format using `%+`.
#}}}
# This value is useful for an error like this:
#
#     Error: /tmp/file.dot: syntax error in line 40 near '['˜
