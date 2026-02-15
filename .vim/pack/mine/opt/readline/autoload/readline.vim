vim9script

# FIXME: `Del` is broken with some composing characters.{{{
#
# Sometimes, our functions return `Del`.
# Most of the time, it works as expected; but watch this:
#
#     Ë͙͙̬̹͈͔̜́̽D̦̩̱͕͗̃͒̅̐I̞̟̣̫ͯ̀ͫ͑ͧT̞Ŏ͍̭̭̞͙̆̎̍R̺̟̼͈̟̓͆
#
# Press, `Del` while the cursor is at the beginning of the word, in a buffer; it
# works.  Now,  do the same  on the command-line; you'll  have to press  the key
# `51` times!  `51` is the output of `strchars('Ë͙͙̬̹͈͔̜́̽D̦̩̱͕͗̃͒̅̐I̞̟̣̫ͯ̀ͫ͑ͧT̞Ŏ͍̭̭̞͙̆̎̍R̺̟̼͈̟̓͆')`, btw.
# Because of this, some readline functions  don't work with these types of text,
# while on the command-line, like `M-d` and `C-w`.
#
# https://github.com/vim/vim/issues/6134
#}}}

# Could I change Vim's undo granularity automatically (via autocmds)?{{{
#
# Yes, see this: https://vi.stackexchange.com/a/2377/17449
#}}}
#   What would it allow me to do?{{{
#
# You could recover the state of the buffer after deleting some text.
# For example, you could recover the state (2) in the following edition:
#
#     # state (1)
#     hello world|
#                ^
#                cursor
#     # press: C-w
#
#     # state (2)
#     hello |
#     # press: p e o p l e
#
#     # state (3)
#     hello people|
#}}}
#   Why don't you use this code?{{{
#
# Because:
#
#    - either you  break the undo sequence  just *before* the next  insertion of a
#    character, after a sequence of deletion
#
#    - or you break it just *after*
#
# If you break it just before, then  when you insert a register after a sequence
# of deletions,  the last  character of  the register  is changed  (deleted then
# replaced by the 1st):
#
#     @a = 'abc'
#     &backspace = 'start'
#     var deleting: bool
#     autocmd InsertLeave * deleting = 0
#     autocmd InsertCharPre * CloseUndoAfterDeletions()
#     def CloseUndoAfterDeletions()
#         if !deleting
#             return
#         endif
#         feedkeys("\<BS>\<C-G>u" .. v:char, 'in')
#         deleting = false
#     enddef
#     inoremap <expr> <C-W> C_w()
#     def C_w(): string
#         deleting = true
#         return "\<C-W>"
#     enddef
#     # press: i C-w
#     # press: C-r a
#     # expected: 'abc' is inserted
#     # actual:   'aba' is inserted
#
# And if you break it just after,  then a custom abbreviation may be expanded in
# the middle of a word you type:
#
#     &backspace = 'start'
#     inoreabbrev al la
#     var deleting: bool = false
#     autocmd InsertLeave * deleting = false
#     autocmd InsertCharPre * CloseUndoAfterDeletions()
#     def CloseUndoAfterDeletions()
#         if !deleting
#             return
#         endif
#         feedkeys("\<C-G>u", 'in')
#         deleting = false
#     enddef
#     inoremap <expr> <C-W> C_w()
#     def C_w(): string
#         deleting = true
#         return "\<C-W>"
#     enddef
#     # press: i C-w
#     # press: v a l SPC
#     # expected: 'al' remains unchanged
#     # actual:   'al' is replaced by 'la'
#
# This happens because `C-g u` has been executed after `v` and before `al`.
# In any case, no  matter what you do, Vim's behavior  when editing text becomes
# less predictable.  I don't like that.
#}}}

# Init {{{1

