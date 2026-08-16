vim9script

import 'lg.vim'

var source_tmp_file: string

# Interface {{{1
export def Op(verbosity = 0, type = ''): string #{{{2
    if type == ''
        &operatorfunc = function(lg.Opfunc, [{funcname: function(Op, [verbosity])}])
        return 'g@'
    endif

    # Warning: If you run `:update`, don't forget `:lockmarks`.
    # Otherwise, the change marks would be unexpectedly reset.

    var to_ignore: string = '˜$'
        .. '\|' .. '[⇔→]'
        .. '\|' .. '^\s*[│─└┘┌┐]'
        .. '\|' .. '^[↣↢]'
        .. '\|' .. '^\s*\%([-v]\+\|[-^]\+\)\s*$'
    var lines: list<string> = getreg('"')
        ->split('\n')
        ->filter((_, v: string): bool => v !~ to_ignore)

    if lines->empty()
        return ''
    endif

    if b:current_syntax == 'vim9'
      && lines
      ->copy()
      ->filter((_, v: string): bool => v != '')
      ->get(0, '') !~ '^\s*vim9\%[script]'
        lines = ['vim9script'] + lines
    endif

    if source_tmp_file == ''
        silent! delete(source_tmp_file)
        source_tmp_file = ''
    endif
    source_tmp_file = tempname()

    var initial_indent: number = lines[0]
        ->matchstr('^\s*')
        ->strcharlen()
    lines
        ->map((_, v: string) =>
            v->substitute('[✘✔┊].*', '', '')
             ->substitute('^\C\s*\%(fu\%[nction]\|com\%[mand]\)\zs\ze\s', '!', '')
             # Why?{{{
             #
             # Here is the output of a `sed(1)` command in the shell:
             #
             #     $ sed 's/\t/\
             #     /2' <<<'Column1	Column2	Column3	Column4'
             #     Column1	Column2˜
             #     Column3	Column4˜
             #
             # Here is the output of the same command when sourced with our plugin:
             #
             #     $ sed 's/\t/\
             #     /2' <<<'Column1	Column2	Column3	Column4'
             #     Column1 Column2˜
             #         Column3     Column4˜
             #
             # The indentation of the second line alters the output.
             # We must remove it to get the same result as in the shell.
             #}}}
             # Warning:{{{
             #
             # This can alter the result of a heredoc assignment.
             #
             # MRE:
             #
             #         let a =<< END
             #         xx
             #     END
             #     echo a
             #
             # If you run `:source %`, the output will be:
             #
             #     ['    xx']
             #       ^--^
             #
             # If you press `+sip`, the output will be:
             #
             #     ['xx']
             #
             # In practice,  I doubt it will  be an issue because  I think we'll
             # always use `trim`:
             #
             #                   v--v
             #         let a =<< trim END
             #         xx
             #     END
             #     echo a
             #}}}
             ->substitute('^\s\{' .. initial_indent .. '}', '', ''))

    writefile([''] + lines, source_tmp_file, 'b')

    # we're sourcing a shell command
    var prompt: string = lines[0]->matchstr('^\s*\zs[$%]\ze\s')
    if prompt != '' || IsInEmbeddedShellCodeBlock()
        execute 'split ' .. source_tmp_file
        FixShellCmd()
        quit
        var interpreter: string = 'bash'
        if prompt != ''
            interpreter = {
                '$': 'bash',
                '%': 'fish'
            }[prompt]
        endif
        silent systemlist(interpreter .. ' ' .. source_tmp_file)
            ->setreg('o', 'c')
        echo @o
        return ''
    endif

    # we're sourcing a vimscript command
    try
        var cmd: string
        # the function was invoked via the Ex command
        if verbosity != 0
            cmd = verbosity .. 'verbose source ' .. source_tmp_file

        # the function was invoked via the mapping
        else
            cmd = 'source ' .. source_tmp_file
        endif

        # Flush any delayed screen updates before running `cmd`.
        # See `:help :echo-redraw`.
        redraw
        # save the output  in register `o` so we can  directly paste it wherever
        # we want; but remove the first newline before
        setreg('o', [execute(cmd, '')[1 :]], 'c')
        # Don't run `:execute cmd`!{{{
        #
        # If you do, the code will be run twice (because you've just run `execute()`).
        # But if the code is not idempotent, the printed result may seem unexpected.
        # MRE:
        #
        #     var list: list<number> = range(1, 4)
        #     list->add(list->remove(0))
        #     echo list
        #     [3, 4, 1, 2]˜
        #
        # Here, the output should be:
        #
        #     [4, 1, 2, 3]˜
        #}}}

        # Add the current  line to the history  to be able to  insert its output
        # into the buffer with `C-r X`.
        if type == 'line' && line("'[") == line("']")
            getline('.')->histadd(':')
        endif
    catch
        setreg('o', [v:exception->substitute('^Vim(.\{-}):', '', '')], 'c')
        lg.Catch()
    endtry
    return ''
