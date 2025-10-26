vim9script

# FIXME:
#         let maybe_nl = empty(lines) ? '' : "\n"
#         let text = work_on_code
#                \ ?     join(             lines,  "\n") .. maybe_nl ..              text_before_cursor
#                \ :     join(s:remove_cml(lines), "\n") .. maybe_nl .. s:remove_cml(text_before_cursor)
#                          ^
#
# Press `vio` right above the `^`.
# The first/last character of any line in the selection should match a word boundary.
# Here, it's not the case for the 1st and 4th line.
# The selection should only cover 2 lines, with the words `join`.
#
# 2 possible algo:
#
# 1.
# Select current word on current line.
# On next line, from same original column position, select current word:
#
#    - if the new set of column indexes is included in the previous one,
#      go on to next line
#
#    - if it's not check whether the 1st/last column index is the
#      first/last character in a word, in ALL previous lines:
#
#        * if they don't, stop the object on the previous line
#        * if they do, go on to next line
#
# 2.
# Same as before,  except, don't check whether the 1st/last  column index is the
# 1st/last character in  a word, in all previous lines.   Instead, check whether
# they are whitespace, which is more restrictive.
# I prefer  this algo,  because it  seems smarter.   It will  react differently,
# depending on where we press `io`.
# Besides, if,  sometimes, the selection is  not big enough compared  to what we
# expected, all we need to do, is move the cursor (l,j,…), then repress `io`.
#
#         abcd  xy
#         efghij
#         klmnopqr
#
# Our current algorithm is fundamentally different.  It starts to search for the
# lines, then the columns.
# If we want to implement one of the previous 2 algo, we need to start searching
# for the columns, then the lines.

export def Main(iw_aw: string) #{{{1
    var line: string = getline('.')
    if line =~ '^\s*$'
        return
    endif

    # Select current word on current line.
    # On next line, from same original column position, select current word:
    #
    #    - if the new set of column indexes is included in the previous one,
    #      go on to next line
    #
    #    - if it's not check whether the 1st/last column index is the
    #      first/last character in a word, in ALL previous lines:
    #
    #        * if they don't, stop the object on the previous line
    #        * if they do, go on to next line

    var on_space: bool = line[charcol('.') - 1] =~ '\s'

    # pressing Escape is necessary to set the mark '<
    execute 'keepjumps normal! v' .. iw_aw .. "\<Esc>"

    var lnum: number = line('.')
    var indent: number = indent('.')
    var startcol: number = col("'<")
    var startvcol: number = virtcol("'<", true)[0]
    var top_line: number = FindBoundaryLines(
        lnum,
        indent,
        startcol,
        startvcol,
        -1
    )
    var bottom_line: number = FindBoundaryLines(
        lnum,
        indent,
        startcol,
        startvcol,
        1
    )
    var vcol1: number
    var vcol2: number
    [vcol1, vcol2] = FindBoundaryColumns(
        top_line,
        bottom_line,
        virtcol("'<"),
        iw_aw,
        on_space
    )

    execute 'keepjumps normal! '
        .. top_line .. 'G' .. vcol1 .. '|'
        .. "\<C-V>"
        .. bottom_line .. 'G' .. vcol2 .. '|'
enddef

def FindBoundaryLines( #{{{1
    lnum: number,
    indent: number,
    col: number,
    vcol: number,
    dir: number
): number

    var cur_lnum: number = lnum
    var limit: number = dir == 1 ? line('$') : 1

    var is_code: bool = synID(cur_lnum, col, true)
        ->synIDattr('name') != 'Comment'
    while cur_lnum != limit
        var next_lnum: number = cur_lnum + dir
        var line: string = getline(next_lnum)

        var has_same_indent: bool = indent(next_lnum) == indent
        var is_not_empty: bool = line =~ '\S'
        var is_long_enough: bool = line =~ '\%' .. vcol .. 'v'
        var is_not_folded: bool = line !~ '\%({{' .. '{\|}}' .. '}\)\%(\d\+\)\=\s*$'
        var is_relevant: bool = is_code && synID(next_lnum, col, true)
            ->synIDattr('name') != 'Comment'
            || !is_code && synID(next_lnum, col, true)
            ->synIDattr('name') == 'Comment'

        if has_same_indent && is_not_empty && is_long_enough && is_not_folded && is_relevant
            cur_lnum = next_lnum
        else
            return cur_lnum
        endif
    endwhile

    return limit
enddef

def FindBoundaryColumns( #{{{1
    top_line: number,
    bottom_line: number,
    vcol: number,
    iw_aw: string,
    on_space: bool
): list<number>

    var vcol1: number = -1
    var vcol2: number = -1
    var lnum: number = top_line

    while lnum <= bottom_line
        execute $"keepjumps normal! {lnum}G{vcol}|v{iw_aw}\<Esc>"

        if [vcol1, vcol2] == [-1, -1]
            [vcol1, vcol2] = [virtcol("'<"), virtcol("'>")]
        else
            var pat: string = $'\%>{virtcol("'<", true)[0] - 1}v'
                           .. '\S'
                           .. $'\%<{virtcol("'>") + 1}v.'
            var selected_word_is_not_empty: bool = getline('.') =~ pat
            if !on_space && selected_word_is_not_empty
             || on_space && !selected_word_is_not_empty
                vcol1 = [vcol1, virtcol("'<")]->min()
                vcol2 = [vcol2, virtcol("'>")]->max()
            endif
        endif
        ++lnum
    endwhile

    return [vcol1, vcol2]
enddef
