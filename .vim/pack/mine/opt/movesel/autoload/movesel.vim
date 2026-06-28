vim9script

# TODO: Once  you've  completely refactored  this  plugin,  in our  vimrc,  move
# `vim-movesel` from the section “To assimilate” to “Done”.

# FIXME:
# We've modified how to reselect a block when moving one to the left/right.
# It doesn't work as expected when alternating between the 2 motions.
#
# Make some tests with bulleted lists whose 1st line is prefixed with `•` (or `-`?).
#
# Also, try to move this diagram (left, right):
#
#                            ← bottom    top →
#
#         evolution       │      ]
#         of the stack    │      ]    }
#         as parsing      │      ]    }    >
#         progresses      │      ]    }
#                         v      ]

# FIXME:
# Try to move the 1st line down, then  up. The “no“ is merged, and we can't undo
# it.   Interesting:  if  you  decrease  the level  of  indentation,  the  issue
# disappears.
#
#                                              use ~/.vim/ftdetect/test.vim
#                                              no

# TODO: Disable folding while moving text, because moving text across folds is broken.

var mode: string
var dir: string

# Interface {{{1
export def Move(arg_dir: string) #{{{2
# TODO: Make work with a motion?
# E.g.: `M-x }` moves the visual selection after the next paragraph.

    if !&l:modifiable
        return
    endif

    [mode, dir] = [mode(), arg_dir]

    if mode == 'v' && line('v') != line('.')
        Error('Cannot move characterwise selection when it''s multiline')
        return
    endif

    execute "normal! \<Esc>"

    var virtualedit_save: string = &virtualedit
    var view: dict<number> = winsaveview()
    var foldenable_save: bool = &l:foldenable

    try
        &virtualedit = 'all'
        &l:foldenable = false

        if ShouldUndojoin()
            undojoin | MoveImpl()
        else
            MoveImpl()
        endif
    finally
        execute "normal! \<Esc>"
        &virtualedit = virtualedit_save
        &l:foldenable = foldenable_save
        winrestview(view)
        normal! gvzv
    endtry
enddef

export def Duplicate(arg_dir: string) #{{{2
    [mode, dir] = [mode(), arg_dir]

    if mode == 'v' && line('v') != line('.')
        Error('Cannot duplicate characterwise selection when it''s multiline')
        return
    endif

    execute "normal! \<Esc>"

    if mode == 'V'
        if dir == 'up' || dir == 'down'
            DuplicateLines()
        else
            Error('Left and Right duplication not supported for lines')
            return
        endif
    else
        # FIXME: Select a word (characterwise), and press `mdh`.
        # The final selection is completely wrong.
        DuplicateBlock()
    endif
enddef
#}}}1
# Core {{{1
def MoveImpl() #{{{2
    if mode == 'V'
        MoveLines()
    else
        MoveBlock()
    endif
enddef

def MoveLines() #{{{2
    var line1: number
    var line2: number
    [line1, line2] = [line("'<"), line("'>")]

    if dir == 'up' #{{{
        # if  the selection  includes  the very  first line,  we  can't move  it
        # further above, but  we can still append an empty  line right after it,
        # which gives the impression it was moved above
        if line1 == 1
            append(line2, '')
        else
            silent :* move '<-2
        endif #}}}
    elseif dir == 'down' #{{{
        # if the selection includes the very last line, we can't move it further
        # down, but  we can still  append an empty  line right before  it, which
        # gives the impression it was moved below
        if line2 == line('$')
            append(line1 - 1, '')
        else
            silent :* move '>+1
        endif #}}}
    elseif dir == 'right' #{{{
        for lnum: number in range(line1, line2)
            var line: string = getline(lnum)
            if line != ''
                setline(lnum, ' ' .. line)
            endif
        endfor #}}}
    elseif dir == 'left' #{{{
        # Moving the  selection to the left  means removing a space  in front of
        # each line.  But  we don't want to  do that if a line  in the selection
        # starts with a non-whitespace.
        # Otherwise, watch what would happen:{{{
        #
        #     # before
        #     the
        #      selection
        #     ^
        #     we want this space to be preserved
        #
        #     # after
        #     the
        #     selection
        #     ^
        #     ✘
        #}}}
        if AllLinesStartWithWhitespace(line1, line2)
            for lnum: number in range(line1, line2)
                getline(lnum)->substitute('^\s', '', '')->setline(lnum)
            endfor
        endif
    endif #}}}

    normal! gv