augroup MyGranularUndo
    autocmd!
    # Why resetting `concat_next_kill`?{{{
    #
    #     :one two
    #     C-w Esc
    #     :three
    #     C-w
    #     C-y
    #     threetwo    ✘˜
    #     C-y
    #     three       ✔˜
    #}}}

    # Why `[^=]` instead of `*`?{{{
    #
    # We have some readline mappings in  insert mode and command-line mode whose
    # RHS uses `C-r =`.
    # When they are invoked, we shouldn't reset those variables.
    # Otherwise:
    #
    #     # press C-d
    #     echo b|ar
    #           ^
    #           cursor
    #
    #     # press C-d
    #     echo br
    #
    #     # press C-d
    #     echo b
    #
    #     # press C-_ (✔)
    #     echo br
    #
    #     # press C-_ (✘ we should get bar)
    #     echo br
    #}}}
    #   And why do you also include `>`?{{{
    #
    # When we quit debug mode after hitting a breakpoint, there is noise related
    # to these autocmds:
    #
    #     Entering Debug mode.  Type "cont" to continue.
    #     CmdlineLeave Autocommands for "[^=]"
    #     cmd: concat_next_kill = false
    #     >
    #     CmdlineLeave Autocommands for "[^=]"
    #     cmd: undolist_c = [] | mark_c = 0
    #     >
    #     CmdlineLeave Autocommands for "[^=]"
    #     cmd: mark_c = 0
    #}}}
    #   Won't it cause an issue when we leave the expression command-line?{{{
    #
    # Usually, we enter the expression command-line from command-line mode,
    # so the variables will be reset after we leave the regular command-line.
    #
    # But yeah, after entering the command-line from insert mode or command-line
    # mode, then getting back to the previous mode, we'll have an outdated undolist,
    # which won't be removed until we get back to normal mode.
    #
    # It should rarely happen, as I don't use the expression register frequently.
    # And when it does happen, the real  issue will only occur if we press `C-_`
    # enough to get back to this outdated undolist.
    #
    # It doesn't seem a big deal ATM.
    #}}}
    #   Could `<ScriptCmd>` help?{{{
    #
    # It does, but we can't always use it.
    # Sometimes,  we  still  need  `<C-R>=`  or `<C-\>e`,  both  of  which  fire
    # `CmdlineEnter`.
    #}}}
    autocmd CmdlineLeave [^=>] concat_next_kill = false
    # reset undolist and marks when we leave insert/command-line mode
    autocmd CmdlineLeave [^=>] undolist_c = [] | mark_c = 0
    autocmd InsertLeave * undolist_i = [] | mark_i = 0
augroup END

var deleting: bool = false

const FAST_SCROLL_IN_PUM: number = 5

var mark_i: number
var mark_c: number

var undolist_i: list<list<any>>
var undolist_c: list<list<any>>

# When we kill with:
#
#    - M-d: the text is appended  to the top of the kill ring
#    - C-w: the text is prepended "
#    - C-u: the text is prepended "
#    - C-k: the text is appended  "
#
# Exceptions:
# C-k + C-u  →  C-u (only the text killed by C-u goes into the top of the kill ring)
# C-u + C-k  →  C-k ("                       C-k                                   )
#
# Basically, we should *not* concat 2 consecutive big kills.
var last_kill_was_big: bool
var concat_next_kill: bool
var kill_ring_i: list<string> = ['']
var kill_ring_c: list<string> = ['']

var did_yank_or_pop: bool

# Interface {{{1
export def AddToUndolist() #{{{2
    augroup AddToUndolist
        autocmd!
        autocmd User AddToUndolistC AddToUL('c', getcmdline(), getcmdpos())
        autocmd User AddToUndolistI AddToUL('i', getline('.'), col('.'))
    augroup END
enddef

def AddToUL( #{{{2
        mode: string,
        line: string,
        pos: number
        )
    var undolist: list<list<any>> = mode == 'i' ? undolist_i : undolist_c
    var undo_len: number = len(undolist)
    if undo_len > 100
        # limit the size of the undolist to 100 entries
        undolist->remove(0, undo_len - 101)
    endif
    if mode == 'i'
        undolist_i->add([line, pos])
    else
        # Might need an offset for the cursor position to be correct after undoing `C-w`.
        var ppos: number = pos
        # The guard is necessary for the cursor position to be correct after undoing `M-d`.
        if pos != len(line) + 1
            ppos = pos - 1
        endif
        undolist_c->add([line, ppos])
    endif
enddef

export def BackwardChar(): string #{{{2
    concat_next_kill = false

    # SPC + C-h = close wildmenu
    if Mode() == 'i'
        # We need `<C-G>U`  for the dot command  to be able to  repeat an edit
        # during which we've moved the cursor with a readline mapping.
        # We need `<C-G>u` to not break some abbreviation expansions:{{{
        #
        #     $ vim +'call setline(1, "x")' +'inoreabbrev c ddd'
        #     # press "A" to enter insert mode at the end of the line
        #     # press "<C-B>" to go back one character
        #     # insert "c "
        #     # expected: "c" is replaced with "ddd"
        #     # expected: "c" is not replaced
        #}}}
        return "\<C-G>U\<Left>\<C-G>u"
    endif
    if wildmenumode()
        return "\<Space>\<C-H>\<Left>"
    endif
    return "\<Left>"
enddef

export def BackwardDeleteChar(): string #{{{2
    var line: string
    var pos: number
    [line, pos] = Mode()->SetupAndGetInfo(true, false, false)
    return "\<C-H>"
enddef

