vim9script

const FISH_START_BLOCK: string = '\%(begin\|function\|if\|switch\|for\|while\)\>'
const TEMPSCRIPT: string = $'{$TMPDIR}/vim/omni_completion.fish'

export def Complete(findstart: bool, base: string): any #{{{1
    if findstart
        return searchpos('\%(^\|\s\)\zs\S', 'bnW', line('.'))[1] - 1
    endif

    if base->empty()
        return []
    endif

    var to_complete: string = getline('.')->matchstr('^.*\%.c') .. base
    var fish_command: string = to_complete
        ->shellescape()
        ->printf('complete --do-complete %s')
    [fish_command]->writefile(TEMPSCRIPT, 'D')
    # Don't try to pass the code directly to fish; use a temporary script.{{{
    #
    #     $ fish --command='complete --do-complete %s'
    #
    # It  might work  on  simple  lines, but  handling  possible quotes  (and/or
    # special syntaxes  like command substitutions)  in the general case  is too
    # difficult.
    #}}}
    silent var completions: list<string> = systemlist('fish ' .. TEMPSCRIPT)

    return completions
        ->filter((_, completion: string): bool => completion->stridx(base) == 0)
        ->mapnew((_, completion: string): list<string> => completion->split('\t'))
        ->map((_, split: list<string>) => ({
            word: split[0],
            menu: split->get(1, '')
        }))
enddef

export def FixEndBuiltinHighlight() #{{{1
# The `end` builtin  is too ambiguous to be correctly  highlighted by our syntax
# plugin.  Let's use text properties to fix this.
# To  find  the  matching builtin  which  starts  the  block,  we use  the  line
# indentation level as a simple heuristic.  That's not correct, but in practice,
# it should be good enough.

    # Clearing the properties is necessary in  case we reload the syntax without
    # reloading the buffer (e.g. `:doautocmd Syntax`, `=d`, ...).
    var buf: number =  bufnr('%')
    prop_clear(1, line('$'), {type: 'fishEndConditional'})
    prop_clear(1, line('$'), {type: 'fishEndRepeat'})

    if prop_type_get('fishEndConditional', {bufnr: buf})->empty()
        prop_type_add('fishEndConditional', {
            bufnr: buf,
            highlight: 'Conditional',
            combine: false,
        })
        prop_type_add('fishEndRepeat', {
            bufnr: buf,
            highlight: 'Repeat',
            combine: false,
        })
    endif

    var view: dict<number> = winsaveview()
    # let's find an `end` line
    for lnum: number in range(1, line('$'))
        var line: string = getline(lnum)
        # we found one
        if line =~ '^\s*end\>'
            # let's try to guess the starting builtin
            var col: number = indent(lnum) + 1
            # We purposefully consider `begin` and `function` here.{{{
            #
            # Even  though we  don't need  to change  the highlighting  of their
            # `end` statement.
            #
            #     if ...
            #         ...
            #     end
            #     begin
            #         ...
            #     end
            #
            # If we ignored  `begin`, when handling the 2nd  `end`, our function
            # would find  `if`; it  would infer that  this `end`  terminates the
            # `if`, which is wrong.
            #}}}
            var builtin: string = FISH_START_BLOCK
            # Remember that while we can assume `end` to be at the start of a line,
            # the same is not true for the starting command:{{{
            #
            #     ...
            #     ... \
            #     vv
            #     | while ...
            #         ...
            #       end
            #       ^
            #}}}
            builtin = '\%' .. col .. 'c' .. builtin
            setpos('.', [0, lnum, 0, 0])
            var block_start: string = search(builtin, 'bnW')
                ->getline()
                ->matchstr('\l\+')

            # bail out if  we did not find  anything, or if we  found `begin` or
            # `function` (because their highlighting looks OK)
            if ['', 'begin', 'function']->index(block_start) >= 0
                continue
            endif

            # highlight the matching command
            if block_start == 'for' || block_start == 'while'
                prop_add(lnum, col, {length: 3, type: 'fishEndRepeat'})
            else
                prop_add(lnum, col, {length: 3, type: 'fishEndConditional'})
            endif
        endif
    endfor
    winrestview(view)
