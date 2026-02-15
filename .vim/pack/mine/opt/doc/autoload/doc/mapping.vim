vim9script

# Init {{{1

import 'lg.vim'
import autoload 'tmux.vim'

# The filetype of a header file (`.h`) is `cpp`.
const DEVDOCS_ENABLED_FILETYPES: list<string> =<< trim END
    cpp
    html
    css
END

# Interface {{{1
export def Main(type = '') #{{{2
    # Make tests on:{{{
    #
    # foo `man bash` bar
    # foo `man bash /keyword/;/running` bar
    # foo `info groff` bar
    # foo `info groff /difficult/;/confines` bar
    # foo `:help :command` bar
    # foo `:help :command /below/;/list` bar
    # foo `:help /\@=` bar
    # foo `:help /\@= /tricky/;/position` bar
    # foo `CSI ? Pm h/;/Ps = 2 0 0 4` bar
    # foo `$ ls -larth` bar
    #
    #     man bash
    #     man bash /keyword/;/running
    #     info groff
    #     info groff /difficult/;/confines
    #     :help :command
    #     :help :command /below/;/list
    #     :help /\@=
    #     :help /\@= /tricky/;/position
    #     CSI ? Pm h/;/Ps = 2 0 0 4
    #     $ ls -larth
    #}}}
    var cmd: string = GetCmd(type)
    if cmd == ''
        var cword: string = GetCword()
        if cword !~ '\w'
            return
        endif
        if cword =~ '([0-9a-z])$'
            execute $'Man {cword}'
            return
        endif

        # Why do some filetypes need to be handled specially?  Why can't they be handled via `'keywordprg'`?{{{
        #
        # Because  we need  some special  logic which  would need  to be  hidden
        # behind custom  commands, and I  don't want to install  custom commands
        # just for that.
        #
        # It would also  make the code more complex; you  would have to update
        # `b:undo_ftplugin`  to reset  `'keywordprg'`  and  remove the  ad-hoc
        # command.  Besides, the latter needs a specific signature (`-buffer`,
        # `-nargs=1`, `<q-args>`,  ...). And it would  introduce an additional
        # dependency (`vim-lg`) because you  would need to move `UseManPage()`
        # into the latter.
        #
        # ---
        #
        # There is an additional benefit  in dealing here with filetypes which
        # need a  special logic.   We can tweak  `'iskeyword'` more  easily to
        # include some characters  (e.g. `-`) when looking for  the word under
        # the cursor.   It's easier here,  because we  only have to  write the
        # code  dealing  with  adding  `-`  to  `'iskeyword'`  once;  no  code
        # duplication.
        #}}}
        if FiletypeIsSpecial()
            HandleSpecialFiletype(cword)

        elseif In('cheatCommandShell')
            execute $'Man {cword}'

        elseif &l:keywordprg != ''
            UseKeywordPrg()

        elseif !OnCommentedLine() && FiletypeEnabledOnDevdocs()
            UseDevdoc()

        else
            echo 'no known command here (:h, $ cmd, man, info, CSI/OSC/DCS)'
        endif
        return
    endif
    if cmd =~ '^pydoc\s'
        UsePydoc()
        return
    endif
    if VisualSelectionContainsShellCode(type)
        execute $'ExplainShell {cmd}'
        return
    endif
    cmd = VimifyCmd(cmd)
    # If the command does not contain a `/topic` token, just execute it.{{{
    #
    # Note that a  shell command may include  a slash, but it will  never be the
    # start of a `/topic`.  We never use `/topic` after a shell command:
    #
    #     ✔
    #     $ ls -larth
    #
    #     ✘
    #     $ ls -larth /some topic
    #}}}
    if cmd !~ '/' || cmd =~ '^ExplainShell '
        # Don't let a quote or a bar terminate the shell command prematurely.{{{
        #
        #     command -bar -nargs=1 ExplainShell Func(<q-args>)
        #     def Func(cmd: string)
        #         echo cmd
        #     enddef
        #
        #     ExplainShell a"b
        #     a˜
        #     ExplainShell a|b
        #     a˜
        #}}}
        cmd = escape(cmd, '"|')
        try
            execute cmd
        catch
            lg.Catch()
            return
        endtry
        return
    endif
    # The regex is a little complex because a help topic can start with a slash.{{{
    #
    # Example: `:help /\@>`.
    #
    # In that case, when parsing the command, we must not *stop* at this slash.
    # Same thing when parsing the offset: we must not *start* at this slash.
    #}}}
    var topic: string
    [cmd, topic] = matchlist(cmd, '\(.\{-}\)\%(\%(:h\s\+\)\@<!\(/.*\)\|$\)')[1 : 2]
    execute cmd
    # `execute ... cmd` could fail without giving a real Vim error, e.g. `:Man not_a_cmd`.
    # In such a case, we don't want the cursor to move.
    if NotInDocumentationBuffer()
        return
    endif
    try
        # Why the loop?{{{
        #
        # You cannot simply write:
        #
        #     topic->trim('/')->search('c')
        #
        # It would  not be able  to handle  multiple line specifiers  separated by
        # semicolons:
        #
        #     /foo/;/bar
        #
        # This syntax is only available in the range of an Ex command; see `:help :;`.
        #
        # ---
        #
        # Alternatively, we could just write:
        #
        #     execute ':' .. topic
        #
        # But, in  Vim9, I try  to avoid `:execute` as  much as possible,  in part
        # because it suppresses the compilation of the executed command.
        #}}}
        for line_spec: string in topic
                ->trim('/')
                ->split('/;/')
            if search(line_spec, 'c') == 0
                throw $'E486: Pattern not found: {line_spec}'
            endif
        endfor
    catch
        lg.Catch()
        return
    endtry
    topic
        ->trim('/')
        ->SetSearchRegister()
