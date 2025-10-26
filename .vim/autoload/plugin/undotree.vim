vim9script

# Interface {{{1
export def Show() #{{{2
    if &buftype != ''
        echo printf('no undotree for a special buffer (&buftype == %s)', &buftype)
        return
    endif

    # Purpose:{{{
    #
    # If you had several windows in your  tab page prior to opening the undotree
    # window, when you close the diff panel, the geometry of your windows may be
    # altered (not if you've opened undotree from the last window).
    #
    # To fix this, when closing the  diff panel, we'll fire `doautocmd WinEnter`
    # in the window  from which we've opened  undotree; but to do  this, we need
    # its id.
    #}}}
    # Warning: The way we handle this variable is not totally reliable.{{{
    #
    # It doesn't  update the  variable if  we focus  a different  regular window
    # (without  closing  the undotree  window),  then  focus back  the  undotree
    # window.
    #
    # Such a use case is tricky to support.
    # You would  need to  install an autocmd  listening to  `WinEnter <buffer>`.
    # But undotree often  temporarily focuses regular windows on  its own (among
    # other things to add/remove signs when we open/close the diff panel).
    # So, you  would need to find  a way to ignore  those involuntary `WinEnter`
    # events.   Or  you  could  try  to   refactor  undotree  so  that  it  uses
    # `win_execute()`.
    #}}}
    t:undotree_prevwinid = win_getid()

    # A similar autocmd is already installed in `...#diff_toggle()`.  Why installing yet another one here?{{{
    #
    # If  you close  the undotree  window  while the  diff panel  is open,  then
    # re-open the undotree window, the diff panel is automatically re-opened.
    # But in  that case, `D` has  not been pressed, and  `...#diff_toggle()` has
    # not been invoked; so the autocmd is not installed.
    #
    # MRE:
    #
    #     $ vim file
    #     # press -u to open undotree window
    #     # press D to open diff panel
    #     # press q to close undotree window and diff panel
    #     # press -u to open undotree window again
    #}}}
    # OK, but why the guard?{{{
    #
    # Well, when you  press `-u`, there's no guarantee that  the diff panel will
    # be automatically opened; it depends on what you did the last time (did you
    # open the diff panel or not?).
    # So, we need  a guard to be  sure that we customize the  right diff buffer;
    # that is one which is associated to an undotree buffer.
    #}}}
    autocmd FileType diff ++once {
        if winnr('#')->getwinvar('&filetype') == 'undotree'
            CustomizeDiffPanel()
        endif
    }

    execute 'UndotreeShow'
    autocmd BufWinLeave <buffer> ++once unlet! t:undotree_prevwinid
enddef

export def ShowHelp() #{{{2
    var help: list<string> =<< END
   ===== Marks =====
>num<: The current state
{num}: The next redo state
[num]: The latest state
  s: Saved states
  S: The last saved state

  ===== Hotkeys =====
u: Undo
<C-R>: Redo
}: Move to the previous saved state
{: Move to the next saved state
): Move to the previous undo state
(: Move to the next undo state
D: Toggle the diff panel
T: Toggle relative timestamp
C: Clear undo history (with confirmation)
END
    echo help->join("\n")
enddef

export def DiffToggle() #{{{2
    var tbl: list<number> = tabpagebuflist()
    var idx: number = tbl
        ->indexof((_, n: number): bool => bufwinnr(n)->getwinvar('&previewwindow'))
    var pv_bufnr: number = idx == -1 ? 0 : tbl[idx]
    # if there is already a preview window, ask the user to close it (to avoid `E590`)
    if pv_bufnr != 0 && bufname(pv_bufnr) !~ '^diffpanel_\d\+$'
        unsilent echo 'close the preview window first'
        return
    endif
    # check we are going to *open* the diff panel (and not close it)
    if !pv_bufnr
        autocmd FileType diff ++once CustomizeDiffPanel()
    endif
    t:undotree.Action('DiffToggle')
    if exists('t:undotree_prevwinid')
        win_execute(t:undotree_prevwinid, 'doautocmd <nomodeline> WinEnter')
    endif
enddef

export def CloseDiffPanel() #{{{2
# This function is public because we need to be able to call it when we press `SPC q`.
    var tbl: list<number> = tabpagebuflist()
    var idx: number = tbl
        ->indexof((_, n: number): bool => getbufvar(n, '&filetype') == 'undotree')
    var bufnr: number = idx == -1 ? 0 : tbl[idx]

    if bufnr != 0
        var winnr: number = bufwinnr(bufnr)
        win_getid(winnr)->win_gotoid()
        if &filetype == 'undotree'
            t:undotree.Action('DiffToggle')
        else
            echo 'press "D" from the undotree buffer for signs to be removed'
        endif
    else
        echo 'press "D" from the undotree buffer for signs to be removed'
    endif
enddef
#}}}1
# Core {{{1
def CustomizeDiffPanel() #{{{2
    &l:previewwindow = true
    # In the diff panel, the undotree plugin sets a status line, which I don't find useful.
    # Let's use our own.
    &l:statusline = '%!' .. expand('<SID>') .. 'Statusline()'
    b:undo_ftplugin = (get(b:, 'undo_ftplugin') ?? 'execute') .. '| set statusline<'
    nnoremap <buffer><nowait> q <ScriptCmd>CloseDiffPanel()<CR>
enddef

def Statusline(): string #{{{2
    return g:statusline_winid == win_getid()
        ? ' %l,%c%=%{&l:previewwindow ? "[pvw]" : ""}%p%% '
        : '%=%{&l:previewwindow ? "[pvw]" : ""}%p%% '
enddef