export def BackwardKillWord(): string #{{{2
    var mode: string = Mode()
    var iskeyword_save: string = &l:iskeyword
    var bufnr: number = bufnr('%')

    try
        var line: string
        var pos: number
        [line, pos] = SetupAndGetInfo(mode, true, false, true)
        var pat: string =
            # word before cursor
            '\k*'
            # there may be some non-word text between the word and the cursor;
            # alternative to `[^[:keyword:]]`: `\%(\k\@!.\)`
            .. '\%([^[:keyword:]]\+\)\='
            # the cursor
            .. '\%' .. pos .. 'c'

        var killed_text: string = line->matchstr(pat)
        AddToKillRing(killed_text, mode, false, false)

        # Do *not* feed `<BS>` directly, because sometimes it would delete too much text.
        # It might happen when the cursor is  after a sequence of whitespace (1 BS =
        # `&shiftwidth` chars deleted).  Instead, feed `<Left><Del>`.

        var seq: string = CloseUndoBeforeDeletions(mode)
        if mode == 'i'
            seq ..= repeat("\<C-G>U\<Left>\<Del>", strcharlen(killed_text)) .. "\<C-G>u"
        else
            seq ..= repeat("\<Left>\<Del>", strcharlen(killed_text))
        endif
        return seq
    finally
        setbufvar(bufnr, '&iskeyword', iskeyword_save)
    endtry
    return ''
enddef

export def BeginningOfLine(): string #{{{2
    concat_next_kill = false
    if Mode() == 'c'
        return "\<home>"
    endif
    var after_first_nonws = col('.') >= getline('.')->match('\S') + 1
    var pat: string = after_first_nonws
        ?     '\S.*\%.c'
        :     '\%.c\s*\ze\S'
    var count: number = getline('.')->matchstr(pat)->strcharlen()
    # on a very long line, the `repeat(...)` sequence might be huge and too slow for Vim to type
    if count > &columns
        return "\<home>"
    endif
    return repeat("\<C-G>U" .. (after_first_nonws ? "\<Left>" : "\<Right>"), count) .. "\<C-G>u"
enddef

export def ChangeCaseWord(upcase = false, type = ''): string #{{{2
# Warning: If you  change the name  of this function,  make sure to  also change
# them when they're referenced in `window#popup#Scroll()`.

    var mode: string = Mode()
    if mode == 'n' && type == ''
        &operatorfunc = function(ChangeCaseWord, [upcase])
        return 'g@l'
    endif

    var iskeyword_save: string = &l:iskeyword
    var bufnr: number = bufnr('%')
    try
        var line: string
        var pos: number
        [line, pos] = SetupAndGetInfo(mode, true, true, true)
        var pat: string = $'\%{pos}c' .. '\zs\%(\k\+\|.\{-}\<\k\+\>\|[^[:keyword:]]\+\)'
        var word: string = line->matchstr(pat)

        if mode == 'c'
            if pos > strlen(line)
                return line
            endif
            var new_cmdline: string = line
                ->substitute(pat, upcase ? '\U&' : '\L&', '')
            setcmdpos(pos + strlen(word))
            return new_cmdline
        endif
        if mode == 'i'
            var length: number = strcharlen(word)
            return repeat("\<Del>", length) .. (upcase ? toupper(word) : tolower(word))
        endif
        if mode == 'n'
            var new_line: string = line
                ->substitute(pat, (upcase ? '\U&' : '\L&'), '')
            var new_pos: number = match(line, pat .. '\zs') + 1
            setline('.', new_line)
            cursor(0, new_pos)
        endif
        return ''
    finally
        setbufvar(bufnr, '&iskeyword', iskeyword_save)
    endtry
    return ''
enddef

export def CxCa(): string #{{{2
    # Just to add the old command-line in the undolist.
    Mode()->SetupAndGetInfo(true, false, false)
    return "\<C-A>"
enddef

export def DeleteChar(): string #{{{2
    var mode: string = Mode()
    var line: string
    var pos: number
    [line, pos] = SetupAndGetInfo(mode, true, true, false)

    if mode == 'c'
        if wildmenumode()
            return repeat("\<C-N>", FAST_SCROLL_IN_PUM)
        endif

        # If the cursor  is at the end  of the command-line, we  want `C-d` to
        # keep  its normal  behavior which  is to  list names  that match  the
        # pattern in front of the cursor.  However, if it's before the end, we
        # want `C-d` to delete the character after it.
        if getcmdpos() > strlen(line)
            if getcmdtype() =~ '[:>@=]'
                # Before pressing `C-d`, we first redraw to erase the possible
                # listed  completion  suggestions.    This  makes  consecutive
                # listings more readable.
                #
                # MRE:
                #       :help dir       C-d
                #       :help dire      C-d
                #       :help directory C-d
                redraw
                return "\<C-D>"
            endif
        else
            return "\<Del>"
        endif
    endif

    #    - if the pum is visible, and there are enough matches to scroll a page down, scroll
    #    - otherwise, if we're *before* the end of the line, delete next character
    #    - "                   *at* the end of the line,     delete the newline
    var seq: string = pumvisible() && complete_info(['items']).items->len() > FAST_SCROLL_IN_PUM
        ?     repeat("\<C-N>", FAST_SCROLL_IN_PUM)
        : col('.') <= getline('.')->strlen()
        ?     "\<Del>"
        :     "\<C-G>j\<home>\<BS>"
    return seq
enddef

export def EditAndExecuteCommand() #{{{2
    cedit_save = &cedit
    &cedit = "\<C-X>"
    feedkeys(&cedit, 'in')
    autocmd CmdwinEnter * ++once &cedit = cedit_save
