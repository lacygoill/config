vim9script

import autoload './lazy.vim'

export def Hlm(key: string)
    var cnt: number = v:count
    if cnt != 0 && key != 'M'
        execute 'normal! ' .. cnt .. key
    else
        lazy.Compute()
        execute 'normal! ' .. {H: 'zM', L: 'zR', M: 'zMzv'}[key] .. 'zz'
    endif
enddef
