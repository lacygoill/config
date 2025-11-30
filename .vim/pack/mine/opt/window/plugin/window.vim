vim9script noclear

if exists('loaded') | finish | endif
var loaded = true

import 'lg/mapping.vim'
import 'lg/window.vim' as LgWindow
import autoload '../autoload/window.vim'
import autoload '../autoload/window/popup.vim'
import autoload '../autoload/window/quit.vim'
import autoload '../autoload/window/unclose.vim'
import autoload '../autoload/window/util.vim'

# Free keys:{{{
#
# By default `C-w [hjkl]` move the focus to an adjacent window.
# We don't use those; we use `C-[hjkl]` instead.
# So you can map them to anything you like.
#}}}

# Init {{{1

# Default height
const D_HEIGHT: number = 10
# Prompt window
const P_HEIGHT: number = 10
# Terminal window
const T_HEIGHT: number = 10
# Quickfix window
const Q_HEIGHT: number = 10
# file “Running” current line (tmuxprompt, websearch)
const R_HEIGHT: number = 5
const R_FT: list<string> = ['tmuxprompt', 'websearch']

# Autocmds {{{1

# When we switch buffers in the same window, sometimes the view is altered.
# We want it to be preserved.
#
# Inspiration: https://stackoverflow.com/a/31581929/8243465

augroup PreserveView
    autocmd!
    autocmd BufWinLeave * if !IsSpecial() | SaveView() | endif
    autocmd BufWinEnter * if !IsSpecial() | RestoreView() | endif
augroup END

augroup WindowHeight
    autocmd!
    # Why `BufWinEnter`?{{{
    #
    # This is useful when splitting a window to open a `websearch` file.
    # When that happens, and `WinEnter` is fired, the filetype has not yet been set.
    # So `SetWindowHeight()` will not properly set the height of the window.
    #
    # OTOH, when `BufWinEnter` is fired, the filetype *has* been set.
    #}}}
    # Why `VimResized`?{{{
    #
    # Split the Vim window horizontally and focus the top window.
    # Split the tmux window horizontally.
    # Close the tmux pane which you've just opened.
    # Notice how the height of the current Vim window is not maximized anymore.
    #}}}
    autocmd BufWinEnter,WinEnter,VimResized * SetWindowHeight()

    autocmd TerminalWinOpen * SetTerminalHeight()

    # necessary since 8.2.0911
    autocmd CmdwinEnter * execute 'resize ' .. &cmdwinheight
augroup END

augroup UncloseWindow
    autocmd!
    autocmd QuitPre * unclose.Save()
augroup END

augroup CustomizePreviewPopup
    autocmd!
    autocmd BufWinEnter * CustomizePreviewPopup()
augroup END

# Functions {{{1
def CustomizePreviewPopup() #{{{2
    var winid: number = win_getid()
    if &previewpopup == '' || win_gettype(winid) != 'preview'
        return
    endif
    setwinvar(winid, '&wincolor', 'Normal')
    # less noise
    var opts: dict<any> = {
        borderchars: ['─', '│', '─', '│', '┌', '┐', '┘', '└'],
        close: 'none',
        resize: false,
        scrollbar: false,
        title: '',
    }
    # Why to delay until the next `WinLeave`?{{{
    #
    # For some reason, the title would not be cleared without the delay.
    # I guess Vim sets it slightly later.
    #}}}
    execute printf('autocmd WinLeave * ++once popup_setoptions(%d, %s)', winid, opts)
enddef

def GetDiffHeight(n: number = winnr()): number #{{{2
    # Purpose:{{{
    # Return the height of a horizontal window whose 'diff' option is enabled.
    #
    # Should  return half  the  height of  the  screen,  so that  we  can see  2
    # viewports on the same file.
    #
    # If the available  number of lines is odd, example  29, should consistently
    # return the bigger half to the upper viewport.
    # Otherwise, when we would change the focus between the two viewports, their
    # heights would constantly change ([15, 14] ↔ [14, 15]), which is jarring.
    #}}}

    var lines: number = &lines - &cmdheight
        # the two statuslines of the two diff'ed windows
        - 2
        # if there're several tabpages, there's a tabline; we must take its height into account
        - ((&showtabline == 2 || &showtabline == 1 && tabpagenr('$') >= 2) ? 1 : 0)
    return fmod(lines, 2) == 0 || n != 1
        ?     lines / 2
        :     lines / 2 + 1