enddef
var cedit_save: string

export def EndOfLine(): string #{{{2
    concat_next_kill = false
    var count: number = col('$') - col('.')
    if count > &columns
        return "\<end>"
    endif
    return repeat("\<C-G>U\<Right>", count) .. "\<C-G>u"
enddef

export def ForwardChar(): string #{{{2
    concat_next_kill = false
    return Mode() == 'c'
        ?    (wildmenumode() ? "\<Space>\<C-H>" : '') .. "\<Right>"
        : col('.') > getline('.')->strlen()
        ?     ''
        :     "\<C-G>U\<Right>\<C-G>u"
    # Go the right if we're in the middle of the line (custom), or fix the
    # indentation if we're at the end (default)
enddef

export def KillLine(): string #{{{2
    var mode: string = Mode()
    var line: string
    var pos: number
    [line, pos] = SetupAndGetInfo(mode, true, false, false)

    var killed_text: string = strpart(line, pos - 1)
    AddToKillRing(killed_text, mode, true, true)

    # Warning: it may take a long time on a mega long soft-wrapped line if `'scrolloff'` is different than 0{{{
    #
    # MRE:
    #
    #     setlocal wrap scrolloff=3
    #     inoremap <expr> <C-K><C-K> repeat('<Del>', 11000)
    #     :% delete
    #     ['0123456789']->repeat(1000)->setline(1)
    #     :% join
    #     :0 put _
    #     normal! j
    #     startinsert
    #
    #     # press C-k C-k: the line is deleted only after 2 or 3 seconds
    #}}}
    return CloseUndoBeforeDeletions(mode)
        .. repeat("\<Del>", strcharlen(killed_text))
enddef

export def KillWord(): string #{{{2
    var mode: string = Mode()
    var iskeyword_save: string = &l:iskeyword
    var bufnr: number = bufnr('%')
    try
        var line: string
        var pos: number
        [line, pos] = SetupAndGetInfo(mode, true, false, true)
        var pat: string =
        # from  the cursor  until the  end of  the current  word; if  the cursor  is
        # outside of a word, the pattern still matches, because we use `*`, not `+`
        '\k*\%' .. pos .. 'c'
            .. '\zs\%('
            # or all the non-word text we're in
            .. '\k\+'
            .. '\|'
            # or the next word if we're outside of a word
            .. '.\{-}\<\k\+\>'
            .. '\|'
            # the rest of the word after the cursor
            .. '[^[:keyword:]]\+'
            .. '\)'

        var killed_text: string = line->matchstr(pat)
        AddToKillRing(killed_text, mode, true, false)

        return CloseUndoBeforeDeletions(mode)
            .. repeat("\<Del>", strcharlen(killed_text))
    finally
        setbufvar(bufnr, '&iskeyword', iskeyword_save)
    endtry
    return ''
enddef

export def MoveByWords( #{{{2
        is_fwd = true,
        capitalize = false,
        type = ''
        ): string

# Implementing this function was tricky, it has to handle:{{{
#
#    - multibyte characters (éàî)
#    - multicell characters (tab)
#    - composing characters  ( ́)
#}}}
    if type == '' && Mode() == 'n'
        &operatorfunc = function(MoveByWords, [is_fwd, capitalize])
        return 'g@l'
    endif
    var iskeyword_save: string = &l:iskeyword
    var bufnr: number = bufnr('%')

    try
        var mode: string = Mode()
        var line: string
        var pos: number
        #                                   ┌ if, in addition to moving the cursor forward,{{{
        #                                   │ we're going to capitalize,
        #                                   │ we want to add the current line to the undolist
        #                                   │ to be able to undo
        #                                   │
        #                                   ├────────┐}}}
        [line, pos] = SetupAndGetInfo(mode, capitalize, true, true)
        var pat: string

        if is_fwd
            # all characters from the beginning of the line until the last
            # character of the nearest *next* word (current one if we're in a word,
            # or somewhere *after* otherwise)
            # Why `\%#=1`?{{{
            #
            # https://github.com/vim/vim/pull/7572#issuecomment-753563155
            #}}}
            pat = '\%#=1.*\%' .. pos .. 'c\%(.\{-1,}\>\|.*\)'
            #                                           │
            #          if there's no word where we are, ┘
            # nor after us, then go on until the end of the line
        else
            # all characters from the beginning of the line until the first
            # character of the nearest *previous* word (current one if we're in a
            # word, or somewhere *before* otherwise)
            pat = '.*\ze\<.\{-1,}\%' .. pos .. 'c'
        endif
        var new_pos: number = matchend(line, pat)
        if new_pos == -1
            return "\<home>"
        endif

        # Here's how it works in readline:{{{
        #
        #    1. it looks for the keyword character after the cursor
        #
        #       The latter could be right after, or further away.
        #       Which means the capitalization doesn't necessarily uppercase
        #       the first character of a word.
        #
        #    2. it replaces it with its uppercase counterpart
        #
        #    3. it replaces all subsequent characters until a non-keyword character
        #       with their lowercase counterparts
        #}}}
        if capitalize
            var new_line: string = line
                ->substitute(
                    '\%' .. pos .. 'c.\{-}\zs\(\k\)\(.\{-}\)\%' .. (new_pos + 1) .. 'c',
                    '\u\1\L\2',
                    ''
                )
            if mode == 'c'
                setcmdpos(new_pos + 1)
                return new_line
            endif
            new_line->setline('.')
        endif

        var new_pos_char: number = charidx(line, new_pos)
        if new_pos_char == -1
            return "\<end>"
        endif
        # necessary to move correctly on a line such as:
        #          ́ foo  ́ bar
        var pos_char: number = line->strpart(0, pos - 1)->strcharlen()
        var diff: number = pos_char - new_pos_char
        var building_motion: string = mode == 'i'
            ?     diff > 0 ? "\<C-G>U\<Left>" : "\<C-G>U\<Right>"
            :     diff > 0 ? "\<Left>" : "\<Right>"

        # Why `feedkeys()`?{{{
        #
        # Needed  to move  the cursor at  the end  of the word  when we  want to
        # capitalize it in normal mode.
        #}}}
        var seq: string = repeat(building_motion, abs(diff))
        return mode == 'i'
            ? seq .. "\<C-G>u"
            : (feedkeys(seq, 'in') ? '' : '')
    finally
        setbufvar(bufnr, '&iskeyword', iskeyword_save)
    endtry

    return ''
