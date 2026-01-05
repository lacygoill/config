vim9script

# Init {{{1

const PROMPT: string = '[$%]\s'

var cml: string
var cbi: string

# Interface {{{1
export def Command(arg_cmd = '') #{{{2
    if !exists('$TMUX')
        echo 'requires tmux'
        return
    endif

    var cmd: string
    if arg_cmd == ''
        cmd = GetCmd()
    else
        cmd = arg_cmd
    endif
    if cmd == ''
        echo 'no command to run on this line'
        return
    endif

    ClearStalePaneId()
    # TODO: What if we have run a shell command which has started Vim in the other pane.{{{
    #
    # In that case, `pane_id` will exist and our next command will be sent there.
    # But we don't want that.
    #
    # What should we do?
    # Make Vim quit? But then, what about other fullscreen programs, like cmus, weechat, newsboat...
    # Open another tmux pane? Maybe...
    # Then we need to handle another case:
    #
    #     if pane_id != '' && !PreviousPaneRunsShell()
    #         OpenPaneAndSaveId()
    #     endif
    #
    # It seems like a corner case; is it worth the trouble?
    #}}}
    if pane_id == ''
        # if the previous pane runs a shell, let's use it
        if PreviousPaneRunsShell()
            pane_id = GetPreviousPaneId()
        else
            OpenPaneAndSaveId(arg_cmd)
            PostPaneOpened()
        endif
    endif
    ClosePane('later')
    if IsZoomedWindow()
        UnzoomWindow()
    endif

    RunShellCmd(cmd)
enddef
var pane_id: string
#}}}1
# Core {{{1
def GetCmd(): string #{{{2
    if mode() =~ "^[vV\<C-V>]$"
        execute "normal! \<Esc>"
        if &filetype !~ 'python'
            # TODO: support C file too
            echo 'only work in python file at the moment'
            return ''
        endif
        WritePythonCode()
        return $'{GetPythonInterpreter()} {$TMPDIR}/tmux/run.py'
    endif

    var cmd: string

    cml = GetCml()
    cbi = GetCodeblockIndent()

    var filetype: string
    # Case1: fenced code block in markdown
    if &filetype == 'markdown'
        filetype = FiletypeInFencedCodeblock()
        if filetype != ''
            cmd = GetFencedCodeblock(filetype)
        endif
        if cmd != ''
            return cmd
        endif
    endif

    # Case2: fish command in `~/.config/fish/README`
    if filetype == ''
            && expand('%:p') =~ $'^{$__fish_config_dir}/README/'
        return getline('.')
    endif

    # Case3: a codespan in a comment starting with a title.{{{
    #
    # Example (in a C file):
    #
    #     // Test: `$ gcc matrix.c -o build/matrix $GCC_OPTS && ./build/matrix NAME`
    #}}}
    var line: string = getline('.')
    var pat: string = '^\s*' .. cml .. '\s\+'
        # `Some Comment Title:`
        .. '\%(\u\w\+\s*\)\+:\s\+'
        .. '`' .. PROMPT .. '\zs.*\ze`$'
    if line =~ pat
        if &filetype == 'c' || &filetype == 'rust'
            MakeSureBuildDirExists()
        endif
        return printf('cd %s && %s', expand('%:p:h:S'), line->matchstr(pat))
    endif

    # Case4: A multiline shell command.
    cmd = GetMultilineShellCmd()

    # Case5: some code
    if cmd == ''
        if (&filetype == 'vim'
                || getcwd() == $HOME .. '/Wiki/vim'
                # for `~/Wiki/bug/vim.md`
                || expand('%:p:t') == 'vim.md'
        ) && getline('.') =~ '^\s*' .. cml .. cbi
            cmd = GetVimCmd()
        elseif &filetype == 'bash'
            cmd = expand('%:p')
        elseif &filetype == 'c'
            cmd = GetGccCmd()
        elseif &filetype == 'lua'
            cmd = GetLuaCmd()
        elseif &filetype == 'python'
            cmd = GetPythonCmd()
        elseif &filetype == 'rust'
            cmd = GetRustCmd()
        endif
    endif

    return cmd