enddef

def MoveBlock() #{{{2
    # While  '< is  always above  or  equal to  '>  in lnum,  the column  it
    # references could be the first or last col in the selected block
    var line1: number
    var fcol: number
    var foff: number
    var line2: number
    var lcol: number
    var loff: number
    var left_col: number
    var right_col: number
    [_, line1, fcol, foff] = getpos("'<")
    [_, line2, lcol, loff] = getpos("'>")
    [left_col, right_col] = sort([fcol + foff, lcol + loff], 'N')

    if dir == 'up' #{{{
        if line1 == 1
            ''->append(0)
        endif
        normal! gvxkPgvkoko
        #}}}
    elseif dir == 'down' #{{{
        if line2 == line('$')
            append('$', '')
        endif
        normal! gvxjPgvjojo
        #}}}
    elseif dir == 'right' #{{{
        var old_width: number = (getline('.') .. '  ')
            ->strpart(left_col - 1, right_col - left_col + 1)
            ->strcharlen()

        # Original code:
        #
        #     normal! gvxpgvlolo
        #               ^^
        # Why did we replace `xp` with `xlP`?{{{
        #
        # Try to  move a block  to the right, beyond  the end of  the lines,
        # while there  is a multibyte character  before the 1st line  of the
        # block:
        #
        #    • hello
        #    • people
        #
        # It fails because of `xp`.
        #
        # Solution:
        #
        #     xp → xlP
        #
        # Interesting:
        #
        # Set  'virtualedit'  to  'all',  and select  “hello“  in  a  visual
        # characterwise selection, then press `xp` (it will work):
        #
        #    • hello
        #
        # Reselect “hello“  in a  visual blockwise selection,  and press
        # `xp` (it will fail).
        # Now, reselect, and press `xlp`: it will also fail, but not because
        # it didn't move the block, but  because it moved it 1 character too
        # far.  Why?
        #}}}
        normal! gvxlPgvlolo

        # Problem:
        # Try to move the “join, delete, sort“ block to the right.
        # At one point, it misses a character (last `e` in `delete`).
        #
        #    • join
        #    • delete
        #    • sort
        #
        # Solution:
        # After reselecting  the text (`gv`),  check that the length  of the
        # block is the  same as before.  If it's shorter,  press `l` as many
        # times as necessary.

        var col1: number
        var col2: number
        [col1, col2] = sort([col("'<"), col("'>")], 'N')
        var new_width: number = getline('.')
            ->strpart(col1 - 1, col2 - col1 + 1)
            ->strcharlen()
        if old_width > new_width
            execute 'normal! ' .. (old_width - new_width) .. 'l'
        endif
        #}}}
    elseif dir == 'left' #{{{
        # FIXME: https://github.com/zirrostig/vim-schlepp/issues/11
        var vcol1: number
        var vcol2: number
        [vcol1, vcol2] = [virtcol("'<", true)[0], virtcol("'>", true)[0]]
            ->sort('N')
        var old_width: number = (getline('.') .. '  ')
            ->matchstr('\%' .. vcol1 .. 'v.*\%' .. vcol2 .. 'v.')
            ->strcharlen()
        if left_col == 1
            execute "normal! gvA \<Esc>"
            if getline(line1, line2)->match('^\s') >= 0
                for lnum: number in range(line1, line2)
                    if getline(lnum)->match('^\s') >= 0
                        getline(lnum)->substitute('^\s', '', '')->setline(lnum)
                        execute 'normal! ' .. lnum .. 'G' .. right_col .. "|a \<Esc>"
                    endif
                endfor
            endif
            execute "normal! \<Esc>gv"
        else
            normal! gvxhPgvhoho
        endif
        # Problem:
        # Select “join“ and “delete“, then press `xhPgv`, it works.
        #
        #         -join
        #         -delete
        #
        # Now, repeat  the same commands;  this time, it will  fail, because
        # `gv` doesn't reselect the right area:
        #
        #         -join
        #         -delete
        #
        # As soon as the visual  selection cross the multibyte character, it
        # loses some characters.
        #
        # Solution:
        # After reselecting  the text (`gv`),  check that the length  of the
        # block is the  same as before.  If it's shorter,  press `h` as many
        # times as necessary.
        #
        # FIXME:
        # Try to move “join, delete, sort“ to the left:
        #     gvxhPgvhoho
        #
        #    - join
        #    - delete
        #    - sort

        var col1: number
        var col2: number
        [col1, col2] = [col("'<"), col("'>")]
        var new_width: number = getline('.')
            ->strpart(col1 - 1, col2 - col1 + 1)
            ->strcharlen()
        if old_width > new_width
            execute 'normal! o' .. (old_width - new_width) .. 'ho'
        endif
    endif #}}}

    # Strip Whitespace
    # Need new positions since the visual area has moved
    [line1, line2] = [line("'<"), line("'>")]
    for lnum: number in range(line1, line2)
        getline(lnum)->substitute('\s\+$', '', '')->setline(lnum)
    endfor
    # Take care of trailing space created on lines above or below while
    # moving past them
    if dir == 'up'
        getline(line2 + 1)->substitute('\s\+$', '', '')->setline(line2 + 1)
    elseif dir == 'down'
        getline(line1 - 1)->substitute('\s\+$', '', '')->setline(line1 - 1)
    endif