enddef

export def Tab(is_fwd = true): string #{{{2
    if getcmdtype() =~ '[?/]'
        return getcmdline() == ''
            ?     "\<Up>"
            :     is_fwd ? "\<C-G>" : "\<C-T>"
    endif
    if is_fwd
        # The returned key will be pressed from a mapping while in command-line mode.
        # We want Vim to start a wildcard expansion.
        # So, we need to return whatever key is stored in 'wildcharm'.
        var key: string = nr2char(&wildcharm != 0 ? &wildcharm : &wildchar)
        if wildmenumode()
            return key
        endif
        # Just to add the old command-line in the undolist.
        Mode()->SetupAndGetInfo(true, false, false)
        return "\<Tab>"
    endif
    # Why `feedkeys()`?{{{
    #
    # To make Vim press `S-Tab` as if  it didn't come from a mapping.  Without
    # the  `t`  flag of  `feedkeys()`,  hitting  `S-Tab` on  the  command-line
    # outside  the  wildmenu makes  Vim  insert  the 7  characters  `<S-Tab>`,
    # literally.  That's not  what `S-Tab` does by default.   It should simply
    # open the wildmenu and select its last entry.
    #}}}
    # Why `reg_recording()->empty()`?{{{
    #
    # Without, during a recording, `S-Tab` would be recorded twice:
    #
    #    - once when you press the key interactively
    #    - once when `feedkeys()` writes the key in the typeahead
    #
    # Because of that, the execution of the register would be wrong; `S-Tab`
    # would be  pressed twice.
    #}}}
    #   Wait.  What if I press `S-Tab` during a recording while the wildmenu is not open?{{{
    #
    # Well,  it  will  be  broken;  i.e. `<S-Tab>` will  be  inserted  on  the
    # command-line.  I  don't know how to  fix this, and I  don't really care;
    # it's a corner case.
    #}}}
    if !wildmenumode() && reg_recording()->empty()
        feedkeys("\<S-Tab>", 'int')
        return ''
    endif
    return "\<S-Tab>"
enddef

export def TransposeChars(): string #{{{2
    var mode: string = Mode()
    var line: string
    var pos: number
    [line, pos] = SetupAndGetInfo(mode, true, true, false)
    # Test on this:
    #
    #     âêîôû
    if pos > strlen(line)
        var deleted_char: string = line[-2]
        return mode == 'i'
            ?     "\<C-G>U\<Left>\<BS>\<C-G>U\<Right>" .. deleted_char .. "\<C-G>u"
            :     "\<Left>\<BS>\<Right>" .. deleted_char

    elseif pos > 1
        # Alternative: `line->strpart(0, pos - 1)[-1]`
        # It's (very) slightly slower though.
        var deleted_char: string = line[line->charidx(pos - 1) - 1]
        return mode == 'i'
            ?     "\<BS>\<C-G>U\<Right>" .. deleted_char .. "\<C-G>u"
            :     "\<BS>\<Right>" .. deleted_char

    else
        return ''
    endif
enddef

