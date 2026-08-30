vim9script

g:current_compiler = 'tmux'

CompilerSet makeprg=tmux\ source-file\ -n\ %:p:S

CompilerSet errorformat=%f:%l:%m
