vim9script

import 'lg.vim'

export def Complete(findstart: bool, base: string): any #{{{1
    if findstart
        return searchpos('\<\w', 'bcnW')[1] - 1
    endif
    return COMPLETIONS
        ->copy()
        ->filter((_, v: dict<string>): bool => v.word->stridx(base) == 0)
enddef

var COMPLETIONS: list<dict<string>>
{
    var types: list<string> =<< trim END
        augroup
        command
        event
        filetype
        function
        highlight
        option
        var
    END
    for type: string in types
        COMPLETIONS += getcompletion('', type)
            ->map((_, v: string): dict<string> => ({word: v, menu: '[' .. type .. ']'}))
    endfor
}

export def JumpToSyntaxDefinition() #{{{1
    @/ = '^\s*'
        .. '\%(exe\%[cute]\s\+$\=[''"]\)\='
        .. 'syn\%[tax]\s\+\%(keyword\|match\|region\|cluster\)\s\+'
        .. '\zs' .. expand('<cword>') .. '\>'
    search(@/, 's')
    normal! zv
enddef

export def JumpToTag() #{{{1
    var iskeyword_save: string = &l:iskeyword
    var bufnr: number = bufnr('%')
    # Some tags may contain a colon (e.g.: `g:some_function()`).
    #                                       ^
    # When  `C-]` grabs  the  identifier  under the  cursor,  it only  considers
    # characters inside 'iskeyword'.
    setlocal iskeyword+=:
    try
        execute "normal! \<C-]>"
        normal! zvzz
    catch
        lg.Catch()
    finally
        # Why not simply `&l:iskeyword = iskeyword_save`?{{{
        #
        # We may have jumped to another buffer.
        #}}}
        setbufvar(bufnr, '&iskeyword', iskeyword_save)
    endtry
enddef

export def GetHelpUrl() #{{{1
    var winid: number = win_getid()
    # use our custom `K` which is smarter than the builtin one
    normal K
    if expand('%:p') !~ '^' .. $VIMRUNTIME .. '/doc/.*.txt$'
        return
    endif
    var fname: string = expand('%:p')
        ->fnamemodify(':t')
    var tag: string = getline('.')
        ->matchstr('\%.c\*\zs[^*]*')
    if &filetype == 'help'
        close
    endif
    win_gotoid(winid)
    var value: string = printf("[`:help %s`](https://vimhelp.org/%s.html#%s)\n",
        tag,
        fname,
        tag->Encoded()
    )
    setreg('h', value, 'a')
    getreg('h', true, true)
        ->popup_notification({
            time: 2'000,
            pos: 'topright',
            line: 1,
            col: &columns,
            borderchars: ['─', '│', '─', '│', '┌', '┐', '┘', '└'],
        })
enddef

def Encoded(name: string): string
    var Rep: func: string = () => '%' .. submatch(0)
        ->char2nr()
        ->printf('%x')
        ->toupper()
    return name->substitute('[^-_a-zA-Z0-9]', Rep, 'g')
enddef

export def UndoFtplugin() #{{{1
    set commentstring< define< formatlistpat< omnifunc<
    unlet! b:mc_chain

    nunmap <buffer> gf
    nunmap <buffer> <C-W>f
    nunmap <buffer> <C-W>gf

    nunmap <buffer> <C-W>F
    nunmap <buffer> <C-W>GF

    unmap <buffer> [m
    unmap <buffer> ]m
    unmap <buffer> [M
    unmap <buffer> ]M

    nunmap <buffer> <C-]>
    nunmap <buffer> -h

    nunmap <buffer> =rb
    nunmap <buffer> =rd
    nunmap <buffer> =rh
    nunmap <buffer> =ri
    nunmap <buffer> =rl
    nunmap <buffer> =rL
    nunmap <buffer> =r-
    nunmap <buffer> =rq

    xunmap <buffer> ==
    xunmap <buffer> =rd
    xunmap <buffer> =rq
    xunmap <buffer> =rt

    delcommand RefBar
    delcommand RefDot
    delcommand RefHeredoc
    delcommand RefLambda
    delcommand RefQuote
    delcommand RefTernary
enddef
