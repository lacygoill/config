vim9script

import autoload './vimgrep.vim' as _vimgrep

var MAN_PAGES_TO_GREP: dict<list<string>>

# Interface {{{1
export def Main(args: string) # {{{2
    if args == '' || args =~ '^\%(--help\|-h\)\>'
        var help: list<string> =<< trim END
            # look for pattern "foo" in all man pages using current filetype as topic
            :ManGrep foo
            # look for pattern "foo" in all man pages using "bar" as topic
            :ManGrep --apropos=bar foo
        END
        for line: string in help
            var hg: string = line =~ '^:' ? 'Statement' : 'Comment'
            $'echohl {hg}'->execute()
            echo line
            echohl NONE
        endfor
        return
    endif

    var topic: string = args->matchstr('^--apropos=\zs\S*') ?? &filetype
    var pattern: string = args->substitute('^--apropos=\S*\s*', '', '')
    if topic == ''
        echo 'missing topic'
        return
    endif
    if pattern == ''
        echo 'missing pattern'
        return
    endif

    if !MAN_PAGES_TO_GREP->has_key(topic)
        SetManPagesToGrep(topic)
        if !MAN_PAGES_TO_GREP->has_key(topic)
            return
        endif
    endif
    if MAN_PAGES_TO_GREP[topic]->empty()
        return
    endif

    var pattern_and_files: string = $'/{pattern->escape('/')}/gj {MAN_PAGES_TO_GREP[topic]->join()}'
    # `:ManGrep` might be slow.{{{
    #
    # For example, ATM, this command takes around 10s on our machine:
    #
    #     :ManGrep --apropos=fish event
    #}}}
    # Mitigate the issue by trying to run `:vimgrep` asynchronously.
    _vimgrep.Main(pattern_and_files, $':ManGrep {args}')
enddef

export def Complete(..._): string # {{{2
    return ['-h', '--help', '--apropos=']->join("\n")
enddef
# }}}1
# Core {{{1
def SetManPagesToGrep(_topic: string) # {{{2
    var topic: string = _topic
    if topic == 'fish'
        silent var fish_mandir: string = system("fish -c 'echo $__fish_data_dir'")
            ->trim() .. '/man/man1'
        MAN_PAGES_TO_GREP.fish = fish_mandir
            ->readdir()
            ->map((_, v: string) => $'man://{v}(1)')
            ->filter((_, v: string): bool => v !~ '\<fish-\%(doc\|releasenotes\)\>')
        return
    endif

    # For every  config file at  the root  of `/etc/systemd/`, there  exists a
    # dedicated man page.  We don't need to grep *all* systemd man pages; just
    # this one.
    if topic == 'systemd' && expand('%:p') =~ '^/etc/systemd/.*\.conf$'
        topic = $'systemd-{expand('%:p:t')}'
        silent system($'man --where {topic}')
        # These man pages follow an inconsistent naming scheme:{{{
        #
        #     # sometimes, they're prefixed with `systemd-`
        #     /etc/systemd/system.conf   → systemd-system.conf
        #     /etc/systemd/sleep.conf    → systemd-sleep.conf
        #
        #     # sometimes not
        #     /etc/systemd/journald.conf → journald.conf
        #     /etc/systemd/logind.conf   → logind.conf
        #
        # I guess  the `systemd-` prefix  is only used  when necessary to  avoid a
        # clash with another man page.
        #}}}
        if v:shell_error != 0
            topic = topic->substitute('systemd-', '', '')
        endif
        MAN_PAGES_TO_GREP[topic] = [$'man://{topic}']
        return
    endif

    silent var lines: list<string> = systemlist($'man --apropos {topic}')
    if v:shell_error != 0
        echo lines->join("\n")
        return
    endif
    # Why `300`?{{{
    #
    #     # for the "systemd" topic
    #     $ man --apropos systemd | wc --lines
    #     205
    #     ^^^
    #
    # Let's round that number to the nearest multiple of a hundred.
    #}}}
    if lines->len() > 300
        Error($'too many man pages match the topic: {topic}')
        return
    endif
    MAN_PAGES_TO_GREP[topic] = lines
        ->map((_, line: string) => 'man://' .. line
        ->matchstr('[^(]*([^)]*)')
        ->substitute(' ', '', ''))
enddef

export def LoadQuickFixListBuffers() # {{{2
    # We need to export this function so that we can import it from a few scripts.

    # Problem: the quickfix list gets broken once we start jumping to its entries.{{{
    #
    # Initially, the man buffers are unloaded.  Vim loads a man buffer as soon
    # as  you start  jumping to  one  of its  quickfix entry.   And when  that
    # happens, the quickfix list automatically gets updated in a wrong way:
    #
    #     # before
    #     lnum: 123
    #     end_lnum: 123
    #
    #     # after
    #     lnum: <some big number beyond last lnum>
    #     end_lnum: 123
    #}}}
    # Solution: Save the  quickfix list.  Load  all the man  buffers.  Restore
    # the original quickfix list.

    # save quickfix list
    var title: string = getqflist({title: 0}).title
    var qflist: list<dict<any>> = getqflist()
    var qf_buffers: list<number> = qflist
        ->deepcopy()
        ->map((_, v: dict<any>): number => v.bufnr)
        ->uniq()

    # load quickfix buffers
    for buf: number in qf_buffers
        if !buf->bufloaded()
            # We  might call  this  function for  a  quickfix list  containing
            # entries in regular files (not necessarily man buffers).  In that
            # case, `:noswapfile` is necessary.
            noswapfile buf->bufload()
        endif
    endfor

    # restore quickfix list
    setqflist(qflist, 'r')
    setqflist([], 'a', {title: title})
enddef
# }}}1
# Util {{{1
def Error(msg: string) # {{{2
    echohl ErrorMsg
    echomsg msg
    echohl NONE
enddef
