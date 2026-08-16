vim9script

import autoload '../fz.vim'

var mode: string

# Interface {{{1
export def Fz() # {{{2
    mode = mode()
    fz.Run({
        options: [
            '--nth=3..',
            $'--prompt="Registers ({mode}) {$FZF_PROMPT}"',
        ],
        sink: Sink,
        source: GetSource(),
    })
enddef
# }}}1
# Core {{{1
def GetSource(): list<string> # {{{2
    # We use `:registers` to get the names of all registers.  But we still use
    # `getreg()`  to get  their contents,  because `:registers`  truncates the
    # latters after one screen line.
    var regnames: list<string> = 'registers'
        ->execute()
        ->split('\n')[1 :]
        ->map((_, reg: string) => reg->matchstr('^  [lbc]  "\zs\S'))

    return regnames
        ->map((_, reg: string) => printf('%s  "%s   ', {v: 'c', V: 'l'}
        ->get(getregtype(reg), 'b'), reg)
        .. reg->getreg(true, true)->join('^J'))
enddef

def Sink(chosen: string) # {{{2
    var regname: string = chosen->matchstr('"\zs.')

    if mode == 'n'
        feedkeys('"' .. regname, 'in')
    elseif mode == 'i'
        feedkeys((col('.') >= col('$') - 1 ? 'a' : 'i') .. "\<C-R>\<C-O>" .. regname, 'in')
    endif
enddef
