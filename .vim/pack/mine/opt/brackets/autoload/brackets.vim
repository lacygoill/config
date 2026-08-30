vim9script

import 'lg.vim'
import autoload 'fold/lazy.vim' as LazyFold

# Interface {{{1
export def IList( #{{{2
    cmd: string,
    search_cur_word: bool,
    start_at_cursor: bool,
    search_in_comments: bool,
    pattern = ''
)
    # Derive the commands used below from the first argument.
    var excmd: string = cmd .. 'list' .. (search_in_comments ? '!' : '')
    var normcmd: string = toupper(cmd)

    var pat: any
    var output: string
    var title: string
    # if we call the function from a normal mode mapping, the pattern is the
    # word under the cursor
    if search_cur_word
        # `silent!` because pressing `]I` on a unique word gives `E389`
        output = execute('normal! ' .. (start_at_cursor ? ']' : '[') .. normcmd, 'silent!')
        title = (start_at_cursor ? ']' : '[') .. normcmd

    # the function was called by a custom Ex command
    else
        if pattern != ''
            pat = pattern
        elseif pattern == ''
            # otherwise the function must have been called from visual mode
            # (visual mapping): use the visual selection as the pattern
            pat = lg.GetSelectionText()

            # `:ilist` can't find a multiline pattern
            if len(pat) != 1
                Error('E389: Couldn''t find pattern')
                return
            endif
            pat = pat[0]

            # make sure the pattern is interpreted literally
            pat = '\V' .. escape(pat, '\/')
        endif

        output = execute(
            (start_at_cursor ? '+1,$' : '') .. excmd .. ' /' .. pat,
            'silent!')
        title = excmd .. ' /' .. pat
    endif

    var lines: list<string> = split(output, '\n')
    # bail out on errors
    if get(lines, 0, '') =~ '^Error detected\|^$'
        var msg: string = 'Could not find '
            .. string(search_cur_word ? expand('<cword>') : pat)
        Error(msg)
        return
    endif

    # Our results may span multiple files so we need to build a relatively
    # complex list based on filenames.
    var filename: string = ''
    var ll_entries: list<dict<any>>
    for line: string in lines
        # A line in the output of `:ilist` and `dlist` can be a filename.
        # It happens when there are matches in other included files.
        # It's how `:ilist` / `:dlist`tells us in which files are the
        # following entries.
        #
        # When we find such a line, we don't parse its text to add an entry
        # in the ll, as we would do for any other line.
        # We use it to update the variable `filename`, which in turn is used
        # to generate valid entries in the ll.
        if line !~ '^\s*\d\+:'
            filename = line->fnamemodify(':p:.')
            #                              │ │{{{
            #                              │ └ relative to current working directory
            #                              └ full path
        #}}}
        else
            var lnum: number = split(line)[1]->str2nr()

            # remove noise from the text output:
            #
            #    1:   48   line containing pattern
            # ^__________^
            #     noise

            var text: string = line->substitute('^\s*\d\{-}\s*:\s*\d\{-}\s', '', '')

            var col: number = match(text,
                search_cur_word ? '\C\<' .. expand('<cword>') .. '\>' : pat
                ) + 1
            ll_entries->add({
                filename: filename,
                lnum: lnum,
                col: col,
                text: text,
            })
        endif
    endfor

    setloclist(0, [], ' ', {
        items: ll_entries,
        title: title,
        context: {
            origin: 'mine',
            matches: [['Conceal', 'location']],
        }
    })

    # Populating the location list doesn't fire any event.
    # Fire `QuickFixCmdPost`, with the right pattern (*), to open the ll window.
    #
    # (*)  `lvimgrep` is  a  valid pattern  (`:help  QuickFixCmdPre`), and  it
    # begins with  a `l`.   The autocmd  that we use  to automatically  open a
    # quickfix/location window,  relies on  the name of  the command  (how its
    # name begins), to determine whether it must open the quickfix or location
    # window.
    doautocmd <nomodeline> QuickFixCmdPost lwindow
enddef

export def MvLine(dir: string, type = ''): string #{{{2
    if type == ''
        &operatorfunc = function(MvLine, [dir])
        return 'g@l'
    endif

    var cnt: number = v:count1
    # disabling the folds may alter the view, so save it first
    var view: dict<number> = winsaveview()

    &l:foldenable = false
    try
        # `silent!` suppresses `E16` when reaching an edge of the buffer
        if dir == '['
            silent! move .-2
        else
            silent! move .+1
        endif

        if &filetype != 'markdown' && &filetype != ''
            silent normal! ==
        endif
    finally
        &l:foldenable = true
        var curpos: list<number> = getcurpos()
        # restore the view *after* re-enabling folding, because the latter may
        # alter the view
        winrestview(view)
        setpos('.', curpos)
    endtry
    return ''
enddef

