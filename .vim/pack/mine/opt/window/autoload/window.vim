vim9script

import 'lg.vim'
import 'lg/window.vim'

import autoload './window/quit.vim'

# Interface {{{1
export def DisableWrapWhenMovingToVertSplit(dir: string) #{{{2
    setwinvar(winnr('#'), '&wrap', false)
    execute 'wincmd ' .. dir
    &l:wrap = false
enddef

export def Navigate(dir: string) #{{{2
    # Purpose:{{{
    #
    #     $ vim -Nu NONE +'split | vsplit | vsplit | wincmd l'
    #     :wincmd j
    #     :wincmd k
    #
    #     $ vim -Nu NONE +'vsplit | split | split | wincmd j'
    #     :wincmd l
    #     :wincmd h
    #
    # In both cases, you don't focus back the middle window; that's jarring.
    #}}}
    if PreviousWindowIsInSameDirection(dir)
        try
            wincmd p
        catch
            lg.Catch()
        endtry
    else
        try
            execute 'wincmd ' .. dir
        catch
            lg.Catch()
        endtry
    endif
enddef

def PreviousWindowIsInSameDirection(dir: string): bool
    var cnr: number = winnr()
    var pnr: number = winnr('#')

    if dir == 'h'
        var leftedge_current_window: number = win_screenpos(cnr)[1]
        var rightedge_previous_window: number = win_screenpos(pnr)[1] + winwidth(pnr) - 1
        return leftedge_current_window - 1 == rightedge_previous_window + 1
    endif

    if dir == 'l'
        var rightedge_current_window: number = win_screenpos(cnr)[1] + winwidth(cnr) - 1
        var leftedge_previous_window: number = win_screenpos(pnr)[1]
        return rightedge_current_window + 1 == leftedge_previous_window - 1
    endif

    if dir == 'j'
        var bottomedge_current_window: number = win_screenpos(cnr)[0] + winheight(cnr) - 1
        var topedge_previous_window: number = win_screenpos(pnr)[0]
        return bottomedge_current_window + 1 == topedge_previous_window - 1
    endif

    if dir == 'k'
        var topedge_current_window: number = win_screenpos(cnr)[0]
        var bottomedge_previous_window: number = win_screenpos(pnr)[0] + winheight(pnr) - 1
        return topedge_current_window - 1 == bottomedge_previous_window + 1
    endif

    return false
enddef

export def PreviewOpen() #{{{2
    # if we're already in the preview window, get back to previous window
    if &l:previewwindow
        wincmd p
        return
    endif

    # Try to display a possible tag under the cursor in a new preview window.
    try
        wincmd }
        wincmd P
        normal! zMzvzz
        wincmd p
    catch
        lg.Catch()
    endtry
enddef

export def Resize(key: string) #{{{2
    var curwin: number = winnr()
    var keys: string
    if key =~ '[hl]'
        # Why returning different keys depending on the position of the window?{{{
        #
        # `C-w <` moves a border of a vertical window:
        #
        #    - to the right, for the left border of the window on the far right
        #    - to the left, for the right border of other windows
        #
        # 2 reasons for these inconsistencies:
        #
        #    - Vim can't move the right border of the window on the far
        #      right, it would resize the whole “frame“, so it needs to
        #      manipulate the left border
        #
        #    - the left border of the  window on the far right is moved to
        #      the left instead of the right, to increase the visible size of
        #      the window, like it does in the other windows
        #}}}
        if winnr('l') != curwin
            keys = key == 'h'
                ?     "\<C-W>3<"
                :     "\<C-W>3>"
        else
            keys = key == 'h'
                ?     "\<C-W>3>"
                :     "\<C-W>3<"
        endif

    else
        if winnr('j') != curwin
            keys = key == 'k'
                ?     "\<C-W>3-"
                :     "\<C-W>3+"
        else
            keys = key == 'k'
                ?     "\<C-W>3+"
                :     "\<C-W>3-"
        endif
    endif

    feedkeys(keys, 'in')
enddef

export def TerminalClose() #{{{2
    var term_buffer: number = GetTerminalBuffer()
    if term_buffer == 0
        return
    endif
    var winid: number = term_buffer
        ->win_findbuf()
        ->get(0)
    'quit.Main()'->win_execute(winid)
enddef

export def TerminalOpen() #{{{2
    var term_buffer: number = GetTerminalBuffer()
    if term_buffer != 0
        var winid: number = term_buffer
            ->win_findbuf()
            ->get(0)
        win_gotoid(winid)
        return
    endif

    var mod: string = window.GetMod()
    var how_to_open: string = mod .. ' terminal ++close ' .. ($INTERACTIVE_SHELL ?? &shell)
    var resize: string = mod =~ '^vertical'
        ?     ' | vertical resize 30 | resize 30'
        :     ''

    execute printf('execute %s %s', string(how_to_open), resize)
enddef

export def ZoomToggle() #{{{2
    if winnr('$') == 1
        return
    endif

    if exists('t:zoom_restore') && win_getid() == t:zoom_restore.winid
        execute get(t:zoom_restore, 'cmd', '')
        unlet! t:zoom_restore
    else
        var cmd: string = winrestcmd()
        t:zoom_restore = {cmd: cmd, winid: win_getid()}
        wincmd |
        wincmd _
    endif
enddef
#}}}1
# Utilities {{{1
def GetTerminalBuffer(): number #{{{2
    return tabpagenr()
        ->tabpagebuflist()
        ->filter((_, v: number): bool => getbufvar(v, '&buftype', '') == 'terminal')
        ->get(0, 0)
enddef
