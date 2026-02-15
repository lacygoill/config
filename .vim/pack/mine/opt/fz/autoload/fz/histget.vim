vim9script

import autoload '../fz.vim'

# Interface {{{1
export def Fz() # {{{2
    fz.Run({
        options: [
            $'--prompt="search pattern history {$FZF_PROMPT}"',
        ],
        sink: Sink,
        source: GetSource(),
    })
enddef
# }}}1
# Core {{{1
def GetSource(): list<string> # {{{2
    return range(1, &history)
        ->map((_, i: number) => histget('/', i))
        ->filter((_, pat: string) => pat != '')
enddef

def Sink(chosen: string) # {{{2
    chosen->setreg('/', chosen)
    try
        normal n
    # E486: Pattern not found: ...
    catch /^Vim\%((\a\+)\)\=:E486:/
        echohl ErrorMsg
        echomsg v:exception
        echohl NONE
    endtry
enddef
