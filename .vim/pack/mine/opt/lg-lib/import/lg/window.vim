vim9script

import 'lg.vim'

export def GetMod(): string #{{{1
    var winnr: number = winnr()

    var mod: string
    # there's nothing above or below us
    if winnr('j') == winnr && winnr('k') == winnr
        mod = 'botright'

    # we're at the top
    elseif winnr('k') == winnr
        mod = 'topleft'

    # we're at the bottom
    elseif winnr('j') == winnr
        mod = 'botright'

    # we're in a middle window
    else
        # This will cause a vertical split to be opened on the right.
        # If you would prefer on the left, write this instead:
        #
        #     mod = 'vertical leftabove'
        mod = 'vertical rightbelow'
    endif

    return mod
enddef

export def OpenOrFocus(what: any, how: string) #{{{1
    var fname: string
    if what->typename() == 'list<string>'
        if what->empty()
            return
        endif
        fname = what[0]
    else
        if what->typename() != 'string'
            return
        endif
        fname = what
    endif

    # Open given filename in given way, but only if it's not already displayed
    # in a window.  If it is, just focus the latter instead.
    var winid: number = ($'^{fname}$')
        ->bufnr()
        ->win_findbuf()
        ->get(0, -1)
    if winid != -1
        win_gotoid(winid)
        return
    endif
    execute $'{how} {fname}'
    cursor(1, 1)

    # If there are several files to open, put them into an arglist.
    if what->typename() == 'list<string>'
            && what->len() > 1
        var arglist: list<string> = what
            ->copy()
            ->map((_, f: string) => f->fnameescape())
        execute $'arglocal {arglist->join()}'
    endif
enddef

export def QfOpenOrFocus(qftype: string) #{{{1
    var winid: number
    var we_are_in_qf: bool = &buftype == 'quickfix'

    if !we_are_in_qf
        winid = qftype == 'loc'
            ? getloclist(0, {winid: 0}).winid
            : getqflist({winid: 0}).winid
        if !winid
            # Why `:[cl]open`? Are they valid commands here?{{{
            #
            # Probably not, because these commands  don't populate the qfl, they
            # just  open the  qf  window.
            #
            # However,  we  use   these  names  in  the   autocmd  listening  to
            # `QuickFixCmdPost` in `vim-qf`,  to decide whether we  want to open
            # the qf  window unconditionally (`:[cl]open`), or  on the condition
            # that the qfl contains at least 1 valid entry (`:[cl]window`).
            #
            # It lets us do this in any plugin populating the qfl:
            #
            #     doautocmd <nomodeline> QuickFixCmdPost cwindow
            #     open  the qf window  on the condition  it contains at  least 1 valid entry˜
            #
            #     doautocmd <nomodeline> QuickFixCmdPost copen
            #     open the qf window unconditionally˜
            #}}}
            # Could we write sth simpler?{{{
            #
            # Yes:
            #
            #     execute (qftype == 'loc' ? 'l' : 'c') .. 'open'
            #
            # But, it wouldn't open the qf window like our autocmd in `vim-qf` does.
            #}}}
            execute 'doautocmd <nomodeline> QuickFixCmdPost ' .. (qftype == 'loc' ? 'l' : 'c') .. 'open'
        else
            win_gotoid(winid)
        endif

    # if we are already in the qf window, focus the previous one
    elseif we_are_in_qf && qftype == 'qf'
        wincmd p

    # if we are already in the ll window, focus the associated window
    elseif we_are_in_qf && qftype == 'loc'
        getloclist(0, {filewinid: 0})
            ->get('filewinid', 0)
            ->win_gotoid()
    endif
enddef

export def Scratch(lines: list<string>) #{{{1
# TODO: Improve the whole function after reading `~/Wiki/vim/Todo/scratch.md`.
    var tmp_file: string = tempname()
    try
        execute 'split ' .. tmp_file
    # `:pedit` is forbidden from a Vim popup terminal window
    catch /^Vim\%((\a\+)\)\=:E994:/
        lg.Catch()
        return
    endtry
    lines->setline(1)
    silent update
    # in case some line is too long for our vertical split
    &l:wrap = true
    # for vim-window to not maximize the window when we focus it
    &l:previewwindow = true
    nmap <buffer><nowait> q <Plug>(my-quit)
    wincmd p
enddef
