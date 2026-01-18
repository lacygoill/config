vim9script

import autoload '../util.vim'

# Init {{{1

var PAT_BAR: string =
    # outside a single-quoted string
    '\%(^\%(''[^'']*''\|[^'']\)*\)\@<='
    # outside a double-quoted string
    # FIXME: This part can find a wrong match:{{{
    #
    # Because of this, if you press `=rb` on this line, it doesn't get broken:
    #
    #                      ✘
    #                      v
    #     if line =~ '^\s*["#]'
    #         return
    #     endif
    #
    # The issue comes from the double quote.
    # Our  regex  wrongly  thinks  that   the  bars  are  inside  an  unfinished
    # double-quoted string.
    #}}}
    .. '\%(^\%("[^"]*"\|[^"]\)*\)\@<='
    # not on a commented line
    .. '\%(^\s*".*\)\@<!'
    # a bar (!= `||`)
    .. '\s*|\@1<!||\@!\s*'
lockvar! PAT_BAR
const MAX_JOINED_LINES: number = 5

# Interface {{{1
export def Main( #{{{2
    type = '',
    arg = '',
    bang = true
): string

    if type == ''
        &operatorfunc = Main
        return 'g@l'
    endif

    var line: string = getline('.')
    if line =~ '^\s*["#]'
        return ''
    endif
    var pos: list<number> = getcurpos()

    try
        if arg != ''
            call(arg[1]->toupper() .. arg[2 :], [bang])
        else
            if line =~ PAT_BAR
                Break(bang)
            else
                Join(bang)
            endif
        endif
    finally
        setpos('.', pos)
    endtry
    return ''
enddef

export def Complete(_, _, _): string #{{{2
    return ['-break', '-join']->join("\n")
enddef
#}}}1
# Core {{{1
def Break(bang: bool) #{{{2
    var lnum: number = line('.')
    if !WeCanRefactor(lnum, lnum, bang, 'break')
        return
    endif
    var line: string = getline('.')
    var word: string = line->matchstr('^\s*\zs\w\+')
        ->Normalize()
    if ['if', 'elseif', 'try', 'echohl']->index(word) >= 0
        # Perform this transformation:{{{
        #
        #     if 1 | echo 'true' | endif
        #
        #     →
        #
        #     if 1
        #         echo 'true'
        #     endif
        #}}}
        execute 'keepjumps keeppatterns substitute/' .. PAT_BAR .. '/\r/ge'
    elseif word =~ '^\Cau\%[tocmd]$'
        # Perform this transformation:{{{
        #
        #     autocmd User test if 1 | echo 'do sth' | endif
        #
        #     →
        #
        #     autocmd User test if 1
        #         \ | echo 'do sth'
        #         \ | endif
        #}}}
        execute 'silent keepjumps keeppatterns substitute/' .. PAT_BAR .. '/\="\<CR> | "/ge'
    else
        return
    endif
    var range: string = ':' .. (line("'[") + 1) .. ',' .. line("']")
    execute range .. 'normal! =='
enddef

def Join(bang: bool) #{{{2
    var line: string = getline('.')
    var word: string = line->matchstr('^\s*\zs\w\+')
        ->Normalize()
    if ['autocmd', 'if', 'try']->index(word) == -1 || line =~ '\C\send\%(if\|try\)\s*$'
        return
    endif
    var mods: string = 'keepjumps keeppatterns'
    var lnum1: number = line('.')
    var range: string
    # Perform this transformation:{{{
    #
    #     if 1
    #         echo 'true'
    #     endif
    #
    #     →
    #
    #     if 1 | echo 'true' | endif
    #}}}
    if word == 'if' || word == 'try'
        var lnum2: number = search('^\s*\Cend\%(if\|try\)\s*$', 'nW')
        # if too many lines are going to be joined, it's probably an error; bail out
        if lnum2 - lnum1 + 1 > MAX_JOINED_LINES
            return
        endif
        if !WeCanRefactor(lnum1, lnum2, bang, 'join')
            return
        endif
        range = ':' .. lnum1 .. ',' .. lnum2
        execute mods .. ' ' .. range .. '-1 substitute/$/ |/'
    # Perform this transformation:{{{
    #
    #     autocmd User test if 1
    #         \ | do sth
    #         \ | endif
    #
    #     →
    #
    #     autocmd User test if 1 | do sth | endif
        #}}}
    elseif word == 'autocmd'
        var lnum2: number = search('^\s*\\\s*|\s*\Cend\%(if\|try\)\s*$', 'nW')
        if lnum2 - lnum1 + 1 > MAX_JOINED_LINES
            return
        endif
        if !WeCanRefactor(lnum1, lnum2, bang, 'join')
            return
        endif
        range = lnum1 .. ',' .. lnum2
        execute mods .. ' ' .. range .. '-1 substitute/$/ |/'
        execute mods .. ' ' .. range .. ' substitute/^\s*\\\s*|\s*//'
    endif
    execute mods .. ' ' .. range .. ' join'
enddef
#}}}1
# Utilities {{{1
def Normalize(word: string): string #{{{2
    return word =~ '^\Cau\%[tocm]$'
        ? 'autocmd'
        : word
enddef

def WeCanRefactor( #{{{2
    arg_lnum1: number,
    arg_lnum2: number,
    bang: bool,
    change: string
): bool

    # first non-whitespace on first line
    var pat1: string = '^\%' .. arg_lnum1 .. 'l\s*\zs\S'
    # last non-whitespace on last line
    var pat2: string = '\%' .. arg_lnum2 .. 'l\S\s*$'
    var view: dict<number> = winsaveview()

    var lnum1: number
    var col1: number
    var s1: number = search(pat1, 'bc')
    [lnum1, col1] = getcurpos()[1 : 2]

    var lnum2: number
    var col2: number
    var s2: number = search(pat2, 'c')
    [lnum2, col2] = getcurpos()[1 : 2]
    if !util.WeCanRefactor(
        [s1, s2],
        lnum1, col1,
        lnum2, col2,
        bang,
        view,
        change == 'break' ? 'bar-separated commands' : 'multiline block',
        change == 'break' ? 'multiline block' : 'bar-separated commands',
    )
        return false
    endif
    return true
enddef
