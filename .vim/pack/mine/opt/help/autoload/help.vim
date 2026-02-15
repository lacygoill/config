vim9script

# Init {{{1

import 'lg.vim'

# the patterns can be found in `$VIMRUNTIME/syntax/help.vim`
const PAT_HYPERTEXT: string = '\\\@1<!|[#-)!+-~]\+|'
const PAT_OPTION: string = '''[a-z]\{2,\}''\|''t_..'''

const SYNTAX_GROUPS_HYPERTEXT: list<string> =<< trim END
    helpBar
    helpHyperTextJump
END

const SYNTAX_GROUPS_OPTION: list<string> = ['helpOption']

# Interface {{{1
export def PreviewTag() #{{{2
    if (SYNTAX_GROUPS_HYPERTEXT + SYNTAX_GROUPS_OPTION)->index(SyntaxUnderCursor()) == -1
        return
    endif
    try
        # Why not `:execute 'ptag ' .. ident`?{{{
        #
        # Not reliable enough.
        #
        # For example,  if an  identifier in  a help file  begins with  a slash,
        # `:ptag` will – wrongly – interpret it as a regex, instead of a literal
        # string.
        #
        # Example:
        #
        #     :help usr_41
        #     /\\C
        #
        # You would need to escape the slash:
        #
        #     let ident = '/\V' .. escape(ident[1 :], '\')
        #}}}
        wincmd }
    catch
        lg.Catch()
    endtry

    HighlightTag()
    # Why `wincmd _`?{{{
    #
    # After  closing  the preview  window,  the  help window  isn't  maximized
    # anymore.
    #}}}
    # Do *not* use the autocmd pattern `<buffer>`.{{{
    #
    # The preview  window wouldn't  be closed  when we press  Enter on  a tag,
    # because –  if the  tag is  defined in  another file  – `CursorMoved`
    # would be fired in the new buffer.
    #}}}
    autocmd CursorMoved * ++once ClosePreview()
enddef

export def JumpToTag(type: string, dir: string) #{{{2
    var flags: string = (dir == 'previous' ? 'b' : '') .. 'W'

    var pos: list<number> = getcurpos()
    var pat: string
    if type == 'option'
        pat = PAT_OPTION
    elseif type == 'hypertext'
        pat = PAT_HYPERTEXT
    endif
    var find_sth: bool = search(pat, flags) > 0

    while find_sth && !HasRightSyntax(type)
        find_sth = search(pat, flags) > 0
    endwhile

    if !HasRightSyntax(type)
        setpos('.', pos)
    else
        # allow us to jump back with `C-o`
        var new_pos: list<number> = getcurpos()
        setpos('.', pos)
        normal! m'
        setpos('.', new_pos)
    endif
enddef

export def UndoFtplugin() #{{{2
    set commentstring<
    set concealcursor<
    set conceallevel<
    set keywordprg<
    set tabstop<
    set textwidth<
    autocmd! MyHelpWindow * <buffer>

    silent! nunmap <buffer> p
    silent! xunmap <buffer> p

    silent! nunmap <buffer> q
    silent! nunmap <buffer> u

    nunmap <buffer> (
    nunmap <buffer> )
    nunmap <buffer> <<
    nunmap <buffer> >>
    nunmap <buffer> z}
    nunmap <buffer> <CR>
    nunmap <buffer> <BS>
enddef
#}}}1
# Core {{{1
def HighlightTag() #{{{2
    var winid: number = PreviewGetId()
    var matchid: number = getwinvar(winid, 'help_preview_tag', 0)
    if matchid != 0
        matchdelete(matchid, winid)
    endif
    win_execute(winid, 'w:help_tag_pos = getcurpos()')
    var lnum: number
    var col: number
    [lnum, col] = getwinvar(winid, 'help_tag_pos')[1 : 2]
    var pat: string = '\%' .. lnum .. 'l\%' .. col .. 'c\S\+'
    var preview_tag: number = matchadd('IncSearch', pat, 0, -1, {window: winid})
    setwinvar(winid, 'help_preview_tag', preview_tag)
enddef

def ClosePreview() #{{{2
    if &previewpopup != ''
        popup_findpreview()->popup_close()
    else
        pclose
        wincmd _
    endif
enddef
#}}}1
# Utilities {{{1
def HasRightSyntax(type: string): bool #{{{2
    var syngroups: list<string>
    if type == 'option'
        syngroups = SYNTAX_GROUPS_OPTION
    else
        syngroups = SYNTAX_GROUPS_HYPERTEXT
    endif
    return syngroups->index(SyntaxUnderCursor()) >= 0
enddef

def SyntaxUnderCursor(): string #{{{2
    # twice because of a bug: https://github.com/vim/vim/issues/5252
    var id: number = synID('.', col('.'), true)
    id = synID('.', col('.'), true)
    return synIDattr(id, 'name')
enddef

def PreviewGetId(): number #{{{2
    var winid: number
    if &previewpopup != ''
        winid = popup_findpreview()
    else
        var winnr: number = range(1, winnr('$'))
            ->map((_, v: number): bool => getwinvar(v, '&previewwindow'))
            ->match('true') + 1
        winid = win_getid(winnr)
    endif
    return winid
enddef