export def TransposeWords(type = ''): string #{{{2
    var mode: string = Mode()
    if type == '' && mode == 'n'
        &operatorfunc = TransposeWords
        return 'g@l'
    endif
    var iskeyword_save: string = &l:iskeyword
    var bufnr: number = bufnr('%')

    try
        # Warning: Avoid to use a too complex pattern.{{{
        #
        # Especially if it contains a variable-width lookbehind.
        # It could give this error on a long line:
        #
        #     Vim:E363: pattern uses more memory than 'maxmempattern'
        #}}}
        var line: string
        var pos: number
        [line, pos] = SetupAndGetInfo(mode, true, true, true)

        # Special Case: We're on the first word.
        if line =~ '^\s*\%([^[:keyword:]]\+\s*\)\=\k*\%' .. pos .. 'c\k'
                # Or before.
                || line =~ '^\s*\%' .. pos .. 'c\s*\%([^[:keyword:]]\+\s*\)\=\k'
            # There should be no transposition (to correctly emulate readline).
            return mode == 'c' ? line : ''
        endif

        # Special Case: We're on a non-keyword character after the last word.
        #
        #     # cursor is somewhere here
        #              vvv
        #     foo+++bar---
        #     →
        #     bar---+++foo
        #     # `bar---` has been exchanged with `foo`
        if line !~ $'\k\%>{pos}c'
            var pat: string = '\(.*\)\<\(\k\+\)\([^[:keyword:]]\+\)\(\k\+[^[:keyword:]]*\)'
            var rep: string = '\1\4\3\2'
            var new_line: string = line->substitute(pat, rep, '')
            if mode == 'c'
                (line->len() + 1)->setcmdpos()
                return new_line
            endif
            setline('.', new_line)
            cursor(0, line->len() + 1)
            return ''
        endif

        # General Case: We're in-between  the first and last  words (the first
        # one being excluded, but not the last one: `]first, last]`).
        #
        # We're looking for 2 words which are separated by non-word characters.
        # Why non-word characters, and not whitespace?{{{
        #
        # Because readline transposition works even when 2 words are separated
        # by special characters such as backticks:
        #
        #     foo``|``bar    ⇒    bar````foo
        #          ^
        #          cursor
        #}}}
        var pat: string = '\(\<\k\+\>\)\([^[:keyword:]]\+\)\(\<\k\+\>\)'
            # The cursor must be inside those words.{{{
            #
            #             cursor
            #             v
            #     foo bar | baz
            #     ^-----^
            #     don't transpose those 2
            #}}}
            .. $'\%(\%>{pos}c\)\@='

        var rep: string = '\3\2\1'
        var new_line: string = line->substitute(pat, rep, '')

        if mode == 'c'
            var new_pos: number = line->matchend('.*\%' .. pos .. 'c.\{-1,}\>')
            setcmdpos(new_pos + 1)
            return new_line
        endif
        var new_pos: number = searchpos('\>', 'nW', line('.'))[1]
        setline('.', new_line)
        cursor(0, new_pos)
        return ''
    finally
        setbufvar(bufnr, '&iskeyword', iskeyword_save)
    endtry

    return ''
enddef

export def Undo(): string #{{{2
    var mode: string = Mode()
    if mode == 'i' && empty(undolist_i)
    || mode == 'c' && empty(undolist_c)
        return ''
    endif

    var old_line: string
    var old_pos: number
    [old_line, old_pos] = remove(mode == 'i' ? undolist_i : undolist_c, -1)
    UndoRestoreCursor = () => {
        if mode == 'i'
            cursor(0, old_pos)
        else
        # `setcmdpos()` doesn't work from `CmdlineChanged`.{{{
        #
        # It only works when editing the command-line.
        #
        # ---
        #
        # Note that we  only need to restore the position  in 1 particular case:
        # when there  is no text  after the cursor.   That happens e.g.  when we
        # smash `M-d`;  once there is  no word to  delete anymore, if  you press
        # `C-_` to undo the last deletion of  a word, you'll see that the cursor
        # is not restored where you want.
        #
        # I guess  we could check whether  there is some text  after the cursor,
        # before invoking `feedkeys()`.  For now, I prefer to not overcomplicate
        # the  code.  You  might  want  to add  this  check  later (*maybe*  for
        # slightly better performance on long command-lines).
        #
        # You might wonder why we only need  to restore the cursor position in 1
        # particular case.   I think  it's just a  property of  `:help c_CTRL-\_e`.
        # When you  edit the command-line  with the latter, the  cursor probably
        # remains unchanged; *unless*,  your cursor was at the end  of the line.
        # In which case, Vim probably tries to be smart, and think that you want
        # your cursor to be at the end of the new command-line (just like it was
        # at the end of the old one).
        #}}}
            feedkeys( "\<C-B>" .. repeat("\<Right>", strpart(old_line, 0, old_pos)->strcharlen()), 'n')
        endif
    }

    if mode == 'c'
        autocmd CmdlineChanged * ++once UndoRestoreCursor()
        return old_line
    endif
    autocmd TextChangedI * ++once UndoRestoreCursor()
    setline('.', old_line)
    return ''
enddef
var UndoRestoreCursor: func

