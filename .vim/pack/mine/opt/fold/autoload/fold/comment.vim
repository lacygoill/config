vim9script

import autoload 'comment/object.vim'

export def Main(type = ''): string
    if type == ''
        &operatorfunc = Main
        return 'g@l'
    endif

    normal! V
    object.Main()
    execute "normal! \<Esc>"
    var cml: string = '\V'
        ..  &commentstring->matchstr('\S*\ze\s*%s')->escape('\')
        .. '\m'
    if getline("'>") !~ '^\s*' .. cml .. '\s*$'
        execute "normal! o\<Esc>"
    endif
    normal! V
    object.Main()
    normal! zf
    return ''
enddef
