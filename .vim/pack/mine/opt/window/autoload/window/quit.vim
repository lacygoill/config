vim9script

import 'lg.vim'
import autoload './util.vim'
import autoload 'plugin/undotree.vim'

export def Main() #{{{1
    # If we're in goyo mode, leave it.{{{
    #
    # Otherwise, pressing `<Space>q` while in goyo mode gives an error:
    #
    #     Vim(tabclose):E1312: Not allowed to change the window layout in this autocmd
    #
    # Also, it leaves us with a weird Vim layout, and no tmux statusline.
    #}}}
    if exists('#goyo')
        execute 'Goyo!'
    endif

    # If we are in the command-line window, we want to close the latter,
    # and return without doing anything else (no session save).
    #
    #   return ':' in a command-line window,
    #   nothing in a regular buffer
    #   v-----------v
    if !getcmdwintype()->empty()
        quit
        return
    endif

    # a sign may be left in the sign column if you close an undotree diff panel with `:quit` or `:close`
    if bufname('%') =~ '^diffpanel_\d\+$'
        undotree.CloseDiffPanel()
        return
    endif

    # If we're recording a macro, don't close the window; stop the recording.
    if reg_recording() != ''
        feedkeys('q', 'in')
        return
    endif

    var winnr_max: number = winnr('$')

    # Quit everything if:{{{
    #
    #    - there's only 1 window in 1 tabpage
    #    - there're only 2 windows in 1 tabpage, one of which is a location list window
    #    - there're only 2 windows in 1 tabpage, the remaining one is a diff window
    #}}}
    if tabpagenr('$') == 1
        && (
             winnr_max == 1
          || winnr_max == 2
          && (
               getwininfo()
                   ->map((_, v: dict<any>): number => v.loclist)
                   ->index(1) >= 0
               || (winnr() == 1 ? 2 : 1)->getwinvar('&diff')
             )
           )
        # To suppress:
        #     E929: Too many viminfo temp files, like /home/lgc/.local/share/vim/infa.tmp!
        var tmpfiles: list<string> = glob($VIM .. '/*.tmp', false, true)
        if tmpfiles->len() > 10
            tmpfiles->foreach((_, file: string) => file->delete())
        endif

        quitall!

    elseif &buftype == 'terminal'
        if util.IsPopup()
            win_getid()->popup_close()
        else
            # Don't wipe out the buffer.  It could be bound to a job which is in
            # the middle of something important (like a system update).
            close
        endif

    else
        var was_loclist: bool = win_gettype() == 'loclist'
        # if the window we're closing is associated to a ll window, close the latter too
        # We could also install an autocmd in our vimrc:{{{
        #
        #     autocmd QuitPre * ++nested if &buftype != 'quickfix' | lclose | endif
        #
        # Inspiration:
        # https://github.com/romainl/vim-qf/blob/5f971f3ed7f59ff11610c00b8a1e343e2dbae510/plugin/qf.vim#L64-L65
        #
        # But in this  case, we couldn't close the current  window with `:close`
        # at the end of the function.
        # We would have to use `:quit`, because `:close` doesn't emit `QuitPre`.
        # For the moment,  we prefer to use `:close` because  it doesn't close a
        # window if it's the last one.
        #}}}
        lclose

        # if we were already in a loclist window, then `:lclose` has closed it,
        # and there's nothing left to close
        if was_loclist
            return
        endif

        # same thing for preview window, but only in a help buffer outside of
        # preview winwow
        if &buftype == 'help' && !&previewwindow
            pclose
        endif

        try
            if tabpagenr('$') == 1
                if getwininfo()
                    ->filter((_, v: dict<any>): bool =>
                               v.winid != win_getid()
                            && getbufvar(v.bufnr, '&filetype') != 'help')
                    ->empty()
                    # Why `:close` instead of `:quit`?{{{
                    #
                    #     $ vim
                    #     :help
                    #     C-w w
                    #     :quit
                    #
                    # Vim quits entirely instead of only closing the window.
                    # It considers help buffers as unimportant.
                    #
                    # `:close` doesn't close a window if it's the last one.
                    #}}}
                    # Why adding a bang if `&l:bufhidden == 'wipe'`?{{{
                    #
                    # To avoid E37.
                    # Vim refuses to wipe a modified buffer without a bang.
                    # But if  we've set  `'bufhidden'` to `wipe`,  it's probably
                    # not an important buffer.  So, we don't want to be bothered
                    # by an error.
                    #}}}
                    execute 'close' .. (&l:bufhidden == 'wipe' ? '!' : '')
                    return
                endif
            endif
            # Don't replace `:quit` with `:close`.{{{
            #
            # `:quit` fires `QuitPre`; not `:close`.
            #
            # We need `QuitPre`  to be fired so  that `window#unclose#Save()` is
            # automatically called  to save the  current layout, and be  able to
            # undo the closing.
            #}}}
            quit
        catch
            lg.Catch()
        endtry
    endif
enddef
