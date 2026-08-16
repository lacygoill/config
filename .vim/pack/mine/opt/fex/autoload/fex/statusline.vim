vim9script

export def Curdir(): string
    return get(b:, 'fex_curdir', '') == '/'
        ? '/'
        : get(b:, 'fex_curdir', '')->fnamemodify(':t')
enddef
