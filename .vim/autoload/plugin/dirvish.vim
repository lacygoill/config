fu plugin#dirvish#undo_ftplugin() abort
    unlet! b:fex_last_line
    if exists('#fex_print_metadata')
        au! fex_print_metadata * <buffer>
    endif

    nunmap <buffer> -M
    nunmap <buffer> -m
    xunmap <buffer> -m

    nunmap <buffer> ?
    nunmap <buffer> gh
    nunmap <buffer> h
    nunmap <buffer> l
    nunmap <buffer> p
    nunmap <buffer> q
    nunmap <buffer> (
    nunmap <buffer> )
endfu

