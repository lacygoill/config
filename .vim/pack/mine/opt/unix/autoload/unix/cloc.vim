vim9script

# TODO: Make the code async (so that it doesn't block when we use `:Cloc` on a
# big directory).

export def Main( #{{{1
        lnum1: number,
        lnum2: number,
        path: string
        )
    if !executable('cloc')
        echomsg 'missing dependency: cloc(1)'
        return
    endif

    var exclude_opts: string = '--exclude-lang=Markdown --exclude-dir=.cache,t,test'

    var our_code: string
    if !empty(path)
        if path =~ '^http'
            var tmp_dir: string = tempname()
            var cmd: string = path =~ 'bitbucket' ? 'hg' : 'git'
            silent var git_output: string = system($'{cmd} clone {path} {tmp_dir}')
            our_code = tmp_dir
        else
            our_code = path
        endif
        var cmd: string = $'cloc {exclude_opts} --quiet {our_code}'
        echo systemlist(cmd)[3 : -2]->join("\n")
        return
    endif

    var file: string = tempname()
    our_code = file .. '.' .. (expand('%:e')->empty() ? &filetype : expand('%:e'))
    # TODO: Currently, `cloc(1)` does not recognize the new Vim9 comment leader (`#`).{{{
    #
    # As a result, it parses any Vim9 commented line as a line of code.
    # This makes the results wrong.
    #
    # We temporarily fix that by replacing `#` with `"`.
    #
    # In the future, consider opening an issue here:
    # https://github.com/AlDanial/cloc/issues
    #}}}
    if get(b:, 'current_syntax', '') == 'vim9'
        getline(lnum1, lnum2)
            ->map((_, line: string) => line->substitute('^\s*\zs#', '"', ''))
            ->writefile(our_code)
    else
        getline(lnum1, lnum2)->writefile(our_code)
    endif
    # Warning: there seems to be a limit on the size of the shell's standard input.{{{
    #
    # We could use this code instead:
    #
    #     var lines: string = getline(lnum1, lnum2)->join("\n")->shellescape()
    #     silent var out: string = system('echo ' .. lines .. ' | cloc --stdin-name=foo.' .. &filetype .. ' -')
    #     echo out
    #
    # But because of the previous limit:
    # http://stackoverflow.com/a/19355351
    #
    # ... the command would error out when send too much text.
    # The error would like like this:
    #
    #     E484: Can't open file /tmp/user/1000/vsgRgDU/97˜
    #
    # Currently, on my system, it seems to error out somewhere above 120KB.
    # In a file, to  go the 120 000th byte, use the  normal `go` command and
    # hit `120000go`.  Or the Ex version:
    #
    #     :120000 go
    #}}}

    silent var cmd_output: string = $'cloc {exclude_opts} --json {our_code}'
        ->system()
    if cmd_output == ''
        return
    endif
    var stats_json: dict<dict<any>> = cmd_output
        ->json_decode()
    if stats_json->has_key('SUM')
        stats_json->remove('SUM')
    endif
    if stats_json->has_key('header')
        stats_json->remove('header')
    endif
    var stats: dict<number> = stats_json
        ->values()
        ->get(0, {})

    if empty(stats)
        return
    endif

    echo printf('code: %s, comment: %s, blank: %s',
        stats.code, stats.comment, stats.blank)
enddef

export def CountLinesInFunc() #{{{1
    if ['awk', 'c', 'bash', 'fish', 'python', 'vim']->index(&filetype) == -1
        return
    endif

    var view: dict<number> = winsaveview()

    var marks_save: list<list<number>> = [getpos("'<"), getpos("'>")]
    # NOTE: this  relies on a  custom text-object  (`if`) which should  let us
    # operate on the body of the current function.
    execute "silent normal vif\<Esc>"
    Main(line("'<"), line("'>"), '')
    setpos("'<", marks_save[0])
    setpos("'>", marks_save[1])

    winrestview(view)
enddef
