vim9script

export def FoldExpr(): string #{{{1
    var line: string = getline(v:lnum)

    # % tags
    if line =~ '^%'
        unlet! b:seen_a_command_description
        return '>1'
    endif

    # Empty   line  separating   tags/extension  from   start  of   arguments'
    # definitions.
    if line == ''
            && getline(v:lnum - 1) =~ '^[%@]'
        return '>2'
    endif

    # ; start of some comment in arguments' definitions
    if line =~ '^;'
            && getline(v:lnum - 1) == ''
            && getline(v:lnum + 1) =~ '^;'
        return '>3'
    endif

    # ; end of some comment in arguments' definitions
    if line =~ '^;'
            && getline(v:lnum + 1) !~ '^;'
        return '<3'
    endif

    # empty line right below last argument's definition
    if line == ''
            && getline(v:lnum + 1) =~ '^#'
            && !get(b:, 'seen_a_command_description')
        return '1'
    endif

    if line =~ '^#'
        # cache the fact that we now have seen at least 1 command description
        b:seen_a_command_description = true
        # invalidate the cache after the fold level of all the lines has been computed
        timer_start(0, (_) => {
            unlet! b:seen_a_command_description
        })
        return '>2'
    endif

    if line == ''
            && getline(v:lnum - 1) =~ '^    #'
            && getline(v:lnum + 1) =~ '^%'
        return '1'
    endif

    #     command
    #         # comment 1
    #         #
    #         # ---
    #         #
    #         # comment 2
    #
    # Start fold on line `comment 1`.
    if line =~ '^    # \%(---\)\@!'
            && getline(v:lnum - 1) =~ '^\S\|^    [^#]'
            #                               ^-------^
            #                               to support multiline command
        return '>3'
    endif
    # Start fold on line separating `comment 1` from `comment 2`.
    if line == '    # ---'
        return '>3'
    endif

    # empty line  between 2  consecutive command  descriptions, or  below last
    # commented line of command description
    if line == ''
        if getline(v:lnum + 1) =~ '^%'
            return '1'
        endif
        return '2'
    endif

    return '='
enddef

export def FoldText(): string #{{{1
    var foldstart: string = getline(v:foldstart)
    var linecount: string

    if get(b:, 'foldtitle_full', false)
        var foldsize: number = v:foldend - v:foldstart
        linecount = printf('%-6s', $'[{foldsize}]')
    endif

    if foldstart =~ '^% '
        return linecount .. foldstart
            ->substitute('^% ', '', '')
    endif

    if foldstart == ''
        return linecount .. 'Arguments'
    endif

    if foldstart =~ '^; '
        return linecount .. foldstart
            ->substitute('^; ', '', '')
    endif

    if foldstart =~ '^# '
        return $'{linecount}    ' .. foldstart
            ->substitute('^# ', '', '')
    endif

    if foldstart =~ '^    # \%(---$\)\@!'
        return $'{linecount}    ' .. foldstart
            ->substitute('^    # \%(    \)\=', '    ', '')
    endif

    if foldstart == '    # ---'
        return $'{linecount}    ' .. getline(v:foldstart + 2)
            ->substitute('^    # \%(    \)\=', '    ', '')
            #                    ^---------^
            #                    possible commented codeblock
    endif

    return linecount .. foldstart
enddef

export def NoArgumentInShellComment() #{{{1
# A shell comment should be completely  ignored.  In particular, it should not
# contain a placeholder argument; that would cause `fzf(1)` to prompt us for a
# value.
#
#     # comment including cmd <argument>
#                             ^        ^
#                             ✘        ✘
#
#     # comment including cmd ❬argument❭
#                             ^        ^
#                             ✔        ✔
    var view: dict<number> = winsaveview()
    silent keepjumps keeppatterns :% substitute/\%(^\s\+#.*\)\@<=<\(\w\%(\w\|-\)*\)>/❬\1❭/ge
    view->winrestview()
enddef

export def WarnAgainstUnusedArgument() #{{{1
# Make sure that for every line such as:{{{
#
#     $ argument: some shell command
#
# There is at least 1 `<argument>` placeholder somewhere in the file.
#}}}
    var arguments: list<string> = getline(1, '$')
        ->filter((_, line: string): bool => line =~ '^\$ ')
        ->map((_, line: string) => line->matchstr('\w\%(\w\|-\)*'))
    for argument: string in arguments
        if search($'<{argument}>', 'n') == 0
            unsilent echomsg printf('the "%s" argument is not used', argument)
        endif
    endfor
enddef

export def WarnAgainstMissingExpand() #{{{1
# The `--multi` parameter can be used when specifying the default values of an argument:{{{
#
#     # some comment
#     echo <argument>
#     $ argument: printf '%s\n' a b c --- --multi
#                                         ^-----^
#}}}
#   But we should always accompany it with `--expand`:{{{
#
#     $ argument: printf '%s\n' a b c --- --multi --expand
#                                                 ^------^
#
# If we use `--multi`, it means that we want to be able to select several values.
# Now, suppose we  select `a`, `b` and  `c`, but forgot `--expand`;  here is the
# final inserted shell command:
#
#     $ echo a
#     b
#     c
#
# That's not what  we want.  We want  the arguments to be  separated with spaces
# instead of newlines.  That's what `--expand` does:
#
#     $ echo "a" "b" "c"
#}}}
    # Or with `--map` + `paste(1)`.{{{
    #
    # Because of a bug which prevents `--expand` from working with `--map`:
    # https://github.com/denisidoro/navi/issues/708
    #}}}
    var view: dict<number> = winsaveview()

    var loclist: list<dict<number>>
    var buf: number = bufnr('%')
    for [lnum: number, line: string] in getline(1, '$')->items()
        if line !~ '^\$'
            continue
        endif
        setpos('.', [0, lnum + 1, 1, 0])
        var stopline: number = search('^$\|^[;%@#$]', 'nW')
        var multi_pos: list<number> = searchpos('\%>.l--multi\>', 'cnW', stopline)
        if multi_pos[0] > 0
        && search('\%>.l\%(--expand\|--map\s\+[''"].*\<paste\>.*--serial\)\>', 'cnW', stopline) == 0
            loclist->add({lnum: multi_pos[0], col: multi_pos[1], bufnr: buf})
        endif
    endfor

    view->winrestview()

    if loclist->empty()
        lclose
        return
    endif

    setloclist(0, [], ' ', {
        items: loclist,
        title: '--multi should be used with --expand or --map ''... | paste --serial ...'''
    })
    doautocmd <nomodeline> QuickFixCmdPost lopen
enddef
