vim9script

export def UndoFtplugin()
    set bufhidden<
    set buftype<
    set foldlevel<
    set winfixwidth<
    unlet! b:title_like_in_markdown
    nunmap <buffer> q
    nunmap <buffer> R
enddef
