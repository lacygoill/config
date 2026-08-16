vim9script

import autoload './util.vim'

export def Main(stop_at_empty_comments = false, op_is_c = false) #{{{1
    if &l:commentstring == ''
        return
    endif

    var l_: string
    var r_: string
    [l_, r_] = util.GetCml()
    var boundaries: list<number> = [line('.') + 1, line('.') - 1]

    #       ┌ 0 or 1:  upper or lower boundary
    #       │
    for  [which: number, dir: number, limit: number, next_line: string]
    in  [[0, -1, 1, getline('.')],
         [1, 1, line('$'), getline('.')]]

        var l: string
        var r: string
        [l, r] = getline('.')->util.MaybeTrimCml(l_, r_)
        var nl: string = next_line
        while util.IsCommented(nl, l, r)
                && !(stop_at_empty_comments && nl =~ $'^\s*{l->trim()}\s*$')
            # stop if the boundary has reached the beginning/end of a fold
            var foldmarker: string = split(&l:foldmarker, ',')->join('\|')
            if match(nl, foldmarker) >= 0
                break
            endif

            # the test was successful so (inc|dec)rement the boundary
            boundaries[which] += dir

            # update `line`, `l`, `r` before next test
            nl = getline(boundaries[which] + dir)
            [l, r] = util.MaybeTrimCml(nl, l_, r_)
        endwhile
    endfor

    var InvalidBoundaries: func = (): bool =>
           boundaries[0] < 1
        || boundaries[1] > line('$')
        || boundaries[0] > boundaries[1]

    if InvalidBoundaries()
        return
    endif

    #  ┌ we operate on the object with `c`
    #  │          ┌ OR the object doesn't end at the very end of the buffer
    #  │          │
    if op_is_c || boundaries[1] != line('$')
        # make sure there's no empty lines at the *start* of the object
        # by incrementing the upper boundary as long as necessary
        while getline(boundaries[0]) !~ '\S'
            ++boundaries[0]
        endwhile
    endif

    if op_is_c
        # make sure there are no empty lines at the *end* of the object
        while getline(boundaries[1]) !~ '\S'
            --boundaries[1]
        endwhile
    endif

    if InvalidBoundaries()
        return
    endif

    # position the cursor on the 1st line of the object
    execute 'normal! ' .. boundaries[0] .. 'G'

    # select the object
    execute 'normal! ' .. (mode() =~ "[vV\<C-V>]" ? 'o' : 'V') .. boundaries[1] .. 'G'
enddef
