vim9script

export def UndoFtplugin()
    unlet! b:fex_last_line
    if exists('#FexPrintMetadata')
        autocmd! FexPrintMetadata * <buffer>
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
    nunmap <buffer> tp
enddef
