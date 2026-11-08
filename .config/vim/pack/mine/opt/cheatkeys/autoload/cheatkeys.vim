vim9script

# Interface {{{1
export def UndoFtplugin() #{{{2
    set bufhidden<
    set buflisted<
    set commentstring<
    set number<
    set relativenumber<
    set readonly<
    set spell<
    set swapfile<
    set textwidth<
    set winfixwidth<
    set wrap<

    nunmap <buffer> q
enddef
