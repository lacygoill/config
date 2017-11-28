" Options {{{1

augroup my_tmux
    au! *            <buffer>
    au  BufWinEnter  <buffer>  setl fdm=marker
                           \ | let &l:fdt = 'tmux#fold_text()'
                           \ | setl cocu=nc
                           \ | setl cole=3
augroup END

" break lines beyond 80 characters
setl tw=80

" Teardown {{{1

let b:undo_ftplugin =         get(b:, 'undo_ftplugin', '')
                    \ .(empty(get(b:, 'undo_ftplugin', '')) ? '' : '|')
                    \ ."
                    \   setl cocu< cole< fdm< fdt< tw<
                    \|  exe 'au!  my_tmux * <buffer>'
                    \ "