export def EditNextFile(fwd = true) #{{{2
    var there: string = expand('%:p')
    # necessary to not be stuck in an endless loop when moving backward
    if there->empty()
        there = getcwd() .. '/'
    endif

    # There might not be a "next" file in the same directory; but there might be
    # one in another directory, higher in the tree.  If necessary, iterate until
    # we find one.
    while true
        # let's find all the entries in the directory of the current file
        var entries: list<string> = there
            ->fnamemodify(':h')
            ->ReadDir()

        if fwd
            # only keep  the entries  whose names  come *after*  the one  of the
            # current entry
            entries->filter((_, entry: string): bool => entry > there
                # ignore  a  `.wants/`  systemd directory,  because  it  might
                # actually make us loop back to an earlier file
                && entry !~ '/systemd/.*\.wants$')
        else
            # only keep  the entries whose  names come  *before* the one  of the
            # current entry
            entries->filter((_, entry: string): bool => entry < there
                && entry !~ '/systemd/.*\.wants$')
                # also, reverse the  results so that the  nearest entry comes
                # first instead of last
                ->reverse()
        endif
        var next_entry: string = get(entries, 0, '')

        # didn't find anything
        if next_entry->empty()
            # can't climb up higher; bail out
            if there == '/'
                return
            endif
            # update `there` to climb up the tree in the next iteration
            there = there->fnamemodify(':h')
            continue
        endif

        there = next_entry

        var climb_up: bool = false
        # if we found a directory, climb down the tree until we find a file
        while there->isdirectory()
            entries = ReadDir(there)
            # found an empty directory; bail out from this loop, there's nothing
            # we can find down there
            if entries->empty()
                # but  remember *not*  to bail  out from  the outer  loop; there
                # might still be something up there
                climb_up = true
                break
            endif
            there = entries[fwd ? 0 : -1]
        endwhile

        if !climb_up
            break
        endif
    endwhile

    if !there->filereadable()
        return
    endif

    execute $'edit {there->fnameescape()}'
enddef

export def Put( #{{{2
    where: string,
    how_to_indent: string,
    register = '',
    type = ''
): string

    if type == ''
        &operatorfunc = function(Put, [where, how_to_indent, v:register])
        return 'g@l'
    endif

    var cnt: number = v:count1

    # If the register is empty, an error should be given.{{{
    #
    # And we want the exact message we would  have, if we were to try to put the
    # register without our mapping.
    #
    # That's the whole purpose of the next `:normal`:
    #
    #     Vim(normal):E353: Nothing in register "˜
    #     Vim(normal):E32: No file name˜
    #     Vim(normal):E30: No previous command line˜
    #     ...˜
    #}}}
    if getreg(register, true, true) == []
        try
            execute 'normal! "' .. register .. 'p'
        catch
            lg.Catch()
            return ''
        endtry
    endif

    var reg_save: dict<any> = getreginfo('z')
    if register =~ '[/:%#.]'
        # The type of the register we put needs to be linewise.
        # But some registers are special: we can't change their type.
        # So, we'll temporarily duplicate their contents into `z` instead.
        reg_save = getreginfo('z')
    else
        reg_save = getreginfo(register)
    endif

    var reg_to_use: string
    # Warning: about folding interference{{{
    #
    # If one of  the lines you paste  is recognized as the beginning  of a fold,
    # and you  paste using  `<p` or  `>p`, the  folding mechanism  may interfere
    # unexpectedly, causing too many lines to be indented.
    #
    # You could prevent that by temporarily disabling 'foldenable'.
    # But doing so will sometimes make the view change.
    # So, you would also need to save/restore the view.
    # But doing so  will position the cursor right back  where you were, instead
    # of the first line of the pasted text.
    #
    # All in all, trying to fix this rare issue seems to cause too much trouble.
    # So, we don't.
    #}}}
    try
        if register =~ '[/:%#.]'
            reg_to_use = 'z'
            getreginfo(register)->extend({regtype: 'l'})->setreg('z')
        else
            reg_to_use = register
        endif

        # If  we've just  sourced some  line of  code in  a markdown  file, with
        # `+s{text-object}`, the register `o` contains its output.
        # We want it to be highlighted as a code output, so we append `~` at the
        # end of every non-empty line.
        if reg_to_use == 'o'
            && &filetype == 'markdown'
            && synID('.', col('.'), true)->synIDattr('name')
                =~ '^markdown.*CodeBlock$'
            getreg('o', true, true)
                ->map((_, v: string) => v != '' ? v .. '~' : v)
                ->setreg('o', 'l')
        endif

        # force the type of the register to be linewise
        getreginfo(reg_to_use)->extend({regtype: 'l'})->setreg(reg_to_use)

        try
            # put the register (`where` can be `]p` or `[p`)
            execute 'normal! "' .. reg_to_use .. cnt .. where .. how_to_indent
        # could fail if the buffer is unmodifiable
        catch /^Vim\%((\a\+)\)\=:E21:/
            lg.Catch()
        endtry

        # make sure the cursor is on the first non-whitespace
        search('\S', 'cW')
    finally
        setreg(reg_to_use, reg_save)
    endtry
    return ''
enddef

