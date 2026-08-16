vim9script

export def Catch(): string #{{{1
    # This function is  OK to be called  only if it's inside  a `catch` clause
    # which  is followed  by  a specific  pattern (and  not  a catch-all  like
    # `catch` or  `catch /.*/`) matching well-known  errors.  Or if  there are
    # only a few simple commands between `try` and `catch`.
    #
    # What we  want to  avoid, is to  lose time wondering  from where  a weird
    # error comes from.  For example, something like this:
    #
    #     try
    #         Func()
    #     catch
    #         lg.Catch()
    #     endtry
    #
    # `Func()` might  hide many  (possibly complex)  commands, and  thus might
    # give a weird error at runtime.  If it does, we'll have no idea where the
    # error really comes from; unless we remember:
    #
    #    - our custom key binding `coV` to toggle `g:my_verbose_errors`
    #    - how to reproduce the issue which gave the error

    if get(g:, 'my_verbose_errors', false)
        var funcname: string = v:throwpoint->matchstr('function \zs.\{-}\ze,')
        var line: string = v:throwpoint->matchstr('\%(function \)\=.\{-}, \zsline \d\+')

        echohl ErrorMsg
        if !empty(funcname)
            unsilent echomsg 'Error detected while processing function ' .. funcname .. ':'
        else
            # the error comes from a (temporary?) file
            unsilent echomsg 'Error detected while processing ' .. v:throwpoint->matchstr('.\{-}\ze,') .. ':'
        endif
        echohl LineNr
        unsilent echomsg line .. ':'
        # There is no hit-enter prompt, so  it *looks* like no stack trace has
        # been given.   It *has* been  given.  Execute  `:WTF` to parse  it so
        # that  we can  see  where the  error really  comes  from (instead  of
        # wrongly thinking that we didn't get any new info).
        timer_start(0, (_) => execute('silent! WTF'))
    endif

    echohl ErrorMsg
    # Even if  you set  “my_verbose_errors”, when this  function will  be called
    # from a  function implementing  an operator (`g@`),  only the  last message
    # will be visible (i.e. `v:exception`).
    # But it doesn't  matter.  All the messages have been  written in Vim's log.
    # So, `:WTF` will be able to show us where the error comes from.
    unsilent echomsg v:exception
    echohl NONE

    # It's  important   to  return   an  empty   string.   Because   often,  the
    # output   of  this   function  will   be  executed   or  inserted.    Check
    # `vim-interactive-lists`, and `vim-readline`.
    return ''
enddef

export def FuncComplete( #{{{1
    arglead: string,
    _, _
): list<string>

    # Problem: Some commands like `:def` don't complete function names.{{{
    #
    # This is especially annoying for names of script-local functions.
    #}}}
    # Solution: Implement a custom completion function which can be called from wrapper commands.{{{
    #
    # Example:
    #
    #     import FuncComplete from 'lg.vim'
    #     command -bar -complete=customlist,FuncComplete -nargs=? Def Def(<q-args>)
    #                  ^-------------------------------^
    #}}}

    # We really need to return a list, and not a newline-separated list wrapped inside a string.{{{
    #
    # If we return a  string, then this completion function must  be called by a
    # custom command defined with the `-complete=custom` attribute.
    # But  if  `arglead`  starts  with  `s:`,   Vim  will  filter  out  all  the
    # candidates, because none of them would match `s:` at the start.
    #
    # We  must use  `-complete=customlist` to  disable the  filtering, and  that
    # means that this function must return a list, not a string.
    #
    #     command -bar -complete=custom,FuncComplete -nargs=? Def Def(<q-args>)
    #                            ^----^
    #                              ✘
    #
    #     command -bar -complete=customlist,FuncComplete -nargs=? Def Def(<q-args>)
    #                            ^--------^
    #                                ✔
    #
    #}}}
    # Wait.  Why 6 backslashes in the replacement?{{{
    #
    # To emulate the `+` quantifier.  From `:help file-pattern`:
    #
    #    > \\\{n,m\}  like \{n,m} in a |pattern|
    #
    # Note that 3 backslashes are already neededd  in a file pattern, which is a
    # kind of globbing used by `getcompletion()`.
    # And since we write this in the replacement part of `substitute()`, we need
    # to double each backslash; hence 3 x 2 = 6 backslashes.
    #}}}
    return arglead
        ->substitute('^\Cs:', '<SNR>[0-9]\\\\\\{1,}_', '')
        ->getcompletion('function')
        ->map((_, v: string) => v->substitute('($\|()$', '', ''))
enddef

export def GetSelectionText(): list<string> #{{{1
    if mode() =~ "[vV\<C-V>]"
        return getreg('*', true, true)
    endif
    var reg_save: dict<any> = getreginfo('"')
    var clipboard_save: string = &clipboard
    var selection_save: string = &selection
    try
        &clipboard = ''
        &selection = 'inclusive'
        silent noautocmd normal! gvy
        return getreg('"', true, true)
    catch
        echohl ErrorMsg | echomsg v:exception | echohl NONE
    finally
        setreg('"', reg_save)
        [&clipboard, &selection] = [clipboard_save, selection_save]
    endtry
    return []