enddef

def WritePythonCode() #{{{2
# We need  to write a temporary  standalone script, based on  the current visual
# selection.  The latter might not be  complete.  For example, it might refer to
# a variable which was assigned before.
    var lnum1: number = [line("'<"), line("'>")]->min()
    var lnum2: number = [line("'<"), line("'>")]->max()

    # to be  sure our  visually selected  code will work,  first grab  all prior
    # assignments
    var before_first_fold: list<string>
    var found_a_fold: bool
    for line: string in getline(1, lnum1 - 1)
        if line =~ '{{' .. '{\%(\d\)\=$'
            found_a_fold = true
            break
        endif
        if line !~ '^\s*#'
            before_first_fold->add(line)
        endif
    endfor
    if getline(lnum1) =~ '{{' .. '{\%(\d\)\=$'
        found_a_fold = true
    endif

    var script: list<string> = (found_a_fold ? before_first_fold : [])
        + getline(lnum1, lnum2)
    # now, we can append the visual selection
    script->writefile($'{$TMPDIR}/tmux/run.py')
enddef

def ClearStalePaneId() #{{{2
# remove `pane_id` if we manually closed the pane associated to it,
# otherwise the function will think there's no need to create a pane
    if pane_id == ''
        return
    endif
    silent var open_panes: list<string> = systemlist("tmux list-panes -F '#D'")
    var is_pane_still_open: bool = open_panes->index(pane_id) >= 0
    if !is_pane_still_open
        # the pane should be closed, but better be safe
        silent system('tmux kill-pane -t ' .. pane_id)
        pane_id = ''
    endif
enddef

def OpenPaneAndSaveId(arg_cmd: string) #{{{2
    var cmd: string = 'tmux split-window '
    if arg_cmd =~ 'debug#LastPressedKeys'
        cmd ..= '-PF "#D" -l 15% -h'
    else
        # use a vertical split if the terminal window is too small
        if &lines < 24
            # Do *not* pass the `-d` flag to `split-window`.{{{
            #
            # It would prevent many tmux variables from being set correctly.
            # Including `#{pane_current_command}`.
            # Because of  that, we  wouldn't be  able to scroll  in the  pane by
            # pressing `M-[jk]` from Vim, until we focus the pane manually.
            #}}}
            cmd ..= '-PF "#D" -l 33% -h \; last-pane'
        else
            cmd ..= '-PF "#D" -l 33% \; last-pane'
        endif
    endif
    silent pane_id = system(cmd)->trim("\n", 2)
    # Necessary to make sure tmux pastes the code, instead of typing it.{{{
    #
    # If tmux types the code:
    #
    #    - our interactive zsh abbreviations might be unexpectedly expanded,
    #      causing the wrong code to be executed
    #
    #    - we might see these kind distracting prompts:
    #
    #         heredoc>
    #         cmdsubst>
    #         cmdsubst heredoc>
    #
    #    - we might need to wait longer than necessary
    #      (especially noticeable for a large amount of code)
    #
    # ---
    #
    # I  guess that  in  a new  terminal,  zsh  needs some  time  to enable  the
    # bracketed  paste  mode (which  we  ask  tmux to  use  by  passing `-p`  to
    # `paste-buffer`).
    #}}}
    # Do not reduce the duration.{{{
    #
    # For example, 100ms seems to work fine most of the time, but not always.
    # To test, press `||` on a long codeblock in a markdown file.
    # Look for these prompts:
    #
    #     heredoc>
    #     cmdsubst>
    #     cmdsubst heredoc>
    #
    # If you can read one of them, the duration is not long enough.
    # Don't stop after one test; you need several to be sure.
    # After each test, close the newly opened tmux pane.
    #}}}
    sleep 200m
enddef

