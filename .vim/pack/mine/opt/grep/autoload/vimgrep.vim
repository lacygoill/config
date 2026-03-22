vim9script

import autoload './mangrep.vim'

# Interface {{{1
export def Main(args: string, title = '') #{{{2
    var vimrc: string = tempname()
    var qfl_file: string = tempname()

    var guard: list<string> =<< trim END
        var qfl_file: string = expand('%:p')
        if qfl_file !~ '^' .. ($TMPDIR ?? '/tmp') .. '/'
            finish
        endif
    END

    var ManGrep: bool = title =~ '^:ManGrep'

    var events_to_ignore: any
    # for `:ManGrep`, we need to allow autocmds listening to `BufReadCmd`
    if ManGrep
        events_to_ignore = getcompletion('', 'event')
        events_to_ignore->remove(events_to_ignore->index('BufReadCmd'))
        events_to_ignore = events_to_ignore->join(',')
    else
        events_to_ignore = 'all'
    endif

    # Why do you write the arguments in a file?  Why not passing them as arguments to `vim(1)`?{{{
    #
    # They could contain some quotes.
    # When that happens, I have no idea how to protect them.
    #}}}
    var cdcmd: string = 'cd ' .. getcwd()->fnameescape()
    # Don't we need to also pass `$MYVIMRC`?{{{
    #
    # No.  Apparently, a Vim job inherits the environment of the current Vim instance.
    #
    #     :call delete('/tmp/file')
    #     :let $ENVVAR = 'some environment variable'
    #     :call job_start('vim -es -Nu NONE +"call writefile([$ENVVAR], ''/tmp/file'') | quitall!"')
    #     :echo readfile('/tmp/file')
    #     ['some environment variable']
    #}}}
    # `key=xxx`: handle case where we accidentally grep an encrypted file.{{{
    #
    # Because in that case, the Vim job will be stuck asking us for the key.
    # To make sure Vim can quit (after grep'ing all the other regular files), we
    # need to give it a key now, even if its value is wrong (here we use `xxx`).
    #}}}
    # `nomodified`: reset `'modified'` option set by `key=xxx`.{{{
    #
    # If the current buffer is modified,  it will break `:VimGrep` (because of
    # `E37`), unless we give it the `j` flag.
    #}}}
    var setcmd: string = printf('set wildignore=%s suffixes=%s %signorecase %ssmartcase key=xxx nomodified eventignore=%s',
        &wildignore,
        &suffixes,
        &ignorecase ? '' : 'no',
        &smartcase ? '' : 'no',
        events_to_ignore
    )
    # Why do you expand the arguments?{{{
    #
    # If  we  didn't provide  a  pattern  (`:VimGrep // files`), the  new  Vim
    # process will replace  it with the contents of its  search register.  But
    # there's no  guarantee that the  search register  of this Vim  process is
    # identical to the one of our current Vim process.
    #
    # Same thing for `%` and `##`.
    #}}}
    var expanded_args: string = ExpandArgs(args)
    var vimgrepcmd: string = 'vimgrep ' .. expanded_args
    # Why `strtrans()`?{{{
    #
    # If the text contains NULs, it could mess up the parsing of `:cgetfile`.
    # Maybe other control characters could cause similar issues.
    #
    # Let's play it  safe; we don't need special characters  to be preserved; we
    # just need to be able to read  them; anything which is not printable should
    # be made printable.
    #}}}
    var write_qfl: list<string> =<< trim END
        getqflist()
           ->map((_, v: dict<any>): string => printf('%s:%d:%d:%s',
               bufname(v.bufnr)->fnamemodify(':p'),
               v.lnum,
               v.col,
               v.text->substitute('[^[:print:]]', (m: list<string>): string => strtrans(m[0]), 'g')))
           ->writefile(qfl_file, 's')
    END
    # Make sure that the code contained in `guard` is run before `vimgrepcmd`.{{{
    #
    # `:vimgrep` could  change the current file;  you could also try  to use the
    # `j` flag  unconditionally in the  second Vim instance where  `:vimgrep` is
    # run, but better be safe.
    #}}}
    var lines: list<string> = ['vim9script noclear']
        + guard
        + ['try']
        + (ManGrep ? ['packadd man'] : [])
        + [cdcmd, setcmd, vimgrepcmd]
        + write_qfl
        + ['catch']
        + ['set key=']
        + ['v:exception->setline(1)']
        + ['update']
        + ['cquit!']
        + ['finally']
        + ['quitall!']
        + ['endtry']
    lines->writefile(vimrc, 's')

    var vimcmd: string = printf('vim -es -Nu NONE -U NONE -i NONE -S %s %s', vimrc, qfl_file)
    var arglist: list<any> = [qfl_file, title ?? $':VimGrep {expanded_args}', ManGrep]
    var opts: dict<any> = {
        exit_cb: function(Callback, arglist),
        in_io: 'null',
        out_io: 'null',
        err_io: 'null',
    }
    job_start(vimcmd, opts)
enddef
# }}}1
# Core {{{1
def Callback( #{{{2
        tempqfl: string,
        title: string,
        ManGrep: bool,
        _: job,
        exit: number
        )

    # Vim(vimgrep):E53: Unmatched ...
    # Vim(vimgrep):E480: No match: ...
    if exit != 0
        echohl ErrorMsg
        echomsg readfile(tempqfl)->get(0, '')
        echohl NONE
        return
    endif

    var errorformat_save: string = &l:errorformat
    var bufnr: number = bufnr('%')
    try
        # `%f:%l:%c:` is needed to support the case where there is no text.{{{
        #
        # That can happen, for example, if you look for empty lines.
        #
        #     :VimGrep /^$/gj $MYVIMRC
        #}}}
        &l:errorformat = '%f:%l:%c:%m,%f:%l:%c:'
        execute 'cgetfile ' .. tempqfl
        cwindow
        setqflist([], 'a', {title: title})
        if ManGrep
            mangrep.LoadQuickFixListBuffers()
        endif
    finally
        setbufvar(bufnr, '&errorformat', errorformat_save)
    endtry
    # If you were moving in a buffer  while the callback is invoked and open the
    # qf window, some stray characters might be printed in the status line.
    redraw!
enddef
# }}}1
# Utilities {{{1
def ExpandArgs(args: string): string #{{{2
    var pat: string = '^\([^[:ident:][:blank:]]\)\1\ze[gj]\{,2}\s\+'
    #                   ^-------------------------^
    #                   2 consecutive and identical non-identifier characters
    var rep: string = '/' .. escape(@/, '\/') .. '/'
    #                                    ^
    # `substitute()`  will remove  any backslash,  because some  sequences are
    # special (like `\1` or  `\u`).  See: `:help sub-replace-special`.  If our
    # pattern contains a backslash (like in `\s`), we need it to be preserved.

    # expand `//` into `/last search/`
    return args
        ->substitute(pat, rep, '')
        # expand `%` into the path to the current file
        ->substitute('\s\+\zs%\s*$', expand('%:p')->fnameescape(), '')
        # expand `##` into the paths from the arglist
        ->substitute(
            '\s\+\zs##\s*$',
            argv()
            ->map((_, v: string) => v->fnamemodify(':p')->fnameescape())
            ->join(),
            '')
enddef
