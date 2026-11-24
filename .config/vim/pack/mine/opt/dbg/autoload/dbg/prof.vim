vim9script

silent! import autoload 'fold/adhoc.vim' as fold

const DIR: string = $'{$TMPDIR}/vim'

const SUBCOMMANDS: list<string> = getcompletion('profile ', 'cmdline')
#                                                       ^
#                                                       necessary

export def Completion( #{{{1
    arglead: string,
    cmdline: string,
    pos: number
): list<string>

    var Filter: func = (l: list<string>): list<string> =>
        l->filter((_, v: string): bool => stridx(v, arglead) == 0)

    if cmdline =~ '^\CProf\s\+func\s\+'
    && cmdline !~ '^\CProf\s\+func\s\+\S\+\s\+'
        return getcompletion('profile func ', 'cmdline')
    endif

    if cmdline =~ '^\CProf\s\+\%(file\|start\)\s\+'
    && cmdline !~ '^\CProf\s\+\%(file\|start\)\s\+\S\+\s\+'
        if arglead =~ '$\h\w*$'
            return getcompletion(arglead[1 :], 'environment')
                ->map((_, v: string) => '$' .. v)
        endif
        return getcompletion(arglead, 'file')
    endif

    if cmdline =~ '^\CProf\s\+\%(' .. SUBCOMMANDS->join('\|') .. '\)'
        || count(cmdline, ' -') >= 2
        return []
    endif

    if cmdline !~ '-'
        return copy(SUBCOMMANDS)->Filter()
    endif

    # Warning: if you try to refactor this block, make some tests.{{{
    #
    # In particular, check how the function completes this:
    #
    #     :Prof -plu
    #     :Prof -plugin vim-
    #}}}
    var last_dash_to_cursor: string = cmdline->matchstr('.*\s\zs-.*\%' .. (pos + 1) .. 'c')
    if last_dash_to_cursor =~ '^-\%[plugin]$\|^-\%[read_last_profile]$'
        return Filter(['-plugin', '-read_last_profile'])
    endif

    if last_dash_to_cursor =~ '^-plugin\s\+\S*$'
        var plugin_names: list<string> = ['vendor/start', 'vendor/opt', 'mine/start', 'mine/opt']
            ->map((_, v: string) => $HOME .. '/.vim/pack/' .. v)
            ->filter((_, v: string): bool => isdirectory(v))
            ->map((_, v: string): list<string> => readdir(v))
            ->reduce((a: list<string>, v: list<string>): list<string> => a + v)
            + ['fzf']
        return Filter(plugin_names)
    endif
    return []
enddef

export def Wrapper(bang: string, args: string) #{{{1
    if ['', '-h', '--help']->index(args) >= 0
        var usage: list<string> =<< trim END
            usage:
                :Prof continue
                :Prof[!] file {pattern}
                :Prof func {pattern}
                :Prof pause
                :Prof start {fname}
                :Prof -plugin {plugin name} profile a plugin
                :Prof -read_last_profile    load last logged profile
        END
        echo usage->join("\n")
        return
    endif

    if args =~ '^\C\%(' .. SUBCOMMANDS->join('\|') .. '\)\s*$'
        .. '\|^\%(start\|file\|func\)\s\+\S\+\s*$'
        try
            execute printf('profile%s %s', bang, args)
        catch
            echohl ErrorMsg
            echomsg v:exception
            echohl NONE
        endtry
        return
    endif
    if args == '-read_last_profile'
        ReadLastProfile()
        return
    endif

    var plugin_name: string = args->substitute('-plugin\s\+', '', '')
    var cmdline: string = 'Prof -plugin '
    if Completion('', cmdline, strcharlen(cmdline))->index(plugin_name) == -1
        echo 'There''s no plugin named:  ' .. plugin_name
        return
    endif

    var start_cmd: string = 'profile start ' .. DIR .. '/profile.log'
    var plugin_files: list<string>
    var file_cmd: string
    if plugin_name == 'fzf'
        file_cmd = 'profile' .. bang .. ' file ' .. $HOME .. '/.fzf/**/*.vim'
        execute start_cmd | execute file_cmd
        plugin_files = glob($HOME .. '/.fzf/**/*.vim', true, true)
    else
        file_cmd = 'profile' .. bang .. ' file '
            .. $HOME .. '/.vim/pack/**/' .. plugin_name .. '/**/*.vim'
        execute start_cmd | execute file_cmd
        plugin_files = glob($HOME .. '/.vim/pack/**/' .. plugin_name .. '/**/*.vim', true, true)
    endif

    plugin_files
        ->filter((_, v: string): bool => v !~ '\c/t\%[est]/')
        ->map((_, v: string) => 'source ' .. v)
        ->writefile(DIR .. '/profile.log')
    execute 'silent! source ' .. DIR .. '/profile.log'

    echo printf("Executing:\n    %s\n    %s\n%s\n\n",
            start_cmd,
            file_cmd,
            plugin_files
                ->map((_, v: string) => '    ' .. v)
                ->join("\n"))

    # TODO: If one day, `:profile` supports  the `dump` subcommand, we would not
    # need to restart Vim.  We could see the log from the current session.
    # Why not with `:echo`?{{{
    #
    # Because we want it logged.
    #}}}
    # Why not everything (i.e. including the previous messages) with `:echomsg`?{{{
    #
    # Because `:echomsg` doesn't translate `\n` into a newline.
    # It prints a NUL `^@` instead.
    #}}}
    echomsg 'Recreate the issue, restart Vim, and execute:  :Prof -read_last_profile'
enddef

def ReadLastProfile() #{{{1
    var logfile: string = DIR .. '/profile.log'
    if !filereadable(logfile)
        echo 'There are no results to read'
        return
    endif
    execute 'split ' .. DIR .. '/profile.log'
    silent keepjumps keeppatterns :% substitute/\s*$//e

    silent! fold.Main()
    normal! 1G
    silent! FoldAutoOpen
    silent update
enddef