def PostPaneOpened() #{{{2
    # activate Python virtual environment if one is available
    var activation: string = $'{expand('%:p:h')}/.venv/bin/activate.fish'
    if &filetype == 'python' && activation->filereadable()
        RunShellCmd($'source {activation}')
    endif
enddef

def ClosePane(when: string) #{{{2
    if when == 'later'
        augroup TmuxRunCmdClosePane
            autocmd!
            # Is it ok to remove *all* autocmds?{{{
            #
            # For the moment, yes.
            # I don't intend to have more than one pane open at a time.
            #
            # If you want more granularity, you could remove `autocmd!`, and add
            # a bang after all the next `:autocmd` commands (`autocmd` → `autocmd!`).
            #
            # If you  want to check whether  the autocmds are duplicated,  run a
            # command, close its pane, then re-run the command.
            #}}}
            autocmd VimLeave * ClosePane('now')
            autocmd BufWinLeave <buffer> ClosePane('now')
        augroup END
    else
        silent system('tmux kill-pane -t ' .. pane_id)
        pane_id = ''
        if exists('#TmuxRunCmdClosePane')
            autocmd! TmuxRunCmdClosePane
        endif
    endif
enddef

def RunShellCmd(arg_cmd: string) #{{{2
    # make sure we're not in copy-mode, before trying to run any shell command
    silent system('tmux send-keys -X -t ' .. pane_id .. ' cancel')

    # We might have to quit `less` *and* Vim later.{{{
    #
    # That can happen when we execute  a Vim command containing a heredoc.  In
    # that case, one of our custom fish functions runs something like:
    #
    #     sed "1d" $TMPDIR/fish/bash | bat --language=bash --style=plain
    #     vim -Nu NONE -S <(tee <<'EOF'
    #     ...
    #     EOF
    #     )
    #
    # If  the command  is too  long  to fit  on the  screen, `bat(1)`  invokes
    # `less(1)` on the  1st line.  Here, we  have to quit it  by pressing `q`.
    # Then, we'll have to quit the Vim command on the 2nd line.
    #}}}
    if PaneIsRunning('less')
        silent system('tmux send-keys -t ' .. pane_id .. ' q')
    endif

    var clear: string
    if PaneIsRunning('vim')
        # `C-\ C-n` doesn't work at the more prompt, nor in a confirmation prompt (e.g. `:substitute/pat/rep/c`).{{{
        #
        # Don't try to include the key with the other ones and use a single `$ tmux send-keys ...`.
        # For some reason, it doesn't (always?) work.
        #}}}
        silent system('tmux send-keys -t ' .. pane_id .. ' C-c')
        clear = 'tmux send-keys -t ' .. pane_id .. ' C-\\ C-n :quitall! Enter'
    else
        # Why `ZQ`?{{{
        #
        # In case `PaneIsRunning('vim')` failed to detect that Vim was running
        # in the pane.  That can happen, for example, if we've run:
        #
        #     $ git diff | vipe
        #
        # Obviously, `ZQ`  is not perfect;  there could  be more than  1 window.
        # But we can't press `:quitall! Enter`; if  Vim is really not running in
        # the  pane, that  would cause  `quitall!` to  be run  which could  have
        # unexpected side-effects.
        #}}}
        # Why not `C-e C-u`?{{{
        #
        # The command-line could contain several lines of code (e.g. heredoc).
        # In that case, `C-e C-u` would only clear the current line, not the other ones.
        #}}}
        #   OK, and what does `C-x C-k` do?{{{
        #
        # It clears the whole command-line, no  matter how many lines of code it
        # contains, or where the cursor is.
        #
        # It works  only in fish where  we bind `C-x  C-k` to  a custom function
        # (`kill-buffer`).   In bash,  we fall  back on  `C-u  C-k`, which  only
        # clears  the current  line (unfortunately,  that might  not be  enough,
        # because the buffer could contain more than 1 line).
        #}}}
        var kill_keys: string = $INTERACTIVE_SHELL != '' ? 'C-u C-k' : 'C-x C-k'
        clear = 'tmux send-keys -t ' .. pane_id .. ' ' .. kill_keys
    endif
    silent system(clear)

    var cmd: string = arg_cmd
        ->substitute('\\\s\+$', '\', '')
        # https://github.com/jebaum/vim-tmuxify/issues/16
        ->tr("\t", ' ')
    # Make sure a trailing semicolon is correctly sent.{{{
    #
    # ... and not parsed as a command termination.
    #
    # https://github.com/tmux/tmux/issues/1849
    # https://github.com/jebaum/vim-tmuxify/issues/11
    #}}}
    if cmd[-1] == ';'
        cmd = cmd[: -2] .. '\;'
    endif
    var tmp_file: string = tempname()
    split(cmd, '\n')->writefile(tmp_file, 'b')

    var tmux_cmd: string = 'tmux load-buffer -b barbar ' .. tmp_file
        .. ' \; paste-buffer -d -p -b barbar -t ' .. pane_id
        .. ' \; send -t ' .. pane_id .. ' C-m'

    # `C-c` is not always instantaneous.
    # Sometimes, Vim needs one second or two; that can happen when some errors are given.
    if PaneIsRunning('vim')
        timer_start(2'000, (_) => system(tmux_cmd))
    else
        silent system(tmux_cmd)
    endif
enddef

def HighlightCode(cmd: list<string>, filetype: string): string #{{{2
    var script: string = $'{$TMPDIR}/tmux/run.' .. filetype
    var highlight: string = printf(
        'sed "1d" %s | bat --language=%s --style=plain',
        script, filetype)
    var code: list<string> = [highlight] + cmd
    writefile(code, script)
    return filetype .. ' ' .. script
enddef

def MakeSureBuildDirExists() #{{{2
    var build_dir: string = expand('%:p:h') .. '/build/'
    if !isdirectory(build_dir)
        mkdir(build_dir, 'p')
    endif
enddef

def UnzoomWindow() #{{{2
    silent system('tmux resize-pane -Z')
enddef
#}}}1
# Utilities {{{1
def GetCml(): string #{{{2
    var s: string
    if &filetype == 'markdown' || &commentstring == ''
        s = ''
    else
        s = &commentstring->matchstr('\S*\ze\s*%s')
        s = '\V' .. s->escape('\') .. '\m'
    endif
    return s
enddef

def GetCodeblockIndent(): string #{{{2
    return '\s\{' .. (&filetype == 'markdown' || cml == '' ? 4 : 5) .. '}'
enddef

def GetMultilineShellCmd(): string #{{{2
    var curpos: list<number> = getcurpos()

    if search('^\s*' .. cml .. cbi .. PROMPT, 'bcW') == 0
        setpos('.', curpos)
        return ''
    endif

    var cmd: list<string> = [GetMultilineShellCmdStart()]
    # sanity check
    if cmd == []
        setpos('.', curpos)
        return ''
    endif
    var end: number = cmd[0]->GetMultilineShellCmdEndLnum()

    var curlnum: number = curpos[1]
    # make sure  the code block  which is found  is relevant (i.e.  the original
    # cursor position should be between the start and end of the block)
    if !(curlnum >= line('.') && curlnum <= end)
        setpos('.', curpos)
        return ''
    endif
    var lines: list<string> = cmd + getline(line('.') + 1, end)
    var indent: string = getline('.')
        ->matchstr('^\s*' .. cml .. '\s*')
    cmd = lines
        ->map((_, v: string) => v
                ->substitute(indent, '', '')
                # Remove comment leader on empty lines.{{{
                #
                # Otherwise, if you execute this command:
                #
                #     $ vim -S <(tee <<'EOF'
                #         vim9script
                #
                #         var lines =<< trim END
                #             aaa
                #
                #         END
                #         lines->setline(1)
                #     EOF
                #     )
                #
                # You'll end up with this buffer:
                #
                #     aaa
                #     #
                #
                # Which is not what you want; you only want this:
                #
                #     aaa
                #}}}
                ->substitute('^\s*' .. cml .. '\s*$', '', '')
        )

    setpos('.', curpos)

    # A complex shell command should be written in a temporary bash script and
    # run  by  bash  (it  might  contain  a  bash-specific  syntax  which  our
    # interactive shell doesn't understand).
    #
    # But  a  `cd`  command is  not  complex,  and  needs  to be  run  by  our
    # interactive  shell directly.   Otherwise, its  effect would  not persist
    # after the bash interpreter has run the script and exit.
    if cmd->len() == 1 && cmd[0] =~ '^cd\s'
        return cmd[0]
    endif
    return HighlightCode(cmd, 'bash')
enddef

def GetMultilineShellCmdStart(): string #{{{2
    # Note that we don't exclude the whitespace which follows the `$` or `%` prompt.
    # This will make sure that when the command is run, zsh doesn't log it in its history.
    return getline('.')
        ->matchstr('^\s*' .. cml .. cbi .. '\s*' .. PROMPT .. '\zs.*')
        #                                  ^---^
        # The indentation could be longer than expected.
        # That happens for example in a code block nested inside a list item.
enddef

def GetMultilineShellCmdEndLnum(cmd: string): number #{{{2
    var end: number = line('.')

    # support continuation lines
    if cmd =~ '\\\s*$'
        end = search('\%(\\\s*\)\@<!$\|\%$', 'nW')

    # support heredoc
    elseif cmd =~ '<<-\=\([''"]\=\)EOF\1'
        end = search('^\s*' .. cml .. '\s*EOF$', 'nW')
        if end == 0
            return 0
        endif
        # support process substitution containing a heredoc
        if getline(end + 1) =~ '^\s*' .. cml .. '\s*)'
            ++end
        endif

    # support fish block (`man begin(1)`)
    elseif cmd == 'begin'
        end = search('^\s*' .. cml .. '\s*end$', 'nW')
    endif

    return end
enddef

def GetPythonInterpreter(): string #{{{2
    var firstline: string = getline(1)
    var interpreter: string
    if firstline =~ '^#!'
        return firstline->matchstr('#!\zs.*')
    endif
    return 'python3'
enddef

def GetVimCmd(): string #{{{2
    # We should be able to run some Vim code without writing an explicit heredoc all the time.{{{
    #
    #     # too verbose
    #     ✘
    #     $ vim -Nu NONE -S <(tee <<'EOF'
    #         vim9script
    #         def g:Func()
    #             echo 'before error'
    #             invalid
    #             echo 'after error'
    #         enddef
    #     EOF
    #     )
    #
    #     ✔
    #     def g:Func()
    #         echo 'before error'
    #         invalid
    #         echo 'after error'
    #     enddef
    #}}}

    var curpos: list<number> = getcurpos()
    # To find the starting line of the block, we first look for the nearest line
    # *outside* the block.  Then, we look for the nearest line *inside* the block.
    var outside: string
    var inside: string
    if &filetype == 'markdown' || cml == ''
        # Why do you check for a non-whitespace at the end of the first branch?{{{
        #
        # So that we can find a code which contains empty commented lines.
        #}}}
        # Why do you check for a tilde at the end of the second branch?{{{
        #
        # To stop at an output line.
        #
        # This is useful to write 2 blocks of code separated by output lines and
        # be able  to run the second  block without the first  one being wrongly
        # merged with the output lines.  Example:
        #
        #     def FuncA()
        #         def FuncB()
        #         enddef
        #     enddef
        #     FuncB()
        #
        #     E117: Unknown function: FuncB˜
        #
        #     def FuncA()
        #         def FuncB()
        #         enddef
        #         FuncB()
        #     enddef
        #     FuncA()
        #     ✔
        #}}}
        outside = '^\%(\s\{4}\)\@!.*\S\|˜$'
        # Why `[:"#]`?{{{
        #
        # We  need to  ignore a  colon because  we usually  use it  as a  prompt
        # denoting an Ex command which must be executed interactively.
        #
        # We also need to ignore a commented line.
        # Otherwise, we could run some Ex command prefixed by a colon, which was
        # meant to be executed interactively.  It can happen if we have a mix of
        # interactive Ex commands and Vim comments.
        #}}}
        # Why `\zs`?{{{
        #
        # To be able to inspect the syntax  item at the start of where the found
        # code block is supposed to be.  This is necessary for the next `l:Skip`
        # expression to work as expected.
        #}}}
        inside = '^\s\{4,}\zs\%(' .. PROMPT .. '\|[:"#]\)\@!'
    else
        outside = '^\s*' .. cml .. '\%(\s\{5}\)\@!.*\S\|^\s*$\|˜$'
        inside = '^\s*' .. cml .. '\s\{5,}\%(' .. PROMPT .. '\)\@!\zs\S'
    endif
    search(outside .. '\|\%^', 'bW')
    # Why the `{skip}` lambda expression?{{{
    #
    # To ignore  false positives, like  some output, or  list item, and  to make
    # sure we land on a code block.
    #}}}
    var Skip: func = (): bool => !IsInCodeblock()
    var start: number = search(inside, 'W', 0, 500, Skip)
    search(outside .. '\|\%$', 'W')
    var end: number = search(inside, 'bW', 0, 500, Skip)
    setpos('.', curpos)
    if !(start <= curpos[1] && curpos[1] <= end)
        return ''
    endif

    # check the validity of the code block (i.e. it should contain the original line)
    if !(curpos[1] >= line('.') && curpos[1] <= end)
        return ''
    endif

    var startline: string = getline(start)
    # There should not be the start of a heredoc on the first line.{{{
    #
    # If we're  here, it  means that we  didn't find a  command starting  with a
    # prompt.  If we allow the code to proceed, we allow a Vim + heredoc command
    # without prompt.  But only  in a Vim file or in the Vim  wiki; *not* in the
    # other wikis.
    #
    # This  would  be inconsistent.   We  should  be  able  to omit  the  prompt
    # everywhere  or  nowhere.   Let's  choose  nowhere.  If  we  made  it  work
    # everywhere, it  would create another  inconsistency.  We would be  able to
    # omit the  prompt for  all Vim commands  using a heredoc,  but not  for the
    # other commands (e.g. `tee(1)`).
    #}}}
    if startline =~ '<<-\=\([''"]\=\)EOF\1'
        return ''
    endif
    var whole_indent: string = startline->matchstr('^\s*' .. cml .. cbi)
    var lines: list<string> = getline(start, end)
    var cmd: list<string> = lines
        ->map((_, v: string) =>
                v->substitute(whole_indent .. '\|^\s*' .. cml .. '$', '', ''))

    return cmd->CompleteCmd('vim')
enddef

def GetFencedCodeblock(filetype: string): string #{{{2
    var start: number = search('^```' .. filetype, 'bcnW')
    if !start
        return ''
    endif
    ++start

    var curpos: list<number> = getcurpos()
    cursor(0, 1)
    var end: number = search('```$', 'cnW')
    setpos('.', curpos)
    if !end
        return ''
    endif
    --end

    var curlnum: number = line('.')
    if !(start <= curlnum && curlnum <= end)
        return ''
    endif

    var cmd: list<string> = getline(start, end)
    return cmd->CompleteCmd(filetype)
enddef

def GetGccCmd(): string #{{{2
    silent! update
    MakeSureBuildDirExists()
    var dir: string = expand('%:p:h:S')
    var fname: string = expand('%:p:t:S')
    var binary: string = expand('%:p:t:r:S')
    # Don't move `GCC_options()` before `fname`.
    # It would break some options such as `-lm`.
    return printf('cd %s && gcc %s -o build/%s $GCC_OPTS %s && ./build/%s',
        dir, fname, binary, GCC_options(), binary)
enddef

def GetLuaCmd(): string #{{{2
    silent! update
    silent system($'lua -m py_compile {expand('%:p:S')}')
    var dir: string = expand('%:p:h:S')
    var script: string = expand('%:p:t:S')
    return printf('cd %s && lua ./%s', dir, script)
enddef

def GetPythonCmd(): string #{{{2
    silent! update
    var interpreter: string = GetPythonInterpreter()
    silent system($'{interpreter} -m py_compile {expand('%:p:S')}')
    var dir: string = expand('%:p:h:S')
    var script: string = expand('%:p:t:S')
    return printf('cd %s && %s ./%s', dir, interpreter, script)
enddef

def GetRustCmd(): string #{{{2
    silent! update
    MakeSureBuildDirExists()
    var dir: string = expand('%:p:h:S')
    var fname: string = expand('%:p:t:S')
    var binary: string = expand('%:p:t:r:S')
    return printf('cd %s && rustc --out-dir build/ %s && ./build/%s', dir, fname, binary)
enddef

def CompleteCmd(cmd: list<string>, filetype: string): string #{{{2
    if filetype == 'c'
        # TODO: Leverage `GetGccCmd()`?
        writefile(cmd, $'{$TMPDIR}/tmux/run.c')
        return $'gcc -o {$TMPDIR}/tmux/run {$TMPDIR}/tmux/run.c $GCC_OPTS {GCC_options()} && {$TMPDIR}/tmux/run'
    endif

    if filetype == 'lua'
        writefile(cmd, $'{$TMPDIR}/tmux/run.lua')
        var first_word: string = 'lua'
        var fullpath: string = expand('%:p')
        if fullpath =~ $'^{$HOME}/.config/'
            first_word = matchstr(fullpath, $'^{$HOME}/.config/\zs[^/]\+') .. ' -S'
        endif
        return $'{first_word} {$TMPDIR}/tmux/run.lua'
    endif

    if filetype == 'python'
        writefile(cmd, $'{$TMPDIR}/tmux/run.py')
        return $'{GetPythonInterpreter()} {$TMPDIR}/tmux/run.py'
    endif

    # Don't simplify the code.
    # The current form can be leveraged to quickly support new filetypes.
    if ['bash']->index(filetype) >= 0
        return HighlightCode(cmd, filetype)
    endif

    if filetype == 'fish'
        var script: string = $'{$TMPDIR}/tmux/run.fish'
        var highlight: string = printf('sed "1d" %s | fish_indent --ansi', script)
        var code: list<string> = [highlight] + cmd
        writefile(code, script)
        return $'fish {script}'
    endif

    if filetype == 'vim'
        var script: string = $'{$TMPDIR}/tmux/run.vim'
        writefile(cmd, script)
        return $'vim -Nu NONE -S {script}'
    endif
    return ''
enddef

def FiletypeInFencedCodeblock(): string #{{{2
    return searchpair('```\w\+', '', '```', 'bcnW')
        ->getline()
        ->matchstr('^```\zs.*')
    # Alternative:{{{
    #
    #     return synstack('.', col('.'))
    #         ->map((_, v: number): string => synIDattr(v, 'name'))
    #         ->filter((_, v: string): bool => v =~ '\cmarkdownHighlight')
    #         ->get(0, '')
    #         ->matchstr('\cmarkdownHighlight\zs.*')
    #
    # We don't use this code, because it makes too many assumptions, like:
    #
    #    - we use `:help :syn-include` to highlight the block
    #      (we could use text properties instead)
    #
    #    - we name our included clusters with the prefix `markdownHighlight`
    #}}}
enddef

def IsInCodeblock(): bool #{{{2
    # Note that you can't just check that the pattern `codeblock` matches one of the syntax items:{{{
    #
    #     \ ->match('\ccodeblock') >= 0
    #
    # It must match the last one:
    #
    #     \ ->reverse()
    #     \ ->match('\ccodeblock') == 0
    #
    # Indeed, for example, on an output line, here is the stack of syntax items:
    #
    #     ['markdownCodeBlock', 'markdownOutput']
    #
    # It  *does* contain  the pattern  `codeblock`, but  not at  the end  of the
    # stack, which is the only relevant place.
    #}}}
    return synstack('.', col('.'))
        ->get(-1, 0)
        ->synIDattr('name') =~ '\ccodeblock'
enddef

def GCC_options(): string #{{{2
    var stopline: number = search('^```c$', 'bcn')
    return search('^\s*// GCC Options:', 'bcn', stopline)
        ->getline()
        ->matchstr('^\s*// GCC Options: \zs.*')
        ->substitute('{{' .. '{.*', '', '')
enddef

def PreviousPaneRunsShell(): bool #{{{2
    silent var number_of_panes: number = system("tmux display-message -p '#{window_panes}'")
        ->trim("\n", 2)
        ->str2nr()
    if number_of_panes < 2
        return false
    endif

    # TODO: What if we have run `$ echo text | vim -` in the previous pane.{{{
    #
    #     $ tmux display-message -p -t '{last}' '#{pane_current_command}'
    #     zsh˜
    #
    # Maybe we should also make sure that `[No Name]` can't be found in the pane.
    # If it  can, Vim  is probably  running, and  we don't  want our  next shell
    # command to be written there.
    #
    # Note that – I think – you need to escape the brackets:
    #
    #     $ tmux display-message -p -t '{last}' '#{C:\[No Name\]}'
    #
    # Otherwise you can get weird results:
    #
    #     # open xterm
    #     $ tmux -Lx
    #     $ tmux split-window
    #     $ vim
    #     :lastp
    #     $ tmux display-message -p -t '{last}' '#{C:[No Name]}'
    #     10˜
    #     $ tmux last-pane
    #     :quit
    #     $ tmux last-pane
    #     $ tmux display-message -p -t '{last}' '#{C:[No Name]}'
    #     2˜
    #
    # The last command should output 0.
    #
    # I haven't  tried to  implement this  for the moment,  because last  time I
    # tried, I got unexpected and inconsistent results.
    # Besides, it seems like a corner case; is it worth the trouble?
    #}}}
    silent var cmd_in_previous_pane: string =
        system("tmux display-message -p -t '{last}' '#{pane_current_command}'")
        ->trim("\n", 2)
    return cmd_in_previous_pane =~ '^\%(bash\|dash\|fish\)$'
enddef

def GetPreviousPaneId(): string #{{{2
    silent return system("tmux display-message -p -t '{last}' '#{pane_id}'")
        ->trim("\n", 2)
enddef

def IsZoomedWindow(): bool #{{{2
    silent return system('tmux display-message -p "#{window_zoomed_flag}"')
        ->trim("\n", 2)
        ->str2nr() == 1
enddef

def PaneIsRunning(pgm: string): bool #{{{2
    # We  can't rely  on the  `pane_current_command` tmux  format, because  it
    # might  expand to  something  like  `bash`, while  actually  the pane  is
    # running Vim (a bash script could start Vim).
    silent var pane_pid: string = $'tmux display-message -t {pane_id} -p "#{{pane_pid}}"'
        ->system()
        ->trim()

    # We need to look  at the child processes, because the  command run by the
    # pane might  have started  `pgm` as a  child (e.g.  `vipe(1)`, `bash(1)`, ...).
    silent var pstree: string = $'pstree {pane_pid}'
        ->system()
        ->trim()

    if pgm == 'vim'
        return pstree =~ '\<n\=vim\%(diff\)\=$'
            .. '\|' .. '{n\=vim\%(diff\)\=}$'
    elseif pgm == 'less'
        return pstree =~ '\<less$'
    endif

    return false
enddef