export def UnixLineDiscard(): string #{{{2
    var mode: string = Mode()
    if mode == 'i'
            && pumvisible()
            && complete_info(['items']).items->len() > FAST_SCROLL_IN_PUM
            || mode == 'c'
            && wildmenumode()
        return repeat("\<C-P>", FAST_SCROLL_IN_PUM)
    endif

    var line: string
    var pos: number
    [line, pos] = SetupAndGetInfo(mode, true, false, false)

    if mode == 'c'
        line->strpart(0, pos - 1)->AddToKillRing('c', false, true)
    else

        AddDeletedTextToKillRing = () =>
            line
            ->strpart(0, pos - 1)
            # In insert mode, `C-u` does not necessarily delete the text all the way back to column 0.{{{
            #
            # It might stop somewhere before.
            # For  example, if  `'backspace'` contains  the `start`  item, `C-u`
            # stops at the column where you've started inserting text.
            #
            # That's why, we can't simply add  all the text before the cursor in
            # the kill  ring.  If there's still  some text between column  0 and
            # the cursor, it must be removed first.
            #}}}
            ->strpart(col('.') - 1)
            ->AddToKillRing('i', false, true)

        autocmd TextChangedI * ++once AddDeletedTextToKillRing()
    endif

    return CloseUndoBeforeDeletions(mode) .. "\<C-U>" .. (mode == 'i' ? "\<C-G>u" : '')
enddef
var AddDeletedTextToKillRing: func

export def Yank(want_to_pop = false): string #{{{2
    var mode: string = Mode()
    if pumvisible()
        return "\<C-Y>"
    endif
    var kill_ring: list<string> = mode == 'i' ? kill_ring_i : kill_ring_c
    if want_to_pop && (!did_yank_or_pop || len(kill_ring) < 2)
        || !want_to_pop && kill_ring->empty()
        return ''
    endif

    # set flag telling that `C-y` or `M-y` has just been pressed
    did_yank_or_pop = true
    var line: string
    var pos: number
    [line, pos] = SetupAndGetInfo(mode, true, true, false)
    var length: number
    if want_to_pop
        length = strcharlen(kill_ring[-1])
        insert(kill_ring, kill_ring->remove(-1), 0)
    endif
    if exists('#ResetDidYankOrPop')
        autocmd! ResetDidYankOrPop
        augroup! ResetDidYankOrPop
    endif
    autocmd SafeState * ++once ResetDidYankOrPop()
    @- = kill_ring[-1]
    var seq: string
    if want_to_pop
        if mode == 'i'
            seq = repeat("\<C-G>U\<Left>\<Del>", length) .. "\<C-G>u"
        else
            seq = repeat("\<Left>\<Del>", length)
        endif
    endif
    return seq .. "\<C-R>-"
enddef

def ResetDidYankOrPop()
    # In the shell, as soon as you move the cursor, `M-y` doesn't do anything anymore.
    # We want the same behavior in Vim.
    augroup ResetDidYankOrPop
        autocmd!
        # Do *not* use a long list of events (`CursorMovedI`, `CmdlineChanged`, ...).{{{
        #
        #     autocmd CursorMovedI,CmdlineChanged,InsertLeave,CursorMoved *
        #
        # It would not be as reliable as `SafeState`.
        # E.g., when you  move your cursor on the command-line,  the flag should
        # be reset, but there is no `CmdlineMoved` event.
        # Besides, finding the  right list of events may be  tricky; you have to
        # consider special cases, such as pressing `C-c` to leave insert mode.
        #}}}
        autocmd SafeState * ++once did_yank_or_pop = false
    augroup END
enddef
#}}}1
# Util {{{1
def AddToKillRing( #{{{2
        text: string,
        mode: string,
        after: bool,
        this_kill_is_big: bool
        )
    # Called when we press one of these:
    #
    #    - `C-k`: `KillLine()`
    #    - `C-u`: `UnixLineDiscard()`
    #    - `C-w`: `BackwardKillWord()`
    #    - `M-d`: `KillWord()`

    if concat_next_kill
        if mode == 'i'
            kill_ring_i[-1] = after
                ?     kill_ring_i[-1] .. text
                :     text .. kill_ring_i[-1]
        else
            kill_ring_c[-1] = after
                ?     kill_ring_c[-1] .. text
                :     text .. kill_ring_c[-1]
        endif
    else
        if mode == 'i' && kill_ring_i == ['']
            kill_ring_i = [text]
        elseif mode == 'c' && kill_ring_c == ['']
            kill_ring_c = [text]
        else
            var kill_ring: list<string> = mode == 'i' ? kill_ring_i : kill_ring_c
            # the kill ring  is never reset in readline; we  should not reset it
            # either but I don't like letting it  grow too much, so we keep only
            # the last 10 killed text
            if len(kill_ring) > 10
                kill_ring->remove(0, len(kill_ring) - 9)
            endif
            kill_ring
                # before adding sth in the kill-ring, check whether it's already
                # there, and if it is, remove it
                ->filter((_, v: string): bool => v != text)
                ->add(text)
        endif
    endif
    SetConcatNextKill(mode, this_kill_is_big)