enddef

def HeightShouldBeReset(n: number): bool #{{{2
# Tests:{{{
#
# Whatever change  you perform  on this  function, make sure  the height  of the
# windows are correct after executing:
#
#     :vertical pedit $MYVIMRC
#
# ---
#
# Also, when moving  from the preview window  to the regular window  A, in these
# layouts:
#
#    ┌─────────┬───────────┐
#    │ preview │ regular A │
#    ├─────────┴───────────┤
#    │      regular B      │
#    └─────────────────────┘
#
#    ┌───────────┬───────────┐
#    │ regular A │           │
#    ├───────────┤ regular B │
#    │  preview  │           │
#    └───────────┴───────────┘
#
# ---
#
# Also, when opening a file explorer with a small width, make sure its height is
# correct.  Same thing with undotree window.
# And  when previewing  a file  from the  file explorer,  make sure  the preview
# window's height is always correct (whether it's focused or not).
# Same thing when previewing a diff from an undotree window.
#}}}
    # Reset if, and only if, there's a window above or below.
    ('should_be_reset = '
        ..     "winnr('j') != " .. n
        .. " || winnr('k') != " .. n
    )->win_execute(win_getid(n))
    return should_be_reset
enddef
var should_be_reset: bool

def IfSpecialGetNrHeightTopline(v: number): list<number> #{{{2
#   ^                           ^
#   |                           a window number
#   \ if it's a special window, get me its number, its desired height,
#   and its current topline

    var info: list<number> = getwinvar(v, '&previewwindow')
        ?     [v, &previewheight]
        : R_FT->index(winbufnr(v)->getbufvar('&filetype', '')) >= 0
        ?     [v, R_HEIGHT]
        : &l:diff
        ?     [v, GetDiffHeight(v)]
        : winbufnr(v)->getbufvar('&buftype', '') == 'prompt'
        ?     [v, P_HEIGHT]
        : winbufnr(v)->getbufvar('&buftype', '') == 'terminal' && !util.IsPopup(v)
        ?     [v, T_HEIGHT]
        : winbufnr(v)->getbufvar('&buftype', '') == 'quickfix'
        ?     [v, [Q_HEIGHT, [&winminheight + 2, winbufnr(v)->getbufline(1, Q_HEIGHT)->len()]->max()]->min()]
        :     []
    # to understand the purpose of `&winminheight + 2`, see our comments around `&equalalways = false`
    return empty(info) ? [] : info  + [win_getid(v)->getwininfo()[0]['topline']]
enddef

def IsAloneInTabpage(): bool #{{{2
    return winnr('$') <= 1
enddef

def IsSpecial(): bool #{{{2
    var buf: number = expand('<abuf>')->str2nr()
    return &l:previewwindow
        || &l:diff
        || (R_FT + ['gitcommit'])->index(getbufvar(buf, '&filetype')) >= 0
        || getbufvar(buf, '&buftype') =~ '^\%(quickfix\|terminal\)$'
enddef

def IsWide(): bool #{{{2
    return winwidth(0) >= &columns / 2
enddef

def IsMaximizedVertically(): bool #{{{2
    # Every time you open a  window above/below, the difference between `&lines`
    # and `winheight(0)` increases by 2:
    # 1 for the new statusline + 1 for the visible line in the other window
    var statusline: number = 1
    var tabline: number = (&showtabline == 2 || &showtabline == 1 && tabpagenr('$') >= 2 ? 1 : 0)
    return (&lines - winheight(0)) <= (&cmdheight + statusline + tabline)
enddef

def MakeWindowSmall() #{{{2
    # to understand the purpose of `&winminheight + 2`, see our comments around `&equalalways = false`
    execute 'resize ' .. (&l:previewwindow
        ?              &l:previewheight
        :          &buftype == 'quickfix'
        ?              min([Q_HEIGHT, max([line('$'), &winminheight + 2])])
        :          &l:diff
        ?              GetDiffHeight()
        :          R_FT->index(&filetype) >= 0
        ?              R_HEIGHT
        :          D_HEIGHT)
enddef