enddef

export def FixSelection() #{{{2
    var tmp_file: string = tempname()
    getreg('*', true, true)
        ->map((_, v: string) =>
                v->substitute('^\C\s*com\%[mand]\s', 'command! ', '')
                 ->substitute('^\C\s*fu\%[nction]\s', 'function! ', ''))
        ->writefile(tmp_file)

    var star_save: dict<any> = getreginfo('*')
    # TODO: We should clear the star register. {{{
    #
    #     setreg('*', {})
    #
    # Rationale: We'll run the fixed code later with a timer.
    # We don't need/want the original code to be run.
    #
    # But we don't clear it atm.
    # Because it would cause an Ex command's output to be automatically cleared:
    #
    #     autocmd CmdlineLeave : setreg('*', {})
    #     'ls'->setline(1)
    #     # press:  V : C-U @ * Enter
    #     # expected:  :ls output is printed
    #     # actual:  no output
    #
    # Note: the issue is limited to short outputs.
    # No issue if the output is long enough to make Vim print it via the pager.
    #}}}
    timer_start(0, function(Sourcethis, [tmp_file, star_save]))
enddef

def Sourcethis(
    tmp_file: string,
    star_save: dict<any>,
    _
)
    try
        execute 'source ' .. tmp_file
    catch
        echohl ErrorMsg
        echomsg v:exception
        echohl NONE
    finally
        setreg('*', star_save)
    endtry
enddef
#}}}1
# Core {{{1
def IsInEmbeddedShellCodeBlock(): bool #{{{2
    return synstack('.', col('.'))
        ->get(0, 0)
        ->synIDattr('name') =~ '^markdownHighlight_bash$'
enddef

export def FixShellCmd() #{{{2
    var pos: list<number> = getcurpos()

    # remove a possible dollar/percent sign in front of the command
    var pat: string = '^\%(\s*\n\)*\s*\zs[$%]\s\+'
    var lnum: number = search(pat)
    if lnum > 0
        getline(lnum)
            ->substitute('^\s*\zs[$%]\s\+', '', '')
            ->setline(lnum)
    endif

    # remove possible indentation in front of `EOF`
    pat = '\C^\%(\s*EOF\)\n\='
    lnum = search(pat)
    var line: string = getline(lnum)
    var indent: string = line->matchstr('^\s*')
    var range: string = ':1/<<.*EOF/;/^\s*EOF/'
    var mods: string = 'silent keepjumps keeppatterns '
    if !empty(indent)
        execute mods .. range .. 'substitute/^' .. indent .. '//e'
        execute mods .. ':'']+1 substitute/^' .. indent .. ')/)/e'
    endif

    # Remove empty lines at the top of the buffer.{{{
    #
    #     $ C-x C-e
    #     # press `o` to open a new line
    #     # insert `ls`
    #     # press `Esc` and `ZZ`
    #     # press Enter to run the command
    #     # press `M-c` to capture the pane contents via the capture-pane command from tmux
    #     # notice how `ls(1)` is not visible in the quickfix window
    #}}}
    # Why the autocmd?{{{
    #
    # To avoid some weird issue when starting Vim via `C-x C-e`.
    #
    #     :let @+ = "\n\x1b[201~\\n\n"
    #     # start a terminal other than xterm
    #     # press C-x C-e
    #     # enter insert mode and press C-S-v
    #     # keep pressing undo
    #
    # Vim keeps undoing new changes indefinitely.
    #
    #     :echo undotree()
    #     E724: variable nested too deep for displaying˜
    #
    # MRE:
    #
    #       inoremap <C-M> <C-G>u<CR>
    #       let &t_PE = "\<Esc>[201~"
    #       autocmd TextChanged * 1;/\S/-d
    #       let @+ = "\n\x1b[201~\\n\n"
    #       startinsert
    #
    #       # press:  C-S-v Esc u u u ...
    #
    # To  avoid  this,   we  delay  the  deletion  until  we   leave  Vim  (yes,
    # `BufWinLeave` is fired when we leave Vim; but not `WinLeave`).
    #}}}
    if !exists('#FixShellcmd') # no need to re-install the autocmd on every `TextChanged` or `InsertLeave`
        augroup FixShellcmd
            autocmd!
            autocmd BufWinLeave <buffer> ++once FixShellcmd()
        augroup END
    endif

    setpos('.', pos)
enddef

def FixShellcmd()
    abuf = expand('<abuf>')->str2nr()
    # find where the buffer is now
    winids = win_findbuf(abuf)
    # make sure we're in its window
    if empty(winids)
        execute 'buffer ' .. abuf
    else
        win_gotoid(winids[0])
    endif
    # remove empty lines at the top
    if getline(1) !~ '\S'
        silent! keepjumps keeppatterns :1;/\S/-1 delete _
        update
    endif
enddef

var abuf: number
var winids: list<number>
