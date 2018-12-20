fu! colorscheme#customize() abort "{{{1
    " hide the EndOfBuffer char (~) by changing its ctermfg attribute (ctermfg=bg)
    " Why the `:try` conditional?{{{
    "
    " Some colorschemes don't set up the `Normal` HG.
    " So, the value `bg` may not exist for all colorschemes.
    " Example:
    "         :colo default
    "         →       Error detected while processing .../colors/my_customizations.vim:
    "                 E420: BG color unknown
    "}}}
    try
        if $DISPLAY is# ''
            hi EndOfBuffer ctermfg=bg
        else
            hi EndOfBuffer ctermfg=bg guifg=bg
        endif
    catch
        call lg#catch_error()
    endtry

    " the `SpecialKey` HG installed by seoul256 is barely readable
    hi! link SpecialKey Special

    " Is there an alternative?{{{
    "
    " Yes, you can configure the 'hl' option in Vim.
    "}}}
    " Can it be used for other HGs?{{{
    "
    " Yes among others, there is `SpecialKey`.
    "}}}
    " How to configure 'hl' to achieve the same result?{{{

    " " We must reset the option so that we can change the configuration, resource
    " " our vimrc, and immediately see the result.
    " set hl&vim
    "
    " "       ┌─ column used to separate vertically split windows
    " "       │
    " set hl-=c:VertSplit hl+=c:StatusLine
    " "         │               │
    " "         │               └─ new HG
    " "         └─ default HG
    "
    " "       ┌─ Meta and special keys listed with ":map"
    " "       │
    " set hl-=8:SpecialKey hl+=8:Special
    "}}}
    " How does it work?{{{
    "
    " The global 'hl' option can be used  to configure the style of various elements
    " in the UI.
    " It contains a comma separated list of values.
    "
    " Each value follows one the following syntax:

    "       ┌ character standing for which element of the UI we want to configure
    "       │         ┌ character standing for which style we want to apply
    "       ├────────┐├────┐
    "       {occasion}{mode}

    "       {occasion}:{HG}
    "                   │
    "                   └ highlight group to color the element of the UI

    " The default values all use the 2nd syntax. They all use a HG.
    " But you could also use a mode:
    "
    "         r  reverse
    "         i  italic
    "         b  bold
    "         s  standout
    "         u  underline
    "         c  undercurl
    "         n  no highlighting
    "}}}
    " Why don't you use it anymore?{{{
    "
    " It's deprecated in Neovim.
    " It feels useless, since we don't need this option to configure any HG.
    "}}}
    hi! link VertSplit Normal

    " Custom HGs

    " We're going to define 2 HGs: User1 and User2.
    " We use them in the status line to customize the appearance of:
    "
    "     • the filename
    "     • the modified flag
    "
    " We want their  attributes to be the  same as the ones of  the HG `StatusLine`,
    " except for one: `reverse` (boolean flag).
    "
    " `User1` and `StatusLine` should have opposite values for the `reverse` attribute.
    " Also, we set the color of the background of `User2` as the same as the
    " foreground color of `Todo`, so that the modified flag clearly stands out.

    " Why the delay?{{{
    "
    " gVim encounters some errors when trying to set up too early some of our custom
    " HGs defined in `~/.vim/colors/my/customizations.vim`:
    "
    "     E417: missing argument: guifg=
    "     E254: Cannot allocate color 95
    "     E254: Cannot allocate color 187
    "
    " The  issue seems  to be  that  the HGs  whose  attributes we  need to  inspect
    " ('StatusLine',  'TabLine',   ...),  are  not  (correctly)   defined  yet  when
    " `~/.vim/colors/my/customizations.vim` is sourced by gVim.
    "}}}
    if has('gui_running') && has('vim_starting')
        augroup delay_colorscheme_when_gvim_starts
            au!
            au VimEnter * call s:set_custom_hg()
        augroup END
    else
        call s:set_custom_hg()
    endif
endfu

fu! colorscheme#save_last_version() abort "{{{1
    let line = 'let g:my_last_colorscheme = '.get(g:, 'seoul256_current_bg', 253)
    call writefile([line], $HOME.'/.vim/colors/my/last_version.vim')
endfu

fu! colorscheme#set() abort "{{{1
    let seoul_bg = get(g:, 'my_last_colorscheme', 253)

    if seoul_bg >= 233 && seoul_bg <= 239
        let g:seoul256_background = seoul_bg
        colo seoul256
    else
        let g:seoul256_light_background = seoul_bg
        colo seoul256-light
    endif

    " If `let g:seoul256_srgb` is set to 1, the color mapping is altered to suit
    " the way  urxvt (and various  other terminals) renders them. That  way, the
    " colors of the terminal and GUI versions are uniformly colored on Linux.
    "
    "         https://github.com/junegunn/seoul256.vim#alternate-256-xterm---srgb-mapping

    let g:seoul256_srgb = 1
endfu

fu! s:set_custom_hg() abort "{{{1
    call s:user()
    call s:styled_comments()
    call s:tabline()
endfu

