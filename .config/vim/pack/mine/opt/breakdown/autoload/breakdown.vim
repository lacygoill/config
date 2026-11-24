vim9script

# Interface {{{1
export def PutErrorSign(where: string, type = ''): string #{{{2
    if type == ''
        &operatorfunc = function(PutErrorSign, [where])
        return 'g@l'
    endif

    var ballot: string = '✘'
    var checkmark: string = '✔'
    var pointer: string = where == 'above'
        ? 'v'
        : '^'
    var vcol: number = virtcol('.')
    var cml: string
    [cml; _] = Getcml()
    var next_line: string = (line('.') + (where == 'above' ? -2 : 2))
        ->getline()

    var new_line: string
    if next_line =~ ballot
        # if our cursor is on the 20th cell, while the next lines occupy only 10
        # cells the  next substitutions  will fail, because  they will  target a
        # non-existing character;  need to prevent  that by appending  spaces if
        # needed
        var next_line_length: number = strcharlen(next_line)
        if vcol > next_line_length
            next_line ..= repeat(' ', vcol - next_line_length)
        endif

        var pat: string = '\%' .. vcol .. 'v' .. repeat('.', strcharlen(ballot))
        new_line = next_line->substitute(pat, ballot, '')

        if where == 'above'
            keepjumps :.-2,.-1 delete _
        else
            keepjumps :.+1,.+2 delete _
            :.-1
        endif
    else
        var indent_lvl: number = indent('.')
        var spaces_between_cml_and_mark: string = ' '
            ->repeat(vcol - 1 - strcharlen(cml) - indent_lvl)
        var indent: string = repeat(' ', indent_lvl)
        new_line = indent .. cml .. spaces_between_cml_and_mark .. ballot
    endif

    if where == 'above'
        var here: number = line('.') - 1
        append(here, new_line)
        new_line
            ->substitute(ballot .. '\|' .. checkmark, pointer, 'g')
            ->append(here + 1)
    else
        var here: number = line('.')
        new_line
            ->substitute(ballot .. '\|' .. checkmark, pointer, 'g')
            ->append(here)
        append(here + 1, new_line)
    endif
    # Why this motion?{{{
    #
    # Without, `.` will  move the cursor at the beginning  of the line, probably
    # because of the previous `:delete` command.
    #}}}
    execute 'normal! ' .. vcol .. '|'
    # Alternatively:{{{
    #
    # You could also have executed one of these right after the deletion:
    #
    #     :.-2,.-1 delete _
    #     :.+1-1
    #
    #     :.-2,.-1 delete _
    #     :.-1+1
    #
    #     :.-2,.-1 delete _
    #     :.-1
    #     :.+1
    #
    #     :.-2,.-1 delete _
    #     :.+1
    #     :.-1
    #
    # It would have prevented the cursor from jumping to the beginning of
    # the line when pressing `.`.
    #
    # Question: How does it work?
    #
    # Answer: from `:help 'startofline`
    #
    #    > ... When off the cursor is kept in the same column (if possible).
    #    > This applies to the commands: ...
    #    > Also for an Ex command that only has a line number, e.g., ":25" or ":+".
    #    > In case  of **buffer changing  commands** the  cursor is placed  at the
    #    > column where it was the last time the buffer was edited.
    #
    # MRE:
    #
    #     set nostartofline
    #     nnoremap <F3> <ScriptCmd>Func()<CR>
    #     def Func()
    #        :.-2,.-1 delete _
    #        append(line('.') - 1, 'the date is:')
    #        strftime('%c')->append(line('.') - 1)
    #     enddef
    #     ['the date is:', 'today', 'some text']->setline(1)
    #     normal! Ge
    #
    #     # press `F3`
    #     # actual:   the cursor has jumped onto the first character of the line
    #     # expected: the cursor does not move
    #
    # Again, you can fix the issue by adding `+-` right after `:delete`.
    #
    # TODO:
    #
    # OK, `+-` doesn't make the column of the cursor change.
    # But it doesn't matter, the column of the cursor has *already* changed when
    # `:delete` is executed!
    #
    # Besides,  if you  execute the  4 commands  manually (`:delete`,  `:.+1-1`,
    # `append()` x 2), the issue is not fixed anymore.
    #
    # So why does  `+-` work differently depending on whether  it's inside a
    # function, or outside?
    #}}}
    return ''
enddef

