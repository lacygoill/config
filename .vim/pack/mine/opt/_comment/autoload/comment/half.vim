vim9script

# Interface {{{1
export def Main(dir: string, type = ''): string #{{{2
    if type == ''
        &operatorfunc = function(Main, [dir])
        return 'g@l'
    endif

    var first_lnum: number = line("'{") + 1
    var last_lnum: number = line("'}") - 1
    if line("'{") == 1 && getline(1) =~ '\S'
        first_lnum = 1
    endif
    if line("'}") == line('$') && getline('$') =~ '\S'
        last_lnum = line('$')
    endif
    var diff: number = last_lnum - first_lnum + 1
    var lnum1: number
    var lnum2: number
    if dir == 'top'
        [lnum1, lnum2] = [
            first_lnum,
            first_lnum + diff / 2 - (diff % 2 == 0 ? 1 : 0)
        ]
    else
        [lnum1, lnum2] = [last_lnum - diff / 2 + 1, last_lnum]
    endif
    execute ':' .. lnum1 .. ',' .. lnum2 .. 'CommentToggle'
    # position cursor on first/last line of the remaining uncommented block of lines
    cursor(dir == 'top' ? lnum2 : lnum1, 1)
    return ''
enddef