enddef

export def FoldExpr(): string #{{{1
    var line: string = getline(v:lnum)
    #     command
    #         # comment 1
    #         #
    #         # ---
    #         #
    #         # comment 2
    #
    # Start fold on line `comment 1`.
    if line =~ '^    # \%(---$\)\@!'
            && getline(v:lnum - 1) =~ '^\S'
        return '>1'
    endif
    # Start fold on line separating `comment 1` from `comment 2`.
    if line == '    # ---'
        return '>1'
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

    if foldstart == '    # ---'
        return linecount .. getline(v:foldstart + 2)
            ->TrimIndentAndCommmentLeader()
    endif

    return linecount .. foldstart
        ->TrimIndentAndCommmentLeader()
enddef

def TrimIndentAndCommmentLeader(line: string): string
    return line
        ->substitute('^\s*# \%(    \)\=', '    ', '')
    #                       ^---------^
    #                       possible commented codeblock
enddef

export def GetMatchWords(): string #{{{1
    var curword: string = expand('<cword>')
    var indent: string = getline('.')->matchstr('^\s*')
    var start_middle_end: list<string>

    if curword == 'function' || curword == 'return'
        start_middle_end = [
            '^function\>',
            '\%(^\s*\)\@<=return\>',
            '^end\>'
        ]

    elseif curword == 'if' || curword == 'else'
        start_middle_end = [
            '\%(^' .. indent .. '\)\@<=if\>',
            '\%(^' .. indent .. '\)\@<=else\>',
            '\%(^' .. indent .. '\)\@<=end\>'
            ]

    elseif curword == 'switch' || curword == 'case'
        if curword == 'case'
            indent = search('^\s*switch\>', 'bnW')
                ->getline()
                ->matchstr('^\s*')
        endif
        start_middle_end = [
            '\%(^' .. indent .. '\)\@<=switch\>',
            '\%(^\s*\)\@<=case\>',
            '\%(^' .. indent .. '\)\@<=end\>'
        ]

    elseif curword == 'for' || curword == 'while'
        start_middle_end = [
            '^' .. indent .. curword .. '\>',
            '\%(^\s*\)\@<=break\>',
            '\%(^' .. indent .. '\)\@<=end\>'
        ]

    elseif curword == 'break'
        indent = search('^\s*\%(for\|while\)\>', 'bnW')
            ->getline()
            ->matchstr('^\s*')
        start_middle_end = [
            '\%(^' .. indent .. '\)\@<=\%(for\|while\)\>',
            '\%(^\s*\)\@<=\<break\>',
            '\%(^' .. indent .. '\)\@<=end\>'
        ]

    elseif curword == 'begin'
        start_middle_end = [
            '\%(^' .. indent .. '\)\@<=begin\>',
            '\%(^' .. indent .. '\)\@<=end\>',
        ]

    elseif curword == 'end'
        var middle: string
        var start = search('^' .. indent .. FISH_START_BLOCK, 'bnW')
            ->getline()
            ->matchstr('\S\+')
        if start == 'if'
            middle = 'else'
        elseif start == 'for' || start == 'while'
            middle = 'break'
        elseif start == 'switch'
            middle = 'case'
        endif
        if middle != ''
            middle = '\%(^\s*\)\@<=' .. middle .. '\>'
        endif
        start_middle_end = [
            '\%(^' .. indent .. '\)\@<=' .. FISH_START_BLOCK,
            middle,
            '\%(^' .. indent .. '\)\@<=end\>'
        ]
    endif

    if start_middle_end->empty()
        return ''
    endif

    return start_middle_end->join(':')
enddef

