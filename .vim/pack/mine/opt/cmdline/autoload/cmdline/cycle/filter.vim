vim9script

# Init {{{1

# `:Filter /pat/ cmd` should just run the built-in `:filter` if it can filter `:cmd`.
# We need to teach `:Filter` which commands should not be tampered with.
const FILTERABLE_COMMANDS: list<string> =<< trim END
    #
    l\%[ist]
    nu\%[mber]
    p\%[rint]
    buffers
    lli\%[st]
    files
    hi\%[ghlight]
    ju\%[mps]
    let
    ls
    nm\%[ap]
    vm\%[ap]
    xm\%[ap]
    smap
    om\%[ap]
    map!
    im\%[ap]
    lm\%[ap]
    cm\%[ap]
    tma\%[p]
    no\%[remap]
    nn\%[oremap]
    vn\%[oremap]
    xn\%[oremap]
    snor\%[emap]
    ono\%[remap]
    no\%[remap]!
    ino\%[remap]
    ln\%[oremap]
    cno\%[remap]
    tno\%[remap]
    norea\%[bbrev]
    ca\%[bbrev]
    cnorea\%[bbrev]
    ia\%[bbrev]
    inorea\%[bbrev]
    old\%[files]
    scr\%[iptnames]
    se\%[t]
    set[lg]
    sig\%[n]
END
# }}}1
# Interface {{{1
export def Main(arg_cmd: string, bang: bool) #{{{2
    var pat: string
    var cmd: string
    [pat, cmd] = arg_cmd->matchlist('/\(.\{-}\)/\s*\(.*\)')[1 : 2]

    var first_word: string = cmd->matchstr('\a*\|#')
    if IsFilterable(first_word)
        if pat == ''
            # Need to be run in the legacy context, to suppress `E1126`:{{{
            #
            # E1126: Cannot use :let in Vim9 script
            #}}}
            execute 'legacy filter' .. (bang ? '!' : '') .. ' '
                .. arg_cmd->substitute('/\zs.\{-}\ze/', @/, '')
        else
            execute 'legacy filter' .. (bang ? '!' : '') .. ' ' .. arg_cmd
        endif
        return
    endif

    var output: list<string> = cmd == 'args'
        ?     argv()
        :     execute(cmd)->split('\n')
    echo output
        ->filter((_, v: string): bool => bang ? v !~ pat : v =~ pat)
        ->join("\n")
enddef
export def Completion(_, _, _): string #{{{2
    var matches: list<string> =<< trim END
        %#
        ab
        chi
        com
        hi
        let
        ls
        map
        mess
        old
        scr
        set
    END
    return matches->join("\n")
enddef
# }}}1
# Utilities {{{1
def IsFilterable(first_word: string): bool #{{{2
    for cmd: string in FILTERABLE_COMMANDS
        if first_word =~ '^\C' .. cmd .. '$'
            return true
        endif
    endfor
    return false
enddef
