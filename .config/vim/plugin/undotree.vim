vim9script noclear

if exists('loaded') || stridx(&runtimepath, '/undotree,') == -1
    finish
endif
var loaded = true

import autoload '../autoload/plugin/undotree.vim'

# Give automatically the focus to the `undotree` window.
g:undotree_SetFocusWhenToggle = true

# Don't open automatically the diff window.
g:undotree_DiffAutoOpen = false

# shorten the timestamps (second → s, minute → m, ...)
g:undotree_ShortIndicators = true

# hide “Press ? for help”
g:undotree_HelpLine = false

nnoremap <unique> -u <ScriptCmd>undotree.Show()<CR>

def g:Undotree_CustomMap() #{{{1
    nmap <buffer><nowait><silent> } <Plug>UndotreePreviousSavedState
    nmap <buffer><nowait><silent> { <Plug>UndotreeNextSavedState
    nmap <buffer><nowait><silent> ) <Plug>UndotreePreviousState
    nmap <buffer><nowait><silent> ( <Plug>UndotreeNextState

    nnoremap <buffer><nowait> < <Nop>
    nnoremap <buffer><nowait> > <Nop>
    nnoremap <buffer><nowait> J <Nop>
    nnoremap <buffer><nowait> K <Nop>

    # Purpose: Override the builtin help which doesn't take into account our custom mappings.
    nnoremap <buffer><nowait> ? <ScriptCmd>undotree.ShowHelp()<CR>

    # Purpose: set the preview flag in the diff panel, which lets us:{{{
    #
    #    1. view its contents without focusing it (otherwise, it's squashed to 0 lines)
    #    2. scroll its contents without focusing it (`M-j`, ...)
    #
    # Regarding  `1.`,   you  could   achieve  the   same  result   by  tweaking
    # `HeightShouldBeReset()` in `vim-window`, and include this condition:
    #
    #     || (winbufnr(a:nr)->bufname() =~ '^diffpanel_\d\+$')
    #
    # Regarding `2.`, if you had to focus the diff panel to scroll its contents,
    # its height would be maximized; you  could find this sudden height increase
    # jarring.
    #}}}
    nnoremap <buffer><nowait> D <ScriptCmd>undotree.DiffToggle()<CR>

    # dummy item to get an empty status line
    &l:statusline = '%h'
    b:undo_ftplugin = (get(b:, 'undo_ftplugin') ?? 'execute')
        .. '| set statusline<'
enddef
