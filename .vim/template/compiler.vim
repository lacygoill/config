" Old Vim versions don't automatically define `:CompilerSet`.
if exists(':CompilerSet') !=# 2
    com -nargs=* CompilerSet setl <args>
endif

" CompilerSet efm=
" CompilerSet mp=