def SaveView() #{{{2
# Save current view settings on a per-window, per-buffer basis.
    if !exists('w:saved_views')
        w:saved_views = {}
    endif
    w:saved_views[expand('<abuf>')->str2nr()] = winsaveview()
enddef

def SetWindowHeight() #{{{2
    # Goal: Maximize the height of the current window, on the condition that it's horizontally maximized.{{{
    #
    # Preview/qf/terminal windows  which are horizontally maximized  should have
    # their height fixed to:
    #
    #    - &previewheight for the preview window
    #    - 10 for a qf/terminal window
    #}}}
    # Corner Case:{{{
    #
    # Create a tab  page with a qf  window + a terminal.  The  terminal is big
    # when we switch to  the qf window, then small when we  switch back to the
    # terminal.
    #
    # More generally, I think this  undesired change of height occurs whenever
    # we move  in a tab  page where there are  several windows, but  *all* are
    # special.  This  is a unique and  probably rare case.  So,  I don't think
    # it's worth trying and fix it.
    #}}}

    # Why the `&l:previewwindow` guard?{{{
    #
    # Suppose we  preview a file from  a file explorer.  Chances  are the file
    # explorer, and thus the preview window, are not horizontally maximized.
    #
    # If we  focus the preview window,  its height won't be  set, because it's
    # not horizontally  maximized.  As  a result,  it will  be treated  like a
    # regular window and maximized.  We don't want that.
    #}}}
    #   OK, but how will the height of a preview window will be set then?{{{
    #
    # The preview window is a special case.
    # When you open one, 2 WinEnter are fired; when Vim:
    #
    #    1. enters the preview window (`&l:previewwindow` is *not* yet set)
    #    2. goes back to the original window (now, `&l:previewwindow` *is* set in the preview window)
    #
    # When the first WinEnter is fired, `&l:previewwindow` is not set.
    # Thus, the function should maximize it.
    #
    # When the  second `WinEnter`  is fired,  we'll get  back to  the original
    # window.  It'll probably be a regular  window, and thus be maximized.  As
    # a result, the preview window will  be minimized (1 line high).  But, the
    # code  at the  end of  this  function should  restore the  height of  the
    # preview window.
    #
    # So, in the end, the height of the preview window is correctly set.
    #}}}
    if &l:previewwindow
            # `wincmd _` might give `E994` in a popup terminal.{{{
            #
            # But not if the current tab  page contains only 1 window, because
            # in that case `!IsAloneInTabpage()` is false.
            #}}}
            || util.IsPopup()
        return
    endif

    if getcmdwintype() != ''
        execute 'noautocmd resize ' .. &cmdwinheight
        return
    endif

    var curwinnr: number = winnr()
    if IsSpecial() && IsWide() && !IsAloneInTabpage()
        if winnr('j') != curwinnr || winnr('k') != curwinnr
            MakeWindowSmall()
        endif
        # If  there's no  window above  or below,  resetting the  height of  a
        # special window would lead to a big cmdline.
        return
    endif

    # If we're going to maximize a regular  window, we might alter the height of
    # a special window somewhere else in the current tab page.
    # In this case, we need to reset their height.
    # What's the output of `map()`?{{{
    #
    # All numbers of all special windows in  the current tabpage, as well as the
    # corresponding desired heights and original toplines.
    #}}}
    # Why invoking `filter()`?{{{
    #
    # Each regular  window will have produced  an empty list in  the output of
    # `map()`.  An empty list will cause an  error in the next `for` loop.  So
    # we need to remove them.
    #
    # Also, we shouldn't reset the height of the current window; we've already
    # just  set  its height  (`wincmd _`).   Only  the  heights of  the  other
    # windows:
    #
    #     && v[0] != curwinnr
    #
    # Finally, there're some  special cases, where we don't want  to reset the
    # height of  a special window.  We  delegate the logic to  handle these in
    # `HeightShouldBeReset()`:
    #
    #     && !HeightShouldBeReset(v[0])
    #}}}
    var special_windows: list<list<number>> = range(1, winnr('$'))
        ->map((_, v: number): list<number> => IfSpecialGetNrHeightTopline(v))
        ->filter((_, v: list<number>): bool =>
            v != []
            && v[0] != curwinnr
            && HeightShouldBeReset(v[0]))

    # if we enter a regular window (or Vim's terminal geometry changes), maximize it
    noautocmd wincmd _

    # Why does `'scrolloff'` need to be temporarily reset?{{{
    #
    # We might need to  restore the position of the topline  in a special window
    # by scrolling with `C-e` or `C-y`.
    #
    # When that happens,  if `&scrolloff` has a non-zero value,  we might scroll
    # more than what we expect.
    #
    # MRE:
    #
    #     $ vim -Nu NONE +'set scrolloff=3 | helpgrep foobar' +'cwindow | :2 quit'
    #     :clast | wincmd _ | :2 resize 10
    #     :call win_execute(win_getid(2), "normal! \<C-Y>")
    #
    # After the first Ex command, the last line of the qf buffer is the topline.
    # The second Ex  command should scroll one line upward;  but in practice, it
    # scrolls 4 lines upward (`1 + &scrolloff`).
    #
    # It could be a bug, because I can't always reproduce.
    # For example, if you scroll back so that the last line is again the topline:
    #
    #     :call win_execute(win_getid(2), "normal! 4\<C-E>")
    #
    # Then, invoke `win_execute()` exactly as  when you triggered the unexpected
    # scrolling earlier:
    #
    #     :call win_execute(win_getid(2), "normal! \<C-Y>")
    #
    # This time, Vim scrolls only 1 line upward.
    #
    # ---
    #
    # Sth else is weird:
    #
    #     $ vim -Nu NONE +'set scrolloff=3 | helpgrep foobar' +'cwindow | :2 quit'
    #     :clast
    #
    # The last line of the qf buffer is the *last* line of the window.
    #
    #     :wincmd _ | :2 resize 10
    #
    # The last line of the qf buffer is the *first* line of the window.
    #
    #     :wincmd w | execute "normal! 6\<C-Y>" | wincmd w
    #
    # The last line of the qf buffer is the last line of the window.
    #
    #     :wincmd _ | :2 resize 10
    #
    # The last line of the qf buffer is *still* the last line of the window.
    #
    # So, we have a unique command (`:wincmd _ | :2 resize 10`) which can have a
    # different effect on  the qf window; and  the difference is not  due to the
    # view in the latter, because it's always  the same (the last line of the qf
    # buffer is the last line of the window).
    #}}}
    # Warning:{{{
    #
    # `'scrolloff'` is global-local.
    # So, to be  completely reliable, we would probably need  to reset the local
    # value of the option.
    # It's not an issue at the moment, because we only set the global value, but
    # keep that in mind.
    #}}}
    var scrolloff_save: number = &scrolloff | noautocmd &scrolloff = 0
    for l: list<number> in special_windows
        # Necessary to prevent the command-line's height from increasing.{{{
        #
        # If there's no  window above nor below  the current window, and  we set its
        # height to a few lines only, then the command-line's height increases.
        #
        # Try this to understand:
        #
        #     :10 wincmd _
        #}}}
        if HasNeighborAboveOrBelow(l[0])
        # Necessary to prevent a regular window from being unmaximized if a special window is on the same row.{{{
        #
        #     $ vim -S <(tee <<'EOF'
        #         vim9script
        #         ['#!/bin/bash -', '', 'name=123']
        #             ->writefile( '/tmp/sh.sh')
        #         edit /tmp/sh.sh
        #         split
        #         # run shellcheck(1) on the current script,
        #         # put the errors in the location list,
        #         # open the location window (in a vertical split)
        #         feedkeys('|c', 'x')
        #         # focus the regular window on the right
        #         wincmd l
        #     EOF
        #     )
        #
        # Without this  condition, the  regular window  in the  bottom right
        # corner is minimized; I think we want it to be maximized.
        #}}}
                && !OnSameRow(l[0])
            FixSpecialWindow(l)
        endif
    endfor
    noautocmd &scrolloff = scrolloff_save