export def ReadTemplate() #{{{1
    var cmd_name: string = expand('<afile>:t:r')
    var lines: list<string> =<< trim eval END
        complete --command={cmd_name} --no-files

        # subcommands {{ {{ {{1
        # `$ {cmd_name} SUBCMD1` {{ {{ {{2

        complete --command={cmd_name} \
            --condition='__fish_use_subcommand' \
            --arguments=SUBCMD1 \
            --description='SUBCMD1 description'

        # `$ {cmd_name} SUBCMD2` {{ {{ {{2

        #     ...
        # }} }} }}1
        # subcommands arguments {{ {{ {{1
        # `$ {cmd_name} SUBCMD1 {{arg1 | arg2}}` {{ {{ {{2

        complete --command={cmd_name} \
            --condition='__fish_seen_subcommand_from SUBCMD1' \
            --arguments='arg1 arg2' \
            --force-files
            # ----------^
            #  also suggests files

        # `$ {cmd_name} SUBCMD1 arg3` {{ {{ {{2

        #     ...

        # `$ {cmd_name} SUBCMD2 arg4` {{ {{ {{2

        #     ...
    END
    lines
        ->map((_, line: string) => line
            ->substitute('{\s*{\s*{', '{{' .. '{', '')
            ->substitute('}\s*}\s*}', '}}' .. '}', ''))
        ->setline(1)
enddef

export def RemoveUniversalVariables() #{{{1
    var file: string = $__fish_config_dir .. '/fish_variables'
    if file->filereadable()
        file->delete()
    endif
enddef

# Fish Alternative 1:{{{
#
#     # in $__fish_config_dir/config.fish
#     function _erase_universal_variables --on-event fish_exit
#         rm --force $__fish_config_dir/fish_variables
#     end
#}}}
# Fish Alternative 2:{{{
#
#     # in $__fish_config_dir/config.fish
#     for universal_var in (set --universal | string split --fields=1 ' ')
#         if test $universal_var = '__fish_initialized'
#             continue
#         end
#     end
#     set --erase $universal_var
#}}}
#   Why don't you use any of these?{{{
#
# It  seems  inefficient  to delete  the  same  file,  every  time we  start  an
# interactive shell.  The only time it might be necessary is after we've changed
# our config.
#
# Besides, if the file does not exist, fish has to re-create it, which increases
# startup by about 20/30 ms.
#}}}

# Note that you can't erase them any way you want.{{{
#
# If you  erase them  with `$  set --erase`, the  `fish_variables` file  will be
# updated; all runnning shells will be notified and read the file.
#
# But some variables need to be set in the universal scope.
# They don't give the expected effect otherwise.
# That's the case for example for:
#
#    - `fish_features`
#    - the `fish_color_*` variables (used in syntax highlighting)
#    - the `_fish_abbr_*` variables (implementing abbreviations)
#
# So, you  don't want  them to  be erased  while an  interactive shell  is still
# running, *unless* you set back the ones you need afterward.
# For example, you could erase them at the top of `config.fish`.
#}}}
#   In particular, do *not* erase `__fish_initialized` during startup.{{{
#
# It would cause errors during startup:
#
#     test: Missing argument at index 3
#     -lt 3000
#              ^
#     /usr/local/share/fish/functions/__fish_config_interactive.fish (line 7):
#         if test $__fish_initialized -lt 3000
#            ^
#}}}

export def UndoFtplugin() #{{{1
    set comments<
    set commentstring<
    set define<
    set equalprg<
    set errorformat<
    set foldexpr<
    set foldmethod<
    set foldtext<
    set formatoptions<
    set include<
    set iskeyword<
    set keywordprg<
    set makeprg<
    set omnifunc<
    set shiftwidth<
    set suffixesadd<

    nunmap <buffer> [m
    nunmap <buffer> ]m
    nunmap <buffer> [M
    nunmap <buffer> ]M

    unlet! b:match_ignorecase
    unlet! b:match_skip
    unlet! b:match_words
    unlet! b:mc_chain
enddef
