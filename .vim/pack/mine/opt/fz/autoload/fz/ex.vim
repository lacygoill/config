vim9script

import autoload '../fz.vim'

# used for the size of the field in which we align the command names
const MAX_CMD_LEN: number = 35

var SOURCE: list<string>

# Interface {{{1
export def Commands() # {{{2
    if SOURCE->empty()
        SetSource()
    endif

    fz.Run({
        options: [$'--prompt="Ex Commands {$FZF_PROMPT}"'],
        sink: (chosen: string) => {
            var cmd: string = chosen->matchstr('\S*')
            feedkeys($':verbose command {cmd}', 'in')
        },
        source: SOURCE,
    })
enddef
# }}}1
# Core {{{1
def SetSource() # {{{2
    # We're only interested in the command name and its definition; all the other fields are noise.{{{
    #
    #     flags
    #     v--v
    #     !|   SomeCmd    ?    .  win    customlist    ...
    #                     ^    ^----^    ^--------^
    #                    Args  Address    Complete
    #
    #}}}
    #                   flags      arguments
    #                   v--v       v--------v
    var pat: string = '^....\(\S*\).*\%47c\S*\(.*\)$'
    #                       ^-----^          ^----^
    #                     command name         definition

    SOURCE = execute('command')
        # remove header
        ->substitute('\_.\{-}Definition\n', '', '')
        # make Vim9 block easier to read
        ->substitute('\s*<NL>\s*', ' | ', 'g')
        ->split('\n')
        ->map((_, line: string) => line->substitute(pat, Rep, ''))

    # align all the names of commands in a field
    var longest: number = SOURCE
        ->mapnew((_, line: string): number =>
            line->matchstr('^\S*')->strcharlen())
        ->max()
    longest = min([MAX_CMD_LEN, longest])
    SOURCE->map((_, line: string) =>
        line->matchstr('^\S*')->printf('%-' .. longest .. 'S')
        .. ' ' .. line->matchstr('^\S*\s\+\zs.*'))
enddef

var Rep: func = (m) => m[1] .. m[2]