enddef

def HasNeighborAboveOrBelow(winnr: number): bool
    win_execute(win_getid(winnr), 'has_above = winnr("k") != winnr()')
    win_execute(win_getid(winnr), 'has_below = winnr("j") != winnr()')
    return has_above || has_below
enddef
var has_above: bool
var has_below: bool

def OnSameRow(n: number): bool
# I guess we  can consider that the special  window `n` is on the  same row as
# the current regular window if, and only  if, both have the same first screen
# row.
    if win_screenpos(n)[0] == win_screenpos(0)[0]
        return true
    endif
    return false
enddef

def FixSpecialWindow(v: list<number>)
    var winnr: number
    var height: number
    var orig_topline: number
    [winnr, height, orig_topline] = v
    # restore the height
    execute 'noautocmd :' .. winnr .. ' resize ' .. height
    # restore the original topline
    var id: number = win_getid(winnr)
    var offset: number = getwininfo(id)[0]['topline'] - orig_topline
    if offset != 0
        var orig_pos: list<number> = getcurpos(id)
        win_execute(id, 'noautocmd normal! ' .. abs(offset) .. (offset > 0 ? "\<C-Y>" : "\<C-E>"))
        # the scrolling might change the cursor position; it should not
        if getcurpos(id) != orig_pos
            win_execute(id, $'setpos(".", {orig_pos->string()})')
        endif
    endif