enddef

def DuplicateLines() #{{{2
    var reselect: string
    if dir == 'up'
        reselect = 'gv'
    elseif dir == 'down'
        reselect = "'[V']"
    endif

    execute 'silent normal! gvyP' .. reselect
enddef

def DuplicateBlock() #{{{2
    var line1: number
    var fcol: number
    var foff: number
    var line2: number
    var lcol: number
    var loff: number
    var left_col: number
    var right_col: number
    [_, line1, fcol, foff] = getpos("'<")
    [_, line2, lcol, loff] = getpos("'>")
    [left_col, right_col] = [fcol + foff, lcol + loff]
        ->sort((i: number, j: number): number => i - j)
    var numlines: number = (line2 - line1) + 1
    var numcols: number = (right_col - left_col)

    if dir == 'up' #{{{
        if (line1 - numlines) < 1
            # Insert enough lines to duplicate above
            for _ in range((numlines - line1) + 1)
                ''->append(0)
            endfor
            # Position of selection has changed
            [_, line1, fcol, foff] = getpos("'<")
        endif

        var set_cursor: string = "\<ScriptCmd>getpos(\"'<\")[1 : 3]->cursor()\<CR>" .. numlines .. 'k'
        execute 'normal! gvy' .. set_cursor .. 'Pgv' #}}}
    elseif dir == 'down' #{{{
        if line2 + numlines >= line('$')
            for _ in ((line2 + numlines) - line('$'))->range()
                append('$', '')
            endfor
        endif
        execute "normal! gvy'>j" .. left_col .. '|Pgv' #}}}
    elseif dir == 'left' #{{{
        if numcols > 0
            execute 'normal! gvyP' .. numcols .. "l\<C-V>"
                .. numcols .. 'l'
                .. (numlines - 1) .. 'jo'
        else
            execute "normal! gvyP\<C-V>" .. (numlines - 1) .. 'jo'
        endif #}}}
    elseif dir == 'right' #{{{
        normal! gvyPgv
    endif #}}}
enddef
#}}}1
# Util {{{1
def Error(msg: string) #{{{2
    echohl ErrorMsg
    echomsg '[movesel] ' .. msg
    echohl NONE
enddef

def ShouldUndojoin(): bool #{{{2
    # We are on the last change.{{{
    #
    # We haven't played with `u`, `C-r`, `g+`, `g-`.
    # Or if we have, we've come back to the latest change.
    #}}}
    if changenr() == undotree().seq_last
    # we haven't performed more than 1 change since the last time
    && get(b:, '_movesel_state', {})->get('seq_last') == (changenr() - 1)
    # we haven't changed the type of the visual mode
    && get(b:, '_movesel_state', {})->get('mode_last', '') == mode
        return true
    endif

    b:_movesel_state = {mode_last: mode, seq_last: undotree().seq_last}
    return false
enddef

def AllLinesStartWithWhitespace(line1: number, line2: number): bool #{{{2
    return getline(line1, line2)->match('^\S') == -1
enddef
