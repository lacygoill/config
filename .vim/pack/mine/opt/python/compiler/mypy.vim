vim9script

g:current_compiler = 'mypy'

CompilerSet errorformat=%f:%l:\ %trror:\ %m,%f:%l:\ %tote:\ %m,%f:%l:%m,%-G%.%#
CompilerSet makeprg=mypy\ --strict\ %:p:S