enddef

def SetTerminalHeight() #{{{2
    if !IsAloneInTabpage() && !IsMaximizedVertically() && !util.IsPopup()
        execute 'noautocmd resize ' .. T_HEIGHT
    endif
enddef

def RestoreView() #{{{2
# Restore current view settings.
    var n: number = bufnr('%')
    # Bail out if the buffer is already displayed in another window.{{{
    #
    # Otherwise, if it was displayed in an  old window, you might think that the
    # cursor jumps in  an unexpected position, which is  jarring.  That happened
    # when we pressed `C-^` to hide and re-display a file.
    #}}}
    if win_findbuf(n)->len() >= 2
        return
    endif
    if exists('w:saved_views') && w:saved_views->has_key(n)
        if !&l:diff
            winrestview(w:saved_views[n])
        endif
        w:saved_views->remove(n)
    else
        # `:help last-position-jump`
        if line("'\"") >= 1
                && line("'\"") <= line('$')
                && &filetype !~ 'commit'
                && ['xxd', 'gitrebase']->index(&filetype) == -1
            normal! g`"
        endif
    endif
enddef
# }}}1
# Mappings {{{1
# C-[hjkl]             move across windows {{{2

nnoremap <unique> <C-H> <ScriptCmd>window.Navigate('h')<CR>
nnoremap <unique> <C-J> <ScriptCmd>window.Navigate('j')<CR>
nnoremap <unique> <C-K> <ScriptCmd>window.Navigate('k')<CR>
nnoremap <unique> <C-L> <ScriptCmd>window.Navigate('l')<CR>

# M-[hjkl] [du] gg G   scroll popup (or preview) window {{{2

execute mapping.Meta('nnoremap <unique> <M-H> <ScriptCmd>popup.Scroll("h")<CR>')
execute mapping.Meta('nnoremap <unique> <M-J> <ScriptCmd>popup.Scroll("j")<CR>')
execute mapping.Meta('nnoremap <unique> <M-K> <ScriptCmd>popup.Scroll("k")<CR>')
execute mapping.Meta('nnoremap <unique> <M-L> <ScriptCmd>popup.Scroll("l")<CR>')

execute mapping.Meta('nnoremap <unique> <M-D> <ScriptCmd>popup.Scroll("C-d")<CR>')
execute mapping.Meta('nnoremap <expr><unique> <M-U> popup.Scroll("C-u")')

execute mapping.Meta('nnoremap <unique> <M-G> <ScriptCmd>popup.Scroll("gg")<CR>')
execute mapping.Meta('nnoremap <unique> <M-S-G> <ScriptCmd>popup.Scroll("G")<CR>')

# SPC (prefix) {{{2

# Provide a `<Plug>` mapping to access  our `quit.Main()` function, so that we
# can call it more easily from other plugins.
# Why don't you use `:normal 1 q` to quit in your plugins?{{{
#
# Yes, we did this in the past:
#
#     :nnoremap <buffer> q <ScriptCmd>normal 1 q<CR>
#
# But it seems to cause too many issues.   We had one in the past involving an
# interaction between `:normal` and `feedkeys()` with the `t` flag.
#
# I  also had  a `E169: Command too recursive`  error, but  I can't  reproduce
# anymore.  I suspect  the issue was somewhere else (maybe  the `<Space>q` was
# not installed  while we were  debugging something); nevertheless,  the error
# message is confusing.
#
# And  the mapping  in itself  can be  confusing to  understand/debug; I  much
# prefer a mapping where the LHS is not repeated in the RHS.
#}}}
nmap <unique> <Space>q <Plug>(my-quit)
nnoremap <unique> <Plug>(my-quit) <ScriptCmd>quit.Main()<CR>
xnoremap <unique> <Space>q <C-\><C-N><ScriptCmd>quit.Main()<CR>

# Warning: Do *not* map `<Space>Q`.{{{
#
# We press  it by accident  too often.   I think that  happens when we  try to
# close a window after opening a path with `ZF`.
#}}}

# Why not `SPC u`?{{{
#
# We often type it by accident.
# When  that happens,  it's  very distracting,  because it  takes  some time  to
# recover the original layout.
#
# Let's try `SPC U`; it should be harder to press by accident.
#}}}
nnoremap <unique> <Space>U <ScriptCmd>unclose.Restore()<CR>
nnoremap <unique> <Space>u <Nop>

nnoremap <unique> <Space>z <ScriptCmd>window.ZoomToggle()<CR>

# C-w (prefix) {{{2

# update window's height – with `doautocmd WinEnter` – when we move it at the very top/bottom
nnoremap <unique> <C-W>J <ScriptCmd>wincmd J <Bar> do <nomodeline> WinEnter<CR>
nnoremap <unique> <C-W>K <ScriptCmd>wincmd K <Bar> do <nomodeline> WinEnter<CR>

# disable `'wrap'` when turning a split into a vertical one
# Alternative:{{{
#
#     augroup NowrapInVertSplits
#         autocmd!
#         autocmd WinLeave * if winwidth(0) != &columns | &l:wrap = false | endif
#         autocmd WinEnter * if winwidth(0) != &columns | &l:wrap = false | endif
#     augroup END
#
# Pro: Will probably cover more cases.
#
# Con: WinLeave/WinEnter is not fired after moving a window.
#}}}
nnoremap <unique> <C-W>H <ScriptCmd>window.DisableWrapWhenMovingToVertSplit('H')<CR>
nnoremap <unique> <C-W>L <ScriptCmd>window.DisableWrapWhenMovingToVertSplit('L')<CR>

# open path in split window/tabpage and unfold
# `C-w f`, `C-w F`, `C-w gf`, ... I'm confused!{{{
#
# Some default normal commands can open a path in another split window or tabpage.
# They all start with the prefix `C-w`.
#
# To understand which suffix must be pressed, see:
#
#    ┌────┬──────────────────────────────────────────────────────────────┐
#    │ f  │ split window                                                 │
#    ├────┼──────────────────────────────────────────────────────────────┤
#    │ F  │ split window, taking into account line indicator like `:123` │
#    ├────┼──────────────────────────────────────────────────────────────┤
#    │ gf │ tabpage                                                      │
#    ├────┼──────────────────────────────────────────────────────────────┤
#    │ gF │ tabpage, taking into account line indicator like `:123`      │
#    └────┴──────────────────────────────────────────────────────────────┘
#}}}
nnoremap <unique> <C-W>f <C-W>fzv
nnoremap <unique> <C-W>F <C-W>Fzv

nnoremap <unique> <C-W>gf <C-W>gfzv
nnoremap <unique> <C-W>gF <C-W>gFzv
nnoremap <unique> <C-W>GF <C-W>GFzv
# easier to press `ZGF` than `ZgF`

xnoremap <unique> <C-W>f <C-W>fzv
xnoremap <unique> <C-W>F <C-W>Fzv

xnoremap <unique> <C-W>gf <C-W>gfzv
xnoremap <unique> <C-W>gF <C-W>gFzv
xnoremap <unique> <C-W>GF <C-W>GFzv

# TODO: Implement a `<C-w>F` visual mapping which would take into account a line address.
# Like `<C-w>F` does in normal mode.
#
# Also, move all mappings which open a path into a dedicated plugin (`vim-gf`).
#}}}2
# z (prefix) {{{2
# z <>              open/focus/close terminal window {{{3
#
# Why `doautocmd WinEnter`?{{{
#
# To update the height of the focused window.
# Atm, we have an autocmd listening  to `WinEnter` which maximizes the height of
# windows displaying a non-special buffer.
#
# So, if  we are in such  a window, we expect  its height to still  be maximized
# after closing a terminal/qf/preview window.
# But that's not what happens without `doautocmd WinEnter`:
#
#     $ vim +'split | helpgrep foobar'
#     :wincmd t
#     :cclose
#}}}
nnoremap <unique> z< <ScriptCmd>window.TerminalOpen()<CR>
nnoremap <unique> z> <ScriptCmd>window.TerminalClose() <Bar> doautocmd <nomodeline> WinEnter<CR>

# z ()  z []                         qf/ll    window {{{3

nnoremap <unique> z( <ScriptCmd>LgWindow.QfOpenOrFocus('qf')<CR>
nnoremap <unique> z) <ScriptCmd>cclose <Bar> doautocmd <nomodeline> WinEnter<CR>

nnoremap <unique> z[ <ScriptCmd>LgWindow.QfOpenOrFocus('loc')<CR>
nnoremap <unique> z] <ScriptCmd>lclose <Bar> doautocmd <nomodeline> WinEnter<CR>

# z {}                               preview  window {{{3

nnoremap <unique> z{ <ScriptCmd>window.PreviewOpen()<CR>
nnoremap <unique> z} <C-W>z<ScriptCmd>doautocmd <nomodeline> WinEnter<CR>

# z"                close all popup windows {{{3

# cannot use `zp` because it's a valid normal command
nnoremap <unique> z" <ScriptCmd>popup.CloseAll()<CR>

# z C-[hjkl]        resize window {{{3

# Why using the `z` prefix instead of the `Z` one?{{{
#
# Easier to type.
#
# `Z C-h`  would mean pressing  the right shift with  our right pinky,  then the
# left control with our left pinky.
# That's 2 pinkys, on different hands; too awkward.
#}}}
nmap <unique> z<C-H> <Plug>(window-resize-h)
nmap <unique> z<C-J> <Plug>(window-resize-j)
nmap <unique> z<C-K> <Plug>(window-resize-k)
nmap <unique> z<C-L> <Plug>(window-resize-l)

nnoremap <Plug>(window-resize-h) <ScriptCmd>window.Resize('h')<CR>
nnoremap <Plug>(window-resize-j) <ScriptCmd>window.Resize('j')<CR>
nnoremap <Plug>(window-resize-k) <ScriptCmd>window.Resize('k')<CR>
nnoremap <Plug>(window-resize-l) <ScriptCmd>window.Resize('l')<CR>

# z[hjkl]           split in any direction {{{3

nnoremap <unique> zh <ScriptCmd>setlocal nowrap <Bar> leftabove  vsplit <Bar> setlocal nowrap<CR>
nnoremap <unique> zl <ScriptCmd>setlocal nowrap <Bar> rightbelow vsplit <Bar> setlocal nowrap<CR>
nnoremap <unique> zj <ScriptCmd>belowright split<CR>
nnoremap <unique> zk <ScriptCmd>aboveleft split<CR>
#}}}2
# Z (prefix) {{{2
# Z                 simpler window prefix {{{3

# Why a *recursive* mapping?{{{
#
# We need the recursiveness, so that, when we type, we can replace <C-W>
# with Z in custom mappings (own+third party).
#
# MRE:
#
#     nnoremap <C-W><CR> <ScriptCmd>echo 'hello'<CR>
#     nnoremap Z <C-W>
#     # press 'Z cr': doesn't work ✘
#
#     nnoremap <C-W><CR> <ScriptCmd>echo 'hello'<CR>
#     nmap Z <C-W>
#     # press 'Z cr': works ✔
#
# Indeed, once  `Z` has  been expanded into  `C-w`, we might  need to  expand it
# *further* for custom mappings using `C-w` in their LHS.
#}}}
nmap <unique> Z <C-W>
xmap <unique> Z <C-W>

# ZQ  ZZ {{{3

# Our `SPC q` mapping is special, it creates a session file so that we can undo
# the closing of the window. `ZQ` should behave in the same way.

nmap <unique> ZQ <Space>q

# If we press `ZZ`, Vim will remap the keys into `C-w Z`, which doesn't do anything.
# We need to restore `ZZ` original behavior.
nmap ZZ <Plug>(my-ZZ-update)<Plug>(my-quit)
nnoremap <Plug>(my-ZZ-update) <ScriptCmd>update<CR>
# }}}1
# Options {{{1

# Purpose:{{{
#
# When you split a window, by default, all the windows are automatically resized
# to have the same height.
# Also when you close a window; although,  this doesn't seem to be the case when
# you close a help window.
#
# This  is annoying  in  various  situations, because  it  can *un*maximize  the
# current window, and *un*squash the non-focused windows.
#
# For example, suppose that:
#
#    - you have 2 horizontal splits
#    - you open our custom file explorer fex (`-t`)
#    - you move your cursor on a file path
#    - you open it in a vertical split (`C-w f`)
#    - you close the latter (`:quit`)
#
# The original 2 horizontal splits are unexpectedly resized.
#
# All of this  shows that it's a general issue which can  affect you in too many
# circumstances.
# Trying to handle  each of them is a  waste of time; let's fix  the root cause;
# let's disable `'equalalways'`.
#}}}
&equalalways = false
# Which pitfall should I be aware of when resetting `'equalalways'`?{{{
#
# It  can cause  `E36` to  be given  whenever you  try to  visit a  qf entry  by
# pressing Enter in the qf window, while the latter is only 1 line high.
#
# Example:
#
#     $ vim +'helpgrep Arthur!'
#     :resize 1
#     # press Enter
#
# Indeed, Vim tries to split the qf window to display the entry.
# But if  the window is only  1 line high, and  Vim can't resize any  window, it
# can't make more room for the new one.
#
# MRE:
#
#     $ vim -Nu NONE +'set noequalalways' +'autocmd QuickFixCmdPost * botright cwindow 2' +'helpgrep readnews'
#     E36: Not enough room˜
#
#     $ vim -Nu NONE +'set noequalalways | :2 split | split'
#     E36: Not enough room˜
#
# In the last example, the final `:split` gives `E36`, because:
#
#    - creating a second window would require 2 lines
#      (one for the text – because `'winminheight'` is 1 – and one for the status line)
#
#    - the top window would still need 2 lines (one for the text, and one for its status line)
#
#    - the top window occupies 3 lines, which is not enough for 2 + 2 lines;
#      it needs to be resized, but Vim can't because `'equalalways'` is reset
#
# ---
#
# That's why  we make sure –  here and in `vim-qf`  – that the qf  window is
# always at least `&winminheight + 2` lines high.
#}}}

# Why setting `'splitbelow'` and `'splitright'`?{{{
#
# When opening a file with long lines, I prefer to do it:
#
#    - on the right if it's vertical
#    - at the bottom if it's horizontal
#
# Rationale:
# When you read a book, the next page is on the right, not on the left.
# When you read a pdf, the next page is below, not above.
#
# ---
#
# However, when displaying a  buffer with short lines, I prefer to  do it on the
# left.
#
# Rationale:
# When you write annotations in a page, you do it in the left margin.
#
# ---
#
# Bottom Line:
# `set splitbelow` and `set splitright`  seem to define good default directions.
# Occasionally though,  we might need  `:topleft` or `:leftabove` to  change the
# direction.
#}}}
# when we create a new horizontal viewport, it should be displayed at the bottom of the screen
&splitbelow = true
# and a new vertical one should be displayed on the right
&splitright = true

# let us squash an unfocused window to 0 lines
&winminheight = 0
# let us squash an unfocused window to 0 columns (useful when we zoom a window with `SPC z`)
&winminwidth = 0

augroup SetPreviewPopupHeights
    autocmd!
    autocmd VimEnter,VimResized * SetPreviewPopupHeights()
augroup END

def SetPreviewPopupHeights()
    &previewheight = &lines / 3
    # make commands which by default would open a preview window, use a popup instead
    #
    #     &previewpopup = printf('highlight:Normal,height:%d,width:%d', &previewheight, (&columns * 2 / 3))

    # TODO: It causes an issue with some of our commands/mappings; like `!m` for example.
    #
    # This is because  `debug#log#Output()` runs `:wincmd P`  which is forbidden
    # when the preview window is also a popup window.
    # Adapt your  code (everywhere) so that  it works whether you  use a regular
    # preview window, or a popup preview window.
enddef
