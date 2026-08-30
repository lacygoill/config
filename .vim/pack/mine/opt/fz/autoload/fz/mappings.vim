vim9script

import autoload '../fz.vim'

# used for the size of the field in which we align the mappings' LHS
const MAX_LHS_LEN: number = 35

# Interface {{{1
export def Fz(mode: string) # {{{2
    var query: string = '!<F !<nop> !<plug> '
    fz.Run({
        options: [
            $'--prompt="Mappings ({mode}) {$FZF_PROMPT}"',
            # Usually (but  not necessarily  always), we're not  interested in
            # `<Plug>` mappings, so let's start without them.
            $'--query="{query}"',
        ],
        sink: (chosen: string) => {
            var lhs: string = chosen
                ->matchstr('^[^ ]*')
                # translate back no-break spaces
                ->tr('∅', "\u00a0")
            feedkeys($':verbose {mode}map {lhs}', 'in')
        },
        # Don't try to cache the source.{{{
        #
        # You need to re-compute the mappings every time, because some of them
        # might be buffer-local.  If you call this function while in buffer A,
        # then later  again while in  buffer B, you  want to see  the mappings
        # local to B, and not the ones local to A.
        #}}}
        source: GetSource(mode),
    })
enddef
# }}}1
# Core {{{1
def GetSource(mode: string): list<string> # {{{2
    #             mode (e.g. nox)       special characters (e.g. *@)
    #                   vvv             v----------v
    var pat: string = '^...\([^ ]*\)\s\+[*&]\=[@ ]\=\(.*\)'
    #                      ^-------^                ^----^
    #                         LHS                    RHS

    var source: list<string> = execute(mode .. 'map')
        # some of our  mappings use no-break spaces in  their LHS (`submode`);
        # make them distinct from regular spaces
        ->tr("\u00a0", '∅')
        ->split('\n')
        ->map((_, line: string) => line->substitute(pat, Rep, ''))

    # align all the LHS in a field
    var longest: number = source
        ->mapnew((_, line: string): number =>
            line->matchstr('^[^ ]*')->strcharlen())
        ->max()
    longest = min([MAX_LHS_LEN, longest])
    return source
        ->map((_, line: string) =>
        line->matchstr('^[^ ]*')->printf('%-' .. longest .. 'S')
        .. ' ' .. line->matchstr('^[^ ]*\s\+\zs.*'))
enddef

var Rep: func = (m) => m[1] .. ' ' .. m[2]