export def PutV(dir: string) #{{{2
    if line("'<") != line("'>")
        return
    endif
    # we need `strdisplaywidth()` in case the line contains multicell characters, like tabs
    var line: string = repeat(' ', getline('.')->strdisplaywidth())
    var vcol1: number = [virtcol("'<", true)[0], virtcol("'>", true)[0]]->min()
    var vcol2: number = [virtcol("'<", true)[0], virtcol("'>", true)[0]]->max()
    # Describes all the characters which were visually selected.{{{
    #
    # The pattern contains 3 branches because such a character could be:
    #
    #    - after the mark '< and before the mark '>
    #    - on the mark '<
    #    - on the mark '>
    #}}}
    var pat: string = '\%>' .. vcol1 .. 'v\%<' .. vcol2 .. 'v.'
        .. '\|\%' .. vcol1 .. 'v.\|\%' .. vcol2 .. 'v.'
    line = line
            ->substitute(pat, dir == 'below' ? '^' : 'v', 'g')
            ->substitute('\s*$', '', '')
    # `^---^` is nicer than `^^^^^`.
    # But `^-^` looks weird; prefer `^^^`.
    line = line
            ->substitute(
                '[v^]\zs.\{2,}\ze[v^]',
                (m: list<string>): string => repeat('-', strcharlen(m[0])),
                '')
    var cml_left: string
    var cml_right: string
    [cml_left, cml_right] = Getcml()
    var indent: number = indent('.')
    line = repeat(' ', indent)
        .. cml_left
        .. line[strcharlen(cml_left) + indent :]
        .. (!empty(cml_right) ? ' ' : '') .. cml_right
    # if  there are  already  marks on  the line  below/above,  don't add  a
    # new  line  with `append()`,  instead  replace  the current  line  with
    # `setline()`, merging its existing marks with the new ones
    var offset: number = (dir == 'below' ? 1 : -1)
    var existing_line: string = (line('.') + offset)->getline()
    if existing_line =~ '^\s*' .. '\V' .. escape(cml_left, '\') .. '\m' .. '[ v^-]*$'
        line = MergeLines(line, existing_line)
        setline(line('.') + offset, line)
        return
    endif
    append(dir == 'below' ? '.' : line('.') - 1, line)
enddef

export def CenterText() # {{{2
    if line("'<") != line("'>")
        echo 'cannot center multiline text'
        return
    endif

    var line: string = getline(line('.') - 1)
    var cml: string = &l:commentstring
        ->matchstr('\S*\ze\s*%s')
    cml = $'\%(\V{escape(cml, '\')}\m\)\='
    var pointer: string = $'^\s*{cml}\s*[-^v]\+$'
    if line !~ pointer
        line = getline(line('.') + 1)
        if line !~ pointer
            echo 'cannot find pointer on adjacent line'
            return
        endif
    endif

    var before: string = line
        ->matchstr($'^\s*{cml}\s*')

    var col_start: number = [col("'<"), col("'>")]->min()
    var col_end: number = [col("'<"), col("'>")]->max()
    var text: string = getline('.')
        ->matchstr($'\%{col_start}c.*\%{col_end}c.')

    var pointer_length: number = line
        ->matchstr($'^\s*{cml}\s*\zs[-^v]\+$')
        ->strcharlen()
    var offset: number = (pointer_length - strcharlen(text)) / 2

    var new_line: string = before .. ' '->repeat(offset) .. text

    setline('.', new_line)
enddef
# }}}1
# Core {{{1
def MergeLines(line: string, existing_line: string): string #{{{2
    var longest: string
    var shortest: string
    if strcharlen(line) > strcharlen(existing_line)
        [longest, shortest] = [line, existing_line]
    else
        [longest, shortest] = [existing_line, line]
    endif
    var chars_in_longest: list<string> = split(longest, '\zs')
    for [i: number, char: string] in shortest->items()
        if char =~ '[v^-]'
            chars_in_longest[i] = char
        endif
    endfor
    return chars_in_longest->join('')
enddef

# }}}1
# Util {{{1
def Getcml(): list<string> #{{{2
    var cml_left: string
    var cml_right: string
    if &l:commentstring == '' || &filetype == 'markdown'
        [cml_left, cml_right] = ['', '']
    else
        [cml_left, cml_right] = split(&l:commentstring, '%s', true)
    endif
    return [cml_left, cml_right]
enddef