enddef

def CloseUndoBeforeDeletions(mode: string): string #{{{2
    if mode == 'c' || deleting
        return ''
    endif
    # If the execution has reached this  point, it means we're going to delete
    # some multi-char text.   But, if we delete another  multi-char text right
    # after, we don't want to, again, break the undo sequence.
    deleting = true
    # We'll re-enable the breaking of the undo sequence before a deletion, the
    # next time we insert a character, or leave insert mode.
    augroup ReadlineResetDeleting
        autocmd!
        autocmd InsertLeave,InsertCharPre * {
            execute 'autocmd! ReadlineResetDeleting'
            deleting = false
        }
    augroup END
    return "\<C-G>u"
enddef
# Purpose:{{{
#
#    - A is a text we insert
#    - B is a text we insert after A
#    - C is a text we insert to replace B after deleting the latter
#
# Without any custom “granular undo“, we can only visit:
#
#    - ∅
#    - AC
#
# This function presses `C-g  u` the first time we delete  a multi-char text, in
# any given sequence of multi-char deletions.
# This lets us visit AB.
# In the past, we used some code, which broke the undo sequence after a sequence
# of deletions.   It allowed us  to visit A (alone).   We don't use  it anymore,
# because it leads to too many issues.
#}}}

def Mode(): string #{{{2
    var mode: string = mode()
    # if you enter the search command-line from visual mode, `mode()` wrongly returns `v`
    # https://github.com/vim/vim/issues/6127#issuecomment-633119610
    # Why do you compare `mode` to `t`?{{{
    #
    #     breakadd func Func
    #     def Func()
    #         term_start($INTERACTIVE_SHELL ?? &shell, {hidden: true})
    #             ->popup_create({})
    #     enddef
    #     Func()
    #     # > next
    #     # > echo mode()
    #     t˜
    #}}}
    if mode =~ "^[vV\<C-V>t]$"
        return 'c'
    # To suppress this error in `AddToUL()`:{{{
    #
    #     E121: Undefined variable: undolist_R˜
    #
    # Happens when we press `R` in normal mode followed by `C-y`.
    #}}}
    elseif mode =~ 'R'
        return 'i'
    endif
    return mode
enddef

def SetConcatNextKill(mode: string, this_kill_is_big: bool) #{{{2
#                                   ^--------------^
#                                   true when we can kill more than a word
#                                   (i.e. we press C-k or C-u)
    concat_next_kill = this_kill_is_big && last_kill_was_big ? false : true
    last_kill_was_big = this_kill_is_big

    if mode == 'c'
        # Why?{{{
        #
        # After  the next  deletion, it  the command-line  gets empty,  the deletion
        # after that shouldn't be concatenated:
        #
        #     :one C-u
        #     :two C-w
        #     C-y
        #     twoone    ✘˜
        #     two       ✔˜
        #}}}
        autocmd CmdlineChanged * ++once {
            if getcmdline() =~ '^\s*$'
                execute('concat_next_kill = false')
            endif
        }
        return
    endif

    # If we  delete a  multi-char text,  then move the  cursor *or*  insert some
    # text,  then re-delete  a multi-char  text, the  2 multi-char  texts should
    # *not* be concatenated.
    #
    # FIXME: We should make the autocmd listen to `CursorMovedI`, but it would
    # wrongly reset  `concat_next_kill` when we  delete a 2nd  multi-char text
    # right after a 1st one.
    augroup ReadlineResetConcatNextKill
        autocmd!
        autocmd InsertCharPre,InsertEnter,InsertLeave * {
            execute 'autocmd! ReadlineResetConcatNextKill'
            concat_next_kill = false
        }
    augroup END
enddef

def SetupAndGetInfo( #{{{2
        mode: string,
        add_to_undolist: bool,
        reset_concat: bool,
        set_isk: bool
        ): list<any>

    var line: string
    var pos: number
    [line, pos] = mode == 'c'
        ?     [getcmdline(), getcmdpos()]
        :     [getline('.'), col('.')]

    # `TransposeWords()` may call this function from normal mode
    if add_to_undolist && mode != 'n'
        AddToUL(mode, line, pos)
    endif

    if reset_concat && mode != 'n'
        concat_next_kill = false
    endif

    if set_isk
        # Why re-setting 'iskeyword'?{{{
        #
        # readline doesn't consider `-`, `#`, `_` as part of a word,
        # contrary to Vim which may disagree for some of them.
        #
        # Removing them from 'iskeyword' lets us operate on the following “words“:
        #
        #     foo-bar
        #     foo#bar
        #     foo_bar
        #}}}
        # Just in case.{{{
        #
        # In the past, some mappings  behaved strangely because of an unexpected
        # value of `'iskeyword'`.
        # Let's make sure that doesn't happen  again, by first getting back to a
        # known good value.
        #}}}
        setlocal iskeyword&vim
        setlocal iskeyword-=_ iskeyword-=- iskeyword-=#
    endif

    return [line, pos]
enddef
