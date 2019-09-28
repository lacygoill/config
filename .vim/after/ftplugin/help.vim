" TODO:
" Maybe we should move this code in:
"
"     ~/.vim/plugged/vim-help/after/ftplugin/help.vim
"
" And write a folding expression suited for all documentation files.
"
" Also, it would be nice if we had different levels of indentation between titles
" and subtitles, like in our markdown notes.

if expand('%:p') =~# $HOME.'/.vim/doc/misc/\%(notes\|galore\)'
    setl fdm=expr
    let &l:fdt = s:snr().'fold_text()'
    let &l:fde = s:snr().'fold_expr()'
    sil exe 'norm coH'
endif

fu! s:fold_expr() abort "{{{1
    return getline(v:lnum) =~# '^=\+$'
       \ ?     '>1'
       \ :     '='
endfu

fu! s:fold_text() abort "{{{1
    return getline(nextnonblank(v:foldstart+1))
endfu

fu! s:snr() "{{{1
    return matchstr(expand('<sfile>'), '.*\zs<SNR>\d\+_')
endfu

" teardown {{{1

let b:undo_ftplugin = get(b:, 'undo_ftplugin', 'exe')
    \ . "
    \ | setl fde< fdm< fdt<
    \ "