enddef

export def GetSelectionCoords(): dict<list<number>> #{{{1
# Get the coordinates of the current visual selection without quitting visual mode.
    var mode: string = mode()
    if mode !~ "^[vV\<C-V>]$"
        return {}
    endif
    var curpos: list<number>
    var pos_v: list<number>
    var start: list<number>
    var end: list<number>
    [pos_v, curpos] = [getpos('v')[1 : 2], getcurpos()[1 : 2]]
    var control_end: bool = curpos[0] > pos_v[0]
                         || curpos[0] == pos_v[0] && curpos[1] >= pos_v[1]
    if control_end
        [start, end] = [pos_v, curpos]
    else
        [start, end] = [curpos, pos_v]
    endif
    # If the selection is linewise, the column positions are not what we expect.
    # Let's fix that.
    if mode == 'V'
        start[1] = 1
        # Why `getline(end[0])->...`?{{{
        #
        # From `:help col()`:
        #
        #    > $       the end of the cursor line (the result is the
        #    >         number of bytes in the cursor line **plus one**)
        #}}}
        end[1] = col([end[0], '$']) - (getline(end[0])->strlen() > 0 ? 1 : 0)
    # In case we've pressed `O`.{{{
    #
    # Otherwise, the  returned coordinates  would not  match the  upper-left and
    # bottom-right corners, but the upper-right and bottom-left corners.
    #
    # This would undoubtedly introduce some confusion in our plugins.
    # Let's make sure the function always return what we have in mind.
    #}}}
    elseif mode == "\<C-V>" && start[1] > end[1]
        [start[1], end[1]] = [end[1], start[1]]
    endif
    return {start: start, end: end}
enddef

export def Opfunc(op: dict<any>, type: string) #{{{1
    if !op->has_key('funcname')
        return
    endif

    var reg_save: dict<dict<any>>
    # TODO: I think we need to save/restore all registers.{{{
    #
    # Make more tests to be sure.
    # Document the reason why we do this.
    #
    # ---
    #
    # I think `"0` is a special case...
    #}}}
    for regname: string in ['"', '-']
                 + range(10)->map((_, v: number): string => string(v))
        reg_save[regname] = getreginfo(regname)
    endfor

    var clipboard_save: string = &clipboard
    var selection_save: string = &selection
    var visual_marks_save: list<list<number>> = [getpos("'<"), getpos("'>")]
    try
        # Yanking might be useless for our operator function.{{{
        #
        # Worse, it could have undesirable side effects:
        #
        #    - reset `v:register`
        #    - reset `v:count`
        #    - mutate unnamed register
        #
        # See our `dr` operator for an example.
        #}}}
        if get(op, 'yank', true)
            &clipboard = ''
            &selection = 'inclusive'
            # Why do you use visual mode to yank the text?{{{
            #
            #     normal! `[y`]    ✘
            #     normal! `[v`]y   ✔
            #
            # Because  a motion  toward  a  mark is  exclusive,  thus the  `y`
            # operator won't yank the character  which is the nearest from the
            # end of the buffer.
            #
            # OTOH, ``v`]``  makes this same  motion inclusive, thus  `y` will
            # correctly yank  all the characters  in the text-object.   On the
            # condition that `'selection'` includes `inclusive`.
            #}}}
            var commands: dict<string> = {
                char: '`[v`]y',
                line: "'[V']y",
                block: "`[\<C-V>`]y"
            }
            # `:noautocmd`  minimizes  unexpected   side  effects.   E.g.,  it
            # prevents our  visual ring from  saving a possible  selection, as
            # well as the auto highlighting when we've pressed `coy`.
            execute 'silent noautocmd keepjumps normal! ' .. get(commands, type, '')
        endif
        call(op.funcname, [type])
    catch
        Catch()
        return
    finally
        for [regname: string, value: dict<any>] in reg_save->items()
            setreg(regname, value)
        endfor
        [&clipboard, &selection] = [clipboard_save, selection_save]
        # Shouldn't we check the validity of the saved positions?{{{
        #
        # Why?
        #
        # Because  the operator  might  have removed  the  characters where  the
        # visual marks were originally set, and the positions of the saved marks
        # might be invalid?
        #
        # First, the same issue affects a built-in operator.
        # Second, `setpos()` doesn't give any error even if you give it invalid positions:
        #
        #     $ vim -Nu NONE -i NONE +'echomsg setpos("'\''<", [0, 999, 999, 0])'
        #     0
        #
        # So, I don't think there is an issue here.
        #}}}
        setpos("'<", visual_marks_save[0])
        setpos("'>", visual_marks_save[1])
    endtry
enddef

export def Win_getid(arg: string): number #{{{1
    if arg == 'P'
        var winnr: number = range(1, winnr('$'))
            ->indexof((_, n: number): bool => getwinvar(n, '&previewwindow')) + 1
        if winnr == 0
            return 0
        endif
        return win_getid(winnr)
    endif
    if arg == '#'
        var winnr: number = winnr('#')
        return win_getid(winnr)
    endif
    return 0
enddef
