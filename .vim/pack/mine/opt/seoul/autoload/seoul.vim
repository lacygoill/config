vim9script

var popup_id: number

export def NextLevel(more = false) #{{{1
    if g:colors_name != 'seoul'
        echomsg 'the current color scheme is not seoul'
        return
    endif

    # that should not happen, but let's make sure the variable has not been
    # deleted by accident
    if !exists('g:SEOUL')
        colorscheme seoul
    endif

    # update `g:SEOUL.current`
    var lvl: number = g:SEOUL.current - g:SEOUL.min
    var max: number = g:SEOUL.max - g:SEOUL.min
    lvl += more ? 1 : - 1
    if lvl < 0
        lvl = max
    elseif lvl > max
        lvl = 0
    endif
    g:SEOUL.current = g:SEOUL.min + lvl

    # now source the color scheme again; the latter will use the update
    # value of `g:SEOUL.current`
    colorscheme seoul

    popup_close(popup_id)
    var msg: string = printf('[lightness] %s / %d', lvl + 1, max + 1)
    popup_id = popup_notification(msg, {
        time: 2'000,
        pos: 'topright',
        line: 1,
        col: &columns,
        maxwidth: strcharlen(msg),
        borderchars: ['─', '│', '─', '│', '┌', '┐', '┘', '└'],
    })
enddef

export def SetTerminalAnsiColors() #{{{1
    var Xresources: list<string> = readfile($'{$HOME}/.Xresources')

    # Make sure Vim uses the ANSI colors of our terminal palette in a terminal buffer.
    # Necessary when `'termguicolors'` is set.
    g:terminal_ansi_colors = Xresources
        ->copy()
        ->filter((_, line: string): bool => line =~ '^\*\.color\d\+:')
        ->sort((l: string, ll: string): number =>
            l->matchstr('\d\+')->str2nr()
            -
            ll->matchstr('\d\+')->str2nr())
        ->map((_, line: string) => line->matchstr('#\x\+'))

    if g:terminal_ansi_colors->empty()
        return
    endif

    # make sure the colors are applied in the first terminal we open
    var buf: number = bufnr('%')
    if &buftype == 'terminal'
        term_setansicolors(buf, g:terminal_ansi_colors)
    endif

    var lnum: number = Xresources->match('^\*\.background:')
    # `Terminal` controls the background color.
    # The foreground color is copied from the `Normal` HG.
    [{name: 'Terminal', guibg: Xresources[lnum]->matchstr('#\x\+')}]
        ->hlset()
enddef