export def PutLine(below: bool, type = ''): string #{{{2
    if type == ''
        &operatorfunc = function(PutLine, [below])
        return 'g@l'
    endif

    var cnt: number = v:count1
    var line: string = getline('.')
    var cml: string = &l:commentstring->matchstr('\S*\ze\s*%s')->escape('\') .. '\m'

    var is_first_line_in_diagram: bool = line =~ '^\s*\%(' .. cml .. '\)\=├[─┐┘ ├]*$'
    var is_in_diagram: bool = line =~ '^\s*\%(' .. cml .. '\)\=\s*[│┌┐└┘├┤]'
    if is_first_line_in_diagram
        if below && line =~ '┐' || !below && line =~ '┘'
            line = ''
        else
            line = line
                    ->substitute('[^├]', ' ', 'g')
                    ->substitute('├', '│', 'g')
        endif
    elseif is_in_diagram
        line = line->substitute('\%([│┌┐└┘├┤].*\)\@<=[^│┌┐└┘├┤]', ' ', 'g')
        var Rep: func = (m: list<string>): string =>
               m[0] == '└' && below
            || m[0] == '┌' && !below
            ? '' : '│'
        line = line
            ->substitute('[└┌]', Rep, 'g')
            ->substitute('[┘┐]', ' ', 'g')
    else
        line = ''
    endif
    line = line->substitute('\s*$', '', '')
    var lines: list<string> = repeat([line], cnt)

    var lnum: number = line('.') + (below ? 0 : -1)
    # if we're in a closed fold, we don't want to simply add an empty line, we
    # want to create a visual separation between folds
    var fold_begin: number = foldclosed('.')
    var fold_end: number = foldclosedend('.')
    var is_in_closed_fold: bool = fold_begin >= 0

    if is_in_closed_fold && &filetype == 'markdown'
        # for a markdown buffer, where we  use a foldexpr, a visual separation
        # means an empty fold
        var prefix: string = getline(fold_begin)->matchstr('^#\+')
        # fold marked by a line starting with `#`
        if prefix =~ '#'
            if prefix == '#'
                prefix = '##'
            endif
            lines = repeat([prefix], cnt)
        # fold marked by a line starting with `===` or `---`
        elseif getline(fold_begin + 1)->match('^===\|^---') != -1
            lines = repeat(['---', '---'], cnt)
        endif
        lnum = below ? fold_end : fold_begin - 1
    endif

    try
        append(lnum, lines)
        # By default, we set the foldmethod to `manual`, because `expr` can be
        # much more expensive.  As a consequence,  when you insert a new fold,
        # it's not immediately detected as  such; not until you've temporarily
        # switched to `expr`.  That's what `LazyFold.Compute()` does.
        if &filetype == 'markdown' && lines[0] =~ '^[#=-]'
            silent! LazyFold.Compute()
        endif
    # could fail if the buffer is unmodifiable
    catch /^Vim\%((\a\+)\)\=:E21:/
        lg.Catch()
    endtry
    return ''
enddef

export def PutLinesAround(type = ''): string #{{{2
    if type == ''
        &operatorfunc = PutLinesAround
        return 'g@l'
    endif

    # above
    PutLine(false, type)

    # below
    PutLine(true, type)

    return ''
enddef

export def RuleMotion(below = true) #{{{2
    var cnt: number = v:count1
    var cml: string = &l:commentstring->matchstr('\S*\ze\s*%s')->escape('\') .. '\m'
    var flags: string = (below ? '' : 'b') .. 'W'
    var pat: string
    var stopline: number
    for _ in range(1, cnt)
        if &commentstring == '' || &filetype == 'markdown'
            pat = '^---$'
            stopline = search('^#', flags .. 'n')
        else
            pat = '^\s*' .. cml .. ' ---$'
            var foldmarker: string = '\%(' .. split(&l:foldmarker, ',')->join('\|') .. '\)\d*'
            stopline = search('^\s*' .. cml .. '.*' .. foldmarker .. '$', flags .. 'n')
        endif
        var lnum: number = search(pat, flags .. 'n')
        if stopline == 0 || (below && lnum < stopline || !below && lnum > stopline)
            search(pat, flags, stopline)
        endif
    endfor
enddef

export def RulePut(below = true) #{{{2
    append('.', ["\x01", '---', "\x01", "\x01"])
    if &filetype != 'markdown'
        :.+1,.+4 CommentToggle
    endif
    silent keepjumps keeppatterns :.+1,.+4 substitute/\s*\%x01$//e
    if &filetype != 'markdown'
        execute 'silent normal! V3k=3jA '
    endif
    if !below
        :-4 move .
        execute 'normal! ' .. (&filetype == 'markdown' ? '' : '==') .. 'k'
    endif
    startinsert!
enddef
#}}}1
# Util {{{1
def Error(msg: string) #{{{2
    echohl ErrorMsg
    echomsg msg
    echohl NONE
enddef

def ReadDir(dir: string): list<string> #{{{2
    if dir =~ '/\%(build\|__pycache__\)$'
        return []
    endif

    try
        return dir
            ->readdir()
            ->map((_, entry: string) => $'{dir == '/' ? '' : dir}/{entry}')
    # Can't open file ...
    catch /^Vim\%((\a\+)\)\=:E484:/
        return []
    endtry
    return []
enddef