enddef
# }}}1
# Core {{{1
def GetCmd(type: string): string #{{{2
    var cmd: string
    if type == 'vis'
        cmd = lg.GetSelectionText()->join("\n")
    else
        var line: string = getline('.')
        var cmd_pat: string =
            '\C\s*\zs\%('
            ..    ':h\%[elp]\|info\|man\|pydoc\|CSI\|OSC\|DCS'
            # random shell command for which we want a description via `~/bin/explain-shell`
            ..    '\|\$'
            .. '\)\s.*'
            # name of command followed by man page section{{{
            #
            # Need  to assert  the presence  of a backtick  to avoid  a spurious
            # match, causing an unexpected error:
            #
            #     # in a Vim9 script, press `K` on `setline`
            #     report->setline(1)
            #     # expected: `:help setline` is executed
            #     # actual: man.vim: No manual entry for setline
            #}}}
            .. '\|\s*\zs\%(\w\|[-.]\)\+([1-9]\w*)'
        #                                ^^^
        #                                for something like `ec(1ssl)`
        var codespan: string = GetCodespan(line, cmd_pat)
            # In a snippets file (and in a heredoc if `EOF` is unquoted), backticks around a codespan need to be escaped:{{{
            #
            #     \`info tee\`
            #               ^
            #
            # Ignore the trailing backslash.
            #}}}
            ->trim('\', 2)
        var codeblock: string = GetCodeblock(line, cmd_pat)
        if codeblock == '' && codespan == '' && OnCommentedLine()
            # Special Cases:
            #     # See systemd-system.conf(5) for details.
            #           ^--------------------^
            #           in /etc/systemd/system.conf
            #
            #     Documentation=man:systemd.special(7)
            #                       ^----------------^
            #                       in /usr/lib/systemd/user/sound.target
            var cWORD: string = expand('<cWORD>')
            if cWORD =~ '\%(\w\|[-.]\)\+([1-9]\w*)$'
                cmd = cWORD->matchstr('\%(\w\|[-.]\)\+([1-9]\w*)$')
            else
                cmd = ''
            endif
        # if the  function finds a codespan  *and* a codeblock, we  want to give
        # the priority to the latter
        elseif codeblock != ''
            cmd = codeblock
        elseif codespan != ''
            cmd = codespan
        endif
    endif

    if cmd =~ '^\%(\w\|[-.]\)\+([1-9]\w*)$'
        var name: string
        var section: string
        [name, section] = cmd->matchlist('\(\%(\w\|[-.]\)\+\)(\([1-9]\)\w*)')[1 : 2]
        return printf('man %s %s', section, name)
    endif
    return cmd
        # Ignore everything after a bar.{{{
        #
        # Useful to avoid an error  when pressing `K` while visually selecting
        # a  shell command  containing a  pipe.  Also,  we don't  want Vim  to
        # interpret  what follows  the  bar  as an  Ex  command;  it could  be
        # anything, too dangerous.
        #}}}
        ->substitute('.\{-}\zs|.*', '', '')
enddef

def GetCodespan(line: string, cmd_pat: string): string #{{{2
    var cml: string = GetCml()
    var pat: string =
        # we are on a commented line
           '\%(^\s*' .. cml .. '.*\)\@<='
        .. '\%(^\%('
        # there can be a codespan before
        ..         '`[^`]*`'
        ..         '\|'
        # there can be a character outside a codespan before
        ..         '[^`]'
        ..      '\)'
        # there can be several of them
        ..     '*'
        ..  '\)\@<='
        .. '\%('
        # a codespan with the cursor in the middle
        ..     '`[^`]*\%.c[^`]*`'
        ..     '\|'
        # a codespan with the cursor on the opening backtick
        ..     '\%.c`[^`]*`'
        ..  '\)'

    var codespan: string = line->matchstr(pat)
    # Make sure the  text does contain a  command for which our  plugin can find
    # some documentation.
    if codespan !~ $'^`\%({cmd_pat}\)'
        return ''
    endif

    return codespan
        # remove a possible leading `$` (shell prompt)
        ->trim('$', 1)
        # remove surrounding backticks
        ->trim('`')
enddef

def GetCodeblock(line: string, cmd_pat: string): string #{{{2
    var cml: string = GetCml()
    var n: number = &filetype == 'markdown' ? 4 : 5
    var pat: string = '^\s*' .. cml .. ' \{' .. n .. '}\%(' .. cmd_pat .. '\)'
    var codeblock: string = line->matchstr(pat)
    return codeblock
enddef

def GetCword(): string #{{{2
    var iskeyword_save: string = &l:iskeyword
    var bufnr: number = bufnr('%')
    var cword: string
    try
        # Support `[` and `[[` bash builtins.
        setlocal iskeyword+=[
        cword = expand('<cword>')
        if cword == '[' || cword == '[['
            return cword
        endif
        setlocal iskeyword-=[

        # Including the parens is useful for a possible man page section number:{{{
        #
        #     run-mailcap(1)
        #                ^ ^
        #}}}
        if &filetype != 'vim'
                && getline('.')->match('^\s*#') == -1
            setlocal iskeyword+=-,(,)
        endif

        cword = expand('<cword>')
        setlocal iskeyword-=(,)
        if cword =~ '^\w\+(\d\+)$'
            return cword
        endif

        # Support Python methods calls, like:
        #
        #     sys.stdout.flush()
        if &filetype == 'python'
            setlocal iskeyword+=.
            cword = expand('<cword>')

        # Handle man page whose name contains multiple words.{{{
        #
        # In bash:
        #
        #     git checkout
        #     →
        #     :Man git-checkout
        #
        # In fish:
        #
        #     string match
        #     →
        #     :Man string-match
        #}}}
        elseif &filetype == 'bash' || &filetype == 'fish'
            var curline: string = getline('.')
            var cword_and_next: string = curline
                ->matchstr('\<\w*\%.c\w*\s\+\w\+')
                ->substitute('\s\+', '-', '')
            if cword_and_next != ''
                    && ManPageWithMultipleWords(cword_and_next)
                return cword_and_next
            endif

            var cword_and_prev: string = curline
                ->matchstr('\<\w\+\s\+\w*\%.c\w*')
                ->substitute('\s\+', '-', '')
            if cword_and_prev != ''
                    && ManPageWithMultipleWords(cword_and_prev)
                return cword_and_prev
            endif
        else
            cword = expand('<cword>')
        endif
    finally
        setbufvar(bufnr, '&iskeyword', iskeyword_save)
    endtry
    return cword
enddef

def HandleSpecialFiletype(cword: string) #{{{2
    if ['awk', 'sshconfig', 'sshdconfig', 'terminfo']->index(&filetype) >= 0
        UseManPage(&filetype, cword)

    elseif &filetype == 'bash'
        silent if cword->printf('bash -c "type %s"')->system() !~ 'is a shell \%(builtin\|keyword\)'
            execute $'Man {cword}'
            return
        endif
        silent var help: list<string> = cword
            ->printf('bash -c "help %s"')
            ->systemlist()
        if v:shell_error != 0
            return
        endif
        new
        &l:buftype = 'nofile'
        &l:bufhidden = 'wipe'
        &l:swapfile = false
        execute 'file $\ help\ ' .. cword
        nnoremap <buffer><nowait><expr> q reg_recording() != '' ? 'q' : '<ScriptCmd>quit<CR>'
        help->setline(1)
        # The help for `[` and `[[` is incomplete.
        # We also need the help for the `test` builtin.
        if cword == '[' || cword == '[['
            silent ([''] + systemlist('bash -c "help test"'))
                ->append('$')
        endif

    elseif &filetype == 'c'
        var section: number
        if ManPageExists($'2 {cword}')
            section = 2
        elseif ManPageExists($'3 {cword}')
            section = 3
        else
            Error($'No manual entry for {cword}')
            return
        endif
        execute $'Man {section} {cword}'
        @/ = cword

    elseif &filetype == 'lua'
            || &filetype == 'vim'
            || &filetype == 'markdown' && In('markdownHighlight_vim')
            || &filetype == 'markdown' && getcwd() == $HOME .. '/Wiki/vim'
        var tag: string = &filetype == 'lua' ? LuaHelpTag() : HelpTag()
        if tag == ''
            Error('E349: No identifier under cursor')
            return
        endif
        try
            execute 'help ' .. tag
        catch
            lg.Catch()
            return
        endtry

    elseif &filetype == 'navi'
        var cmd: string = GetCword()
        if ManPageExists(cmd)
            execute $'Man {cmd}'
        endif

    elseif &filetype == 'python'
            || &filetype == 'markdown' && In('markdownHighlight_python')
            || &filetype == 'markdown' && getcwd() == $HOME .. '/Wiki/python'
        UsePydoc()

    elseif &filetype == 'strace'
        execute $'Man 2 {expand('<cword>')}'

    elseif &filetype == 'sudoers'
        var word: string
        if cword =~ '^[A-Z]\+$' && cword =~ '^NO'
            word = cword->substitute('NO', '', '')
        endif
        Man 5 sudoers
        @/ = $'^\s*\zs\C{word}'
        histadd('/', @/)
        search(@/)

    elseif &filetype == 'systemd'
        # for the moment, we only try to handle keys
        if getline('.') !~ '^\s*' .. '[#;]\=' .. '\s*\w*\%.c\w*='
        #                            ^------^
        #                            possibly commented
            return
        endif
        @/ = '^\s*'
            # There could be parameters before (e.g. `Before=` in `man systemd.unit`).{{{
            #
            # For  example,  if  we're   looking  for  the  documentation  about
            # `After=`, we want to find this line:
            #
            #     Before=, After=
            #     ^-------^
            #     need to match this before
            #}}}
            .. '\%(\S\+=,\s*\)*'
            .. '\zs' .. GetCword() .. '=\ze'
            # there could be parameters after
            .. '\%(,\s*\S\+=,\=\s*\)*'
            .. '$'
        histadd('/', @/)
        execute $'silent lvimgrep /{@/}/gj man://systemd.directives'

        # Problem: the location list gets broken once we start jumping to its entries.
        # Solution: Save the location list.  Load the man buffer.  Restore the original location list.
        # For more info, see our comments in: `~/.vim/pack/mine/opt/man/autoload/man.vim`.
        # Look for the pattern "vimgrep".
        var title: string = getloclist(0, {title: 0}).title
        var loclist: list<dict<any>> = getloclist(0)
        if bufexists('man://systemd.directives')
            bufload('man://systemd.directives')
        endif
        setloclist(0, loclist, 'r')
        setloclist(0, [], 'a', {title: title})

        if getloclist(0, {size: 0}).size >= 1
            lclose
            split
            silent lfirst
            if getloclist(0, {size: 0}).size > 1
                doautocmd <nomodeline> QuickFixCmdPost lopen
                wincmd p
            endif
        endif

    elseif &filetype == 'tmux'
        tmux.Man()
    endif
enddef

def UseManPage(name: string, cword: string) #{{{2
    try
        # first try to look for the current word in the man page for `name`
        var man_page: string = {
            sshconfig: 'ssh_config',
            sshdconfig: 'sshd_config',
        }->get(name, name)
        execute $'Man {man_page}'

        var pat: string
        if name == 'terminfo'
            pat = '\C\<' .. cword .. '\>'
        else
            # Don't use `\>` (in a man buffer, `(` is in `'iskeyword'`).
            # ---
            # We need to allow `(` to  match after `cword` for a function name
            # such as `split()` in an awk buffer.
            pat = '^\C\s*\zs\<' .. cword .. '\ze\%([ (]\|$\)'
        endif
        # we  use `:/`  instead of  `search()` to  get an  error if  the pattern
        # cannot be found
        execute ':/' .. pat
        setreg('/', [pat], 'c')
        # we use `search()`  to be on the  right column, if the match  is not at
        # the start of the line
        search(pat, 'cW')
    catch /^Vim\%((\a\+)\)\=:E486:/
        # if we can't find the current word in `:Man name`, then try `:Man cword`
        if &filetype == 'man'
            close
        endif
        # Why not trying to catch a possible error if we press `K` on some random word?{{{
        #
        # When `:Man`  is passed the name  of a non-existing man  page, an error
        # message is echo'ed;  but it's just a message highlighted  in red; it's
        # not a real error, so you can't catch it.
        #}}}
        execute $'Man {cword}'
    endtry
enddef

def UseKeywordPrg() #{{{2
    var cword: string = GetCword()
    if &l:keywordprg[0] == ':'
        try
            execute printf('%s %s', &l:keywordprg, cword)
        catch /^Vim\%((\a\+)\)\=:\%(E149\|E434\):/
            lg.Catch()
            return
        endtry
    else
        execute printf('!%s %s', &l:keywordprg, shellescape(cword, true))
    endif
enddef

def UsePydoc() #{{{2
    var cword: string = GetCword()
    silent var doc: list<string> = systemlist('pydoc ' .. shellescape(cword))
    if get(doc, 0, '') =~ '^\cno python documentation found for'
        echo doc[0]
        return
    endif
    execute 'new ' .. tempname()
    doc->setline(1)
    &l:bufhidden = 'delete'
    &l:buftype = 'nofile'
    &l:buflisted = false
    &l:swapfile = false
    &l:modifiable = false
    &l:readonly = true
    nmap <buffer><nowait> q <Plug>(my-quit)
enddef

def UseDevdoc() #{{{2
    var cword: string = GetCword()
    execute 'Doc ' .. cword .. ' ' .. &filetype
enddef

def VimifyCmd(arg_cmd: string): string #{{{2
    var cmd: string = arg_cmd
    if cmd =~ '^\%(info\|man\)\s'
        var Rep: func = (m: list<string>): string => m[0] == 'info' ? 'Info' : 'Man'
        cmd = cmd->substitute('^\%(info\|man\)', Rep, '')
    elseif cmd =~ '^\%(CSI\|OSC\|DCS\)\s'
        cmd = $'CtlSeqs /{cmd}'
    elseif cmd =~ '^\$\s'
        var first_word: string = cmd->matchstr('\%(\w\+\|-\)\+')
        if first_word =~ '^sudo' && expand('<cword>') !~ 'sudo'
            cmd = cmd->substitute('\%(\w\+\|-\)\+', '', '')
        endif
        cmd = $'Man {cmd->matchstr('\%(\w\+\|-\)\+')}'
    elseif cmd =~ '^:h\%[elp]\s'
        # nothing to do; `:help` is already a Vim command
    else
        # When can this happen?{{{
        #
        # When  you visually  select some  text  which doesn't  match any  known
        # documentation command.
        #
        # Or when you refactor `GetCmd()` to support a new kind of documentation
        # command, but you forget to refactor this function to “vimify” it.
        #}}}
        echo 'not a documentation command (:help, $ cmd, man, info, pydoc, CSI/OSC/DCS)'
        cmd = ''
    endif
    return cmd
enddef

def SetSearchRegister(topic: string) #{{{2
    # Populate the search register with  the topic if it doesn't contain
    # any offset, or with the last offset otherwise.
    if topic =~ '/;/'
        setreg('/', [topic->matchstr('.*/;/\zs.*')], 'c')
    else
        setreg('/', [topic], 'c')
    endif
enddef

def LuaHelpTag(): string #{{{2
    var original_iskeyword: string = &l:iskeyword

    # `v:lua`, `v:lua-call`
    setlocal iskeyword+=:
    var word: string = expand('<cword>')
    &l:iskeyword = original_iskeyword

    # to ignore punctuation like a single paren
    if word !~ '\w'
        return ''
    endif

    if word->MatchSomeHelpTag()
            # to ignore `vim` in `vim.cmd()` when the cursor is on `vim`
            && word =~ ':'
        return word
    endif

    setlocal iskeyword+=.
    word = expand('<cword>')
    &l:iskeyword = original_iskeyword

    # Note that the cursor could be before the tag:{{{
    #
    #     ___vim.cmd()
    #     ^^^
    #     stand for 3 spaces
    #
    # `expand('<cword>')` would still give `vim.cmd`.
    #}}}
    # If the word is followed by a paren, grab it to avoid some conflict between
    # a command and a function.
    if getline('.') =~ '\%.c\s*\%(\w\|\.\)\+('
            # to ignore the `:help function()` tag when we're defining
            # a Lua anonymous function (with `function()`)
            && word != 'function'
        word ..= '()'
    endif

    if word =~ '^\<vim\.api\.'
        var col_end: number = matchend(word, 'vim.api.')
        if word[col_end :] != ''
            return word[col_end :]
        endif

    elseif word =~ '^\<api\.'
        var col_end: number = matchend(word, 'api.')
        if word[col_end :] != ''
            return word[col_end :]
        endif

    elseif word =~ '^\<vim\.fn\.'
        var col_end: number = matchend(word, 'vim.fn.')
        if word[col_end :] != ''
            return word[col_end :]
        endif

    elseif word =~ '^\<fn\.'
        var col_end: number = matchend(word, 'fn.')
        if word[col_end :] != ''
            return word[col_end :]
        endif

    elseif word->MatchSomeHelpTag()
        # If we press `K` on `if`, we want `:help luaref-if`; not `:help :if`.
        if ('luaref-' .. word)->MatchSomeHelpTag()
            return 'luaref-' .. word
        endif
        return word

    elseif word =~ '\.'
        var last_token: string = split(word, '\.')->get(-1, '')
        if last_token != '' && last_token->MatchSomeHelpTag()
            return last_token
        endif
    endif

    return word
enddef

def HelpTag(): string #{{{2
    var line: string = getline('.')
    var col: number = col('.')
    var charcol: number = charcol('.')
    var pat_pre: string
    if line[charcol - 1] =~ '\k'
        pat_pre = '.*\ze\<\k*\%.c'
    else
        pat_pre = '.*\%.c.'
    endif
    var pat_post: string = '\%.c\k*\>\zs.*'
    var pre: string = line->matchstr(pat_pre)
    var post: string = line->matchstr(pat_post)

    var syntax_item: string = synstack('.', col)
        ->get(-1, 0)
        ->synIDattr('name')
    var cword: string = expand('<cword>')

    if syntax_item == 'markdownCodeBlock'
        return cword
    endif
    if syntax_item == 'vimFuncName'
        || syntax_item == 'vi9FuncNameBuiltin'
        return cword .. '()'
    endif
    if syntax_item == 'vimOption'
        || syntax_item =~ 'vi9.*Option'
        return "'" .. cword .. "'"
    endif
    # `-bar`, `-nargs`, `-range`...
    if syntax_item == 'vimUserAttrbKey'
        || syntax_item == 'vi9UserAttrbKey'
        return ':command-' .. cword
    endif
    # `<silent>`, `<unique>`, ...
    if syntax_item == 'vimMapModKey'
        || syntax_item == 'vi9MapModKey'
        return ':map-<' .. cword
    endif

    # if the word under the cursor is  preceded by nothing, except maybe a colon
    # right before, treat it as an Ex command
    if pre =~ '^\s*:\=$'
        return ':' .. cword
    endif

    # `v:key`, `v:val`, `v:count`, ... (cursor after `:`)
    if pre =~ '\<v:$'
        return 'v:' .. cword
    endif
    # `v:key`, `v:val`, `v:count`, ... (cursor on `v`)
    if cword == 'v' && post =~ ':\w\+'
        return 'v' .. post->matchstr(':\w\+')
    endif

    return cword
enddef
#}}}1
# Utilities {{{1
def Error(msg: string) # {{{2
    echohl ErrorMsg
    echomsg msg
    echohl NONE
enddef

def In(syngroup: string): bool #{{{2
    return synstack('.', col('.'))
        ->indexof((_, id: number): bool => id->synIDattr('name') =~ '\c' .. syngroup) >= 0
enddef

def FiletypeIsSpecial(): bool #{{{2
    return [
        'awk',
        'bash',
        'c',
        'lua',
        'markdown',
        'navi',
        'python',
        'sshconfig',
        'sshdconfig',
        'strace',
        'sudoers',
        'systemd',
        'terminfo',
        'tmux',
        'vim'
    ]->index(&filetype) >= 0
enddef

def OnCommentedLine(): bool #{{{2
    var cml: string = GetCml()
    if cml == ''
        return false
    endif
    return getline('.') =~ '^\s*' .. cml
enddef

def FiletypeEnabledOnDevdocs(): bool #{{{2
    return DEVDOCS_ENABLED_FILETYPES->index(&filetype) >= 0
enddef

def GetCml(): string #{{{2
    var cml: string
    if &filetype == 'navi'
        cml = '[;#]'
    elseif &filetype == 'markdown'
        cml = ''
    elseif &filetype == 'vim'
        cml = '["#]'
    else
        cml = '\V' .. &l:commentstring->matchstr('\S*\ze\s*%s')->escape('\') .. '\m'
    endif
    return cml
enddef

def VisualSelectionContainsShellCode(type: string): bool #{{{2
    return type == 'vis' && &filetype == 'bash' && !OnCommentedLine()
enddef

def NotInDocumentationBuffer(): bool #{{{2
    return ['help', 'info', 'man']->index(&filetype) == -1
        && expand('%:t') != 'ctlseqs.txt.gz'
enddef

def ManPageWithMultipleWords(words: string): bool #{{{2
    return &filetype == 'fish'
        && words =~ '^string\s\+\w\+$'
        || &filetype =~ '^\%(bash\|fish\)$'
        && ManPageExists(words)
enddef

def ManPageExists(topic: string): bool #{{{2
    silent return system($'man --where {topic->escape('()')}') !~ '^No manual entry'
enddef

def MatchSomeHelpTag(word: string): bool # {{{2
    return !getcompletion('help ' ..  word, 'cmdline')
        ->empty()
enddef
