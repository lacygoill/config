vim9script

# Interface {{{1
export def Main(how: string, type = ''): string #{{{2
    if type == ''
        &operatorfunc = function(Main, [how])
        return 'g@'
    endif

    var cnt: number = v:count1
    for _ in range(1, cnt)
        var range: string = ':' .. line("'[") .. ',' .. line("']")
        if how == 'more'
            execute 'silent keepjumps keeppatterns ' .. range .. 'substitute/^\(#\+\)/\1#/e'
        else
            execute 'silent keepjumps keeppatterns ' .. range .. 'substitute/^\(#\+\)#/\1/e'
        endif
    endfor
    getpos("'[")[1 : 2]->cursor()

    return ''
enddef