fu! s:styled_comments() abort "{{{1
    " How is this function called?{{{
    "
    " 1. `vimrc` installs:
    "
    "     au ColorScheme * call colorscheme#customize()
    "
    " 2. `colorscheme#customize()` calls `s:set_custom_hg()`
    "
    " 3. `s:set_custom_hg()` calls `s:styled_comments()`
    "}}}
    let attributes = {
        \ 'fg'      : 0,
        \ 'bg'      : 0,
        \ 'bold'    : 0,
        \ 'reverse' : 0,
        \ }

    call map(attributes, {k,v -> synIDattr(synIDtrans(hlID('Comment')), k)})

    for [attribute, hg] in items({'bold': 'CommentStrong', 'italic': 'CommentEmphasis'})
        let cmd = has('gui_running')
              \ ?     'hi '.hg.' gui='.attribute.' guifg=%s'
              \ : &tgc
              \ ?     'hi '.hg.' term='.attribute.' cterm='.attribute.' guifg=%s'
              \ :     'hi '.hg.' term='.attribute.' cterm='.attribute.' ctermfg=%s'
        exe printf(cmd, attributes.fg)
    endfor

    " if &background is# 'light'
    "     exe 'hi CommentCodeSpan '.(has('gui_running') || &tgc ? 'guifg' : 'ctermfg').'=235'
    " else
    "     exe 'hi CommentCodeSpan '.(has('gui_running') || &tgc ? 'guifg' : 'ctermfg').'=255'
    " endif

    " TODO: maybe find better color for blockquotes, codespans and codeblocks
    " TODO: make sure that the colors are readable no matter the lightness,
    " and even when we use the dark colorscheme (and even in GUI)
    if has('gui_running') || &tgc
        exe 'hi CodeSpan guibg=#bcbcbc'
        exe 'hi CommentCodeSpan guibg=#bcbcbc guifg=' . attributes.fg
        exe 'hi CommentBlockQuote gui=italic guibg=#bcbcbc guifg=' . attributes.fg
    else
        exe 'hi CodeSpan ctermbg=250'
        exe 'hi CommentCodeSpan ctermbg=250 ctermfg=' . attributes.fg
        exe 'hi CommentBlockQuote term=italic cterm=italic ctermfg=' . attributes.fg
    endif

    " if has('gui_running') || &tgc
    "     exe 'hi CommentCodeSpan guifg=#9A7372'
    " else
    "     exe 'hi CommentCodeSpan ctermfg=95'
    " endif

endfu

fu! s:tabline() abort "{{{1
    " the purpose of this function is to remove the underline value from the HG
    " TabLine

    let attributes = {
        \ 'fg'      : 0,
        \ 'bg'      : 0,
        \ 'bold'    : 0,
        \ 'reverse' : 0,
        \ }

    call map(attributes, {k,v -> synIDattr(synIDtrans(hlID('Tabline')), k)})

    let cmd = has('gui_running')
          \ ?     'hi TabLine gui=none guifg=%s'
          \ : &tgc
          \ ?     'hi TabLine term=none cterm=none guifg=%s'
          \ :     'hi TabLine term=none cterm=none ctermfg=%s'

    " For  some  values of  `g:seoul{_light}_background`,  the  fg attribute  of
    " Tabline doesn't have any value in gui. In this case, executing the command
    " will fail.
    if attributes.fg is# ''
        return
    endif
    exe printf(cmd, attributes.fg)
endfu

fu! s:user() abort "{{{1
    " `ctermfg`, `ctermbg`, `guifg`, `guibg` are not attributes of the HG
    " `StatusLine`. They are arguments for the `:hi` command.
    " They allow us to set the real attributes (`fg` and `bg`) for Vim in
    " terminal or in GUI.
    let attributes = {
        \ 'fg'      : 0,
        \ 'bg'      : 0,
        \ 'bold'    : 0,
        \ 'reverse' : 0,
        \ }

    call map(attributes, {k,v -> synIDattr(synIDtrans(hlID('StatusLine')), k)})

    if has('gui_running')
        " When 'termguicolors' is set, you set up:
        "
        "     • the style  of a HG with the argument  `cterm`   , not `gui`
        "     • the colors of a HG with the arguments `gui[fb]g`, not `cterm[fb]g`
        "
        " IOW, 'tgc' has an effect on how you set up the COLORS of a HG, but not
        " its STYLE.
        let cmd1 = 'hi User1  gui=%s  guifg=%s  guibg=%s'
        let cmd2 = 'hi User2  gui=%s  guifg=%s  guibg=%s'

    elseif &tgc
        let cmd1 = 'hi User1  cterm=%s  guifg=%s  guibg=%s'
        let cmd2 = 'hi User2  cterm=%s  guifg=%s  guibg=%s'

    else
        let cmd1 = 'hi User1  cterm=%s ctermfg=%s ctermbg=%s'
        let cmd2 = 'hi User2  cterm=%s ctermfg=%s ctermbg=%s'
        "                                       │
        "                                       └ yes, you could use `%d`
        "                                         but you couldn't use `%d` for `guifg`
        "                                         nor `%x`
        "                                         nor `%X`
        "                                         only `%s`
        "                                         so, we use `%s` everywhere
    endif

    " For some  colorschemes (default, darkblue,  …), some values used  in the
    " command which is  going to be executed may be  empty. If that happens, the
    " command will fail:
    "
    "         Error detected while processing function <SNR>18_set_user_hg:
    "         E421: Color name or number not recognized: ctermfg= ctermbg=
    if attributes.fg is# '' || attributes.bg is# ''
        return
    endif

    let style1 = (attributes.bold ? 'bold,' : '').(attributes.reverse ? '' : 'reverse')
    if style1 is# '' | return | endif

    exe printf(cmd1, style1, attributes.fg, attributes.bg)

    let style2 = (attributes.bold ? 'bold,' : '').(attributes.reverse ? 'reverse' : '')
    if style2 is# '' | return | endif

    let todo_fg = synIDattr(synIDtrans(hlID('Todo')), 'fg')
    exe printf(cmd2, style2, todo_fg, attributes.bg)
endfu

