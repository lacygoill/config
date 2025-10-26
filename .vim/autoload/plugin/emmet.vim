vim9script

# Interface {{{1
export def InstallMappings() #{{{2
    # The default mappings are not silent (and they probably don't use `<nowait>` either).
    # We prefer to make them silent.

    # Why this guard?{{{
    #
    # We need `:EmmetInstall` later at the end of the function.
    # But if we disable `emmet.vim`, it won't exist.
    # Besides, if  `emmet.vim` is disabled,  there's no point in  installing the
    # next mappings (C-g, ...).
    #}}}
    if exists(':EmmetInstall') != 2
        return
    endif

    # Where did you find all the RHS?{{{
    #
    #     :help emmet-customize-key-mappings
    #}}}
    # Why `C-g C-u` instead of simply `C-g u`? {{{
    #
    # To avoid a conflict with the  default `C-g u` command (`:help i^gu`) which
    # breaks the undo sequence.
    #}}}
    # Same question for `C-g C-[jkm]`.{{{
    #
    # To  avoid a  conflict with  our custom mappings:
    #
    #     C-g j    scroll window downward
    #     C-g k    scroll window upward
    #     C-g m    :FzMaps
    #}}}

    imap <buffer><nowait><silent> <C-G>,     <Plug>(emmet-expand-abbr)
    imap <buffer><nowait><silent> <C-G>;     <Plug>(emmet-expand-word)
    imap <buffer><nowait><silent> <C-G><C-U> <Plug>(emmet-update-tag)
    # Mnemonic: `s` for select
    imap <buffer><nowait><silent> <C-G>s     <Plug>(emmet-balance-tag-inward)
    imap <buffer><nowait><silent> <C-G>S     <Plug>(emmet-balance-tag-outword)
    #                                                                     ^ necessary typo
    imap <buffer><nowait><silent> <C-G>n     <Plug>(emmet-move-next)
    imap <buffer><nowait><silent> <C-G>N     <Plug>(emmet-move-prev)
    imap <buffer><nowait><silent> <C-G>i     <Plug>(emmet-image-size)
    imap <buffer><nowait><silent> <C-G>I     <Plug>(emmet-image-encode)
    imap <buffer><nowait><silent> <C-G>/     <Plug>(emmet-toggle-comment)
    imap <buffer><nowait><silent> <C-G><C-J> <Plug>(emmet-split-join-tag)
    imap <buffer><nowait><silent> <C-G><C-K> <Plug>(emmet-remove-tag)
    imap <buffer><nowait><silent> <C-G>a     <Plug>(emmet-anchorize-url)
    imap <buffer><nowait><silent> <C-G>A     <Plug>(emmet-anchorize-summary)

    xmap <buffer><nowait><silent> <C-G>,     <Plug>(emmet-expand-abbr)
    xmap <buffer><nowait><silent> <C-G>;     <Plug>(emmet-expand-word)
    xmap <buffer><nowait><silent> <C-G><C-U> <Plug>(emmet-update-tag)
    xmap <buffer><nowait><silent> <C-G>s     <Plug>(emmet-balance-tag-inward)
    xmap <buffer><nowait><silent> <C-G>S     <Plug>(emmet-balance-tag-outword)
    xmap <buffer><nowait><silent> <C-G>n     <Plug>(emmet-move-next)
    xmap <buffer><nowait><silent> <C-G>N     <Plug>(emmet-move-prev)
    xmap <buffer><nowait><silent> <C-G>i     <Plug>(emmet-image-size)
    xmap <buffer><nowait><silent> <C-G>/     <Plug>(emmet-toggle-comment)
    xmap <buffer><nowait><silent> <C-G><C-J> <Plug>(emmet-split-join-tag)
    xmap <buffer><nowait><silent> <C-G><C-K> <Plug>(emmet-remove-tag)
    xmap <buffer><nowait><silent> <C-G>a     <Plug>(emmet-anchorize-url)
    xmap <buffer><nowait><silent> <C-G>A     <Plug>(emmet-anchorize-summary)

    # these 2 mappings are specific to visual mode
    xmap <buffer><nowait><silent> <C-G><C-M> <Plug>(emmet-merge-lines)
    xmap <buffer><nowait><silent> <C-G>p     <Plug>(emmet-code-pretty)

    # now, we also need to install the `<Plug>` mappings
    execute 'EmmetInstall'
    # Would this work if I lazy-loaded emmet?{{{
    #
    # No.
    #
    # Its interface would not be installed until we read an html or css file.
    # So, the  first time  we would  read an html  or css  file, `:EmmetInstall`
    # would  not exist,  and we  couldn't use  it here  to install  the `<Plug>`
    # mappings.
    #}}}
    # Would there be solutions?{{{
    #
    # You could execute `:EmmetInstall` from a filetype plugin:
    #
    #     if exists(':EmmetInstall') == 2
    #         EmmetInstall
    #     endif
    #
    # When a  filetype plugin is sourced,  it seems the interface  of the plugin
    # would  be finally  installed (contrary  to  when the  current function  is
    # sourced).
    # Or you could install a one-shot autocmd to slightly delay the execution of
    # `:EmmetInstall`:
    #
    #     autocmd BufWinEnter * ++once {
    #         if ['html', 'css']->index(&filetype) >= 0
    #             silent! EmmetInstall
    #         endif
    #     }
    #}}}
    # Why don't you lazy-load emmet?{{{
    #
    # emmet starts already  quickly (less than a fifth  of millisecond), because
    # the core of its code is autoloaded.
    #
    # Besides, we would need to write the same code in different filetype plugins
    # (violate DRY, DIE).
    #
    # Finally, we've had enough issues with lazy-loading in the past.
    # I prefer to avoid it as much as possible now.
    # It's a hack anyway, and you should use  it only as a last resort, and only
    # if the plugin is slow to start because it hasn't been autoloaded:
    #
    #     “Premature optimization is the root of all evil.“
    #}}}

    SetUndoFtplugin()
enddef
#}}}1
# Core {{{1
def SetUndoFtplugin() #{{{2
    b:undo_ftplugin = (get(b:, 'undo_ftplugin') ?? 'execute')
        .. '| call ' .. expand('<SID>') .. 'UndoFtplugin()'
enddef

def UndoFtplugin() #{{{2
    iunmap <buffer> <C-G>,
    iunmap <buffer> <C-G>;
    iunmap <buffer> <C-G><C-U>
    iunmap <buffer> <C-G>s
    iunmap <buffer> <C-G>S
    iunmap <buffer> <C-G>n
    iunmap <buffer> <C-G>N
    iunmap <buffer> <C-G>i
    iunmap <buffer> <C-G>I
    iunmap <buffer> <C-G>/
    iunmap <buffer> <C-G><C-J>
    iunmap <buffer> <C-G><C-K>
    iunmap <buffer> <C-G>a
    iunmap <buffer> <C-G>A

    xunmap <buffer> <C-G>,
    xunmap <buffer> <C-G>;
    xunmap <buffer> <C-G><C-U>
    xunmap <buffer> <C-G>s
    xunmap <buffer> <C-G>S
    xunmap <buffer> <C-G>n
    xunmap <buffer> <C-G>N
    xunmap <buffer> <C-G>i
    xunmap <buffer> <C-G>/
    xunmap <buffer> <C-G><C-J>
    xunmap <buffer> <C-G><C-K>
    xunmap <buffer> <C-G>a
    xunmap <buffer> <C-G>A
    xunmap <buffer> <C-G><C-M>
    xunmap <buffer> <C-G>p
enddef
