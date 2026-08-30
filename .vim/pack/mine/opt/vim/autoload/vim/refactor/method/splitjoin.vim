vim9script

import autoload '../../util.vim'

# The pattern conflates an arrow used as a method with one used in a legacy lambda!{{{
#
# You could try to add a negative lookbehind to prevent these wrong matches:
#
#     const ARROW_PAT: string = '\S\zs\ze\%({\s*\%(\%(\S\+\s*,\)\=\s*\S\+\)\=\s*\)\@<!->\a'
#                                        ^-------------------------------------------^
#
# I guess you would to refactor the code so that `ARROW_PAT` becomes a dictionary:
#
#     const ARROW_PAT: dict<string> = {
#         vim9: '\S\zs\ze->\a',
#         legacy: '\S\zs\ze\%({\s*\%(\%(\S\+\s*,\)\=\s*\S\+\)\=\s*\)\@<!->\a',
#     }
#}}}
const ARROW_PAT: string = '\S\zs\ze->\a'

# Interface {{{1
export def Main(type = ''): string #{{{2
    if type == ''
        &operatorfunc = Main
        return 'g@l'
    endif
    var range: list<number> = GetRange()
    if !IsValid(range)
        return ''
    endif
    var pos: list<number> = getcurpos()
    if ShouldSplit(range)
        Split(range)
    else
        Join()
    endif
    setpos('.', pos)
    return ''
enddef
#}}}1
# Core {{{1
def Split(range: list<number>) #{{{2
    var lnum1: number = range[0]
    var lnum2: number = range[1]
    var indent: string = getline('.')->matchstr('^\s*')
    var rep: string = "\x01"
        .. indent
        .. repeat(' ', &l:shiftwidth)
    var new: string = getline(lnum1, lnum2)
        ->map((_, v: string): list<string> =>
                    v->substitute(ARROW_PAT, rep, 'g')
                     ->split('\%x01'))
        ->flattennew()
        ->join("\n")
    util.Put(
        new,
        lnum1, 1,
        lnum2, 1,
        true
    )
enddef

def Join() #{{{2
    var pat: string = '^\s*->\a'
    search('^\%(\s*->\a\)\@!', 'bcW')
    var lastlnum: number = search(pat .. '.*\n\%(' .. pat .. '\)\@!', 'cnW')
    var range: string = ':.+1,' .. lastlnum
    execute range .. 'substitute/^\s*//'
    :'[-1,'] join!
enddef
#}}}1
# Utilities {{{1
def GetRange(): list<number> #{{{2
    var patfirst: string = '^\%(\s*->\a\)\@!.*\n\s*->\a'
    var patlast: string = '^\s*->\a.*\n\%(\s*->\a\)\@!'
    var firstlnum: number = search(patfirst, 'bcnW')
    var lastlnum: number = search(patlast, 'cnW')

    if firstlnum == 0
    || lastlnum == 0
    # we did find a possible start and  end, but the range is invalid because it
    # contains a line which doesn't start with a method call
    || getline(firstlnum, lastlnum)
        ->match('^\%(\s*->\a\)\@!', 0, 2) >= 0

        if getline('.')->match(ARROW_PAT) >= 0
            var curlnum: number = line('.')
            return [curlnum, curlnum]
        endif
        return []
    endif
    return [firstlnum, lastlnum]
enddef

def IsValid(lnums: list<number>): bool #{{{2
    if empty(lnums)
        return false
    endif
    # a valid range must not contain an empty line
    var lnum1: number = lnums[0]
    var lnum2: number = lnums[1]
    var curpos: list<number> = getcurpos()
    cursor(lnum1, 1)
    var has_emptyline: bool = search('^\s*$', 'nW', lnum2) > 0
    setpos('.', curpos)
    return !has_emptyline
enddef

def ShouldSplit(range: list<number>): bool #{{{2
    # we should split if, and only if, we  can find 2 `->` method calls on the
    # same line inside the range
    var lnum1: number = range[0]
    var lnum2: number = range[1]
    var curpos: list<number> = getcurpos()
    cursor(lnum1, 1)
    var result: number = search(ARROW_PAT, 'nW', lnum2)
    setpos('.', curpos)
    return result > 0
enddef
