vim9script

import 'lg.vim'
import 'lg/window.vim'

# Operators {{{1
export def OpReplaceWithoutYank(reg = '', type = ''): string #{{{2
    if type == ''
        &operatorfunc = function(lg.Opfunc, [{
            # A third-party text-object might not know that it should pass `v:register` to the operator function:
            # https://github.com/wellle/targets.vim/issues/253
            # TODO: You won't need to pass `v:register`, once this issue gets fixed:
            # https://github.com/vim/vim/issues/6374
            funcname: function(OpReplaceWithoutYank, [v:register]),
            # we don't need to yank the text-object,
            # and don't want `v:register` nor `""` to mutate
            yank: false,
        }])
        return 'g@'
    endif

    # Need to save/restore:{{{
    #
    #    - `reg` in case we make it mutate with the next `setreg()`
    #    - `"-` and the numbered registers, because they will mutate when the selection is replaced
    #}}}
    var save_regs: dict<any>
    var regs: list<string> = [reg, '-']
        + range(10)->map((_, v: any): string => string(v))
    for regname: string in regs
        save_regs[regname] = getreginfo(regname)
    endfor

    if type == 'line'
        execute $'keepjumps normal! ''[V'']"{reg}P'
        normal! gv=
    elseif type == 'block'
        execute $'keepjumps normal! `[\<C-V>`]"{reg}P'
    elseif type == 'char'
        HandleChar(reg)
    endif

    for [regname: string, value: dict<any>] in save_regs->items()
        setreg(regname, value)
    endfor

    return ''
enddef

def HandleChar(reg: string)
    var reginfo: dict<any> = getreginfo(reg)
    var contents: list<string> = get(reginfo, 'regcontents', [])
    if get(reginfo, 'regtype', '') == 'V' && !empty(contents)
        # Tweak linewise register so that it better fits inside a characterwise text.{{{
        #
        # That is:
        #
        #    - reset its type to characterwise
        #    - trim the leading whitespace in front of the first line
        #    - trim the trailing whitespace at the end of the last line
        #
        # Consider this text:
        #
        #     a
        #     b c d
        #
        # If you press `dd` to delete the  `a` line, then press `drl` on the
        # `c` character, you get:
        #
        #     b a d
        #
        # If you didn't tweak the register, you would get:
        #
        #        b
        #        a
        #     d
        #
        # Which is probably not what you want.
        #}}}
        # trim whitespace surrounding the text
        contents[0] = contents[0]->substitute('^\s*', '', '')
        contents[-1] = contents[-1]->substitute('\s*$', '', '')
        # and reset the type to characterwise
        reginfo
            ->extend({regcontents: contents, regtype: 'c'})
            ->setreg(reg)
    endif

    try
        execute $'keepjumps normal! `[v`]"{reg}P'
    catch
        lg.Catch()
    endtry
enddef

export def OpTrimWs(type = ''): string #{{{2
    if type == ''
        &operatorfunc = OpTrimWs
        return 'g@'
    endif
    if &l:binary || &filetype == 'diff'
        return ''
    endif
    var lnum1: number = line("'[")
    var lnum2: number = line("']")
    var range: string = $':{lnum1},{lnum2}'
    execute $'{range} TrimWhitespace'
    return ''
enddef

export def OpYank( #{{{2
    what: string,
    register = '',
    type = ''
): string

    if type == ''
        if @/ =~ '\\n' && @/ =~ '\\zs'
            var warning: string = 'The pattern contains `\n` and `\zs`.  The result might not be what you expect.  Try to use `\@<=`.'
            echowindow warning
            # Example:{{{
            #
            #     :0 put =['aaa', 'bbbccc', '']->repeat(3)
            #     :let @/ = 'aaa\nbbb\zsccc$'
            #     # press:  ymiE
            #
            #     # expected:
            #     bbbccc
            #     bbbccc
            #     bbbccc
            #
            #     # actual:
            #     aaa
            #     aaa
            #     aaa
            #
            # That's because `:global` ignores `\zs`:
            #
            #     :global;aaa\nbbb\zsccc$;yank Z
            #
            # Try to use `\@<=` instead:
            #
            #     :let @/ = '\%(aaa\nbbb\)\@<=ccc$'
            #                ^^^        ^----^
            #
            # Note that it might not work either because Vim cannot backtrack too far away.
            #
            # See: https://github.com/vim/vim/issues/3695#issuecomment-1445165338
            #}}}
        endif

        &operatorfunc = function(OpYank, [what, v:register])
        return 'g@'
    endif
    var mods: string = 'keepjumps keeppatterns'
    var lnum1: number = line("'[")
    var lnum2: number = line("']")
    var range: string = $':{lnum1},{lnum2}'

    var cmd: string = what == 'global//' || what == 'comments'
        ? 'global'
        : 'vglobal'
    var cml: string = $'\C\V{&l:commentstring->matchstr('\S*\ze\s*%s')->escape('\')}'
    var pat: string = what == 'code' || what == 'comments'
        ?     $'^\s*{cml}'
        :     @/

    var z_save: dict<any> = getreginfo('z')
    var yanked: list<string>
    try
        setreg('z', {})
        execute $'{mods}{range}{cmd};{escape(pat, ';')};yank Z'
        yanked = getreginfo('z')->get('regcontents', [])
    finally
        setreg('z', z_save)
        # emulate what Vim does with a  builtin operator; the cursor ends at the
        # *start* of the text object
        cursor(range->matchstr('\d\+')->str2nr(), 1)
    endtry

    # if `:v` was used, and the pattern matched everywhere, nothing was yanked
    if len(yanked) == 0
        return ''
    endif

    # the first  time we've  appended a  match to the  `z` register,  it has
    # appended a newline; we *never* want it; remove it
    if yanked[0] == ''
        yanked->remove(0)
    endif

    # remove *all* empty lines in some other cases
    if what == 'vglobal//' || what == 'code'
        yanked->filter((_, v: string): bool => v !~ '^\s*$')
    endif

    setreg(register, yanked, 'l')
    return ''
enddef
# }}}1
# Text-Objects {{{1
export def TextObjHorizontalRule(adverb: string) #{{{2
# TODO: Consider moving all or most of your custom text-objects into a dedicated (libary?) plugin.
    var start: string
    var end: string
    var comment: string
    if &filetype == 'markdown'
        start = '^\%(---\|#.*\)\n\zs\|\%^'
        end = '\n\@1<=---$\|\n#\|\%$'
    else
        if &filetype == 'vim'
            comment = '["#]'
        else
            var cml: string = &l:commentstring->matchstr('\S*\ze\s*%s')
            comment = $'\V{cml->escape('\')}\m'
        endif
        var foldmarker: string = $'\%({&l:foldmarker->split(',')->join('\|')}\)\d*'
        start =
            # just below a `---` line, or just below the start of a fold
            $'^\s*{comment}\s*\%(---\|.*{foldmarker}\)\n\zs'
            # or the start of a multiline comment
            .. $'\|^\%(\s*{comment}\)\@!.*\n\zs\s*{comment}'
            .. '\|\%^'
        end =
            # a `---` line, or the end of a fold
            $'\s*{comment}\s*\%(---\|.*{foldmarker}\)$'
            # or the end of a multiline comment
            .. $'\|^\s*{comment}.*\n\%(\s*{comment}\)\@!'
    endif
    search(start, 'bcW')
    execute $'normal! o{mode() != 'V' ? 'V' : ''}'
    search($'\n\@1<={end}', 'cW')

    if adverb == 'around'
        # special case: if we're in the last `---` section of a fold,
        # grab the `---` above
        if &filetype == 'markdown' && (getline(line('.') + 1) =~ '^#' || line('.') == line('$'))
        || &filetype != 'markdown' && (getline('.') !~ end)
            normal! oko
        endif
        return
    endif

    if &filetype == 'markdown'
        if getline('.') =~ '^---$\|^#'
            normal! k
        endif
    else
        if getline('.') =~ $'^\s*{comment}\s*---$'
            normal! k
        endif
    endif
enddef

export def TextObjBlock(block_type: string, inside: bool) #{{{2
    if TEXT_OBJ_BLOCK_PATTERNS
            ->get(&filetype, {})
            ->get(block_type, {}) == {}
        return
    endif

    var start_pattern: string = TEXT_OBJ_BLOCK_PATTERNS[&filetype][block_type]['start']
    var end_pattern: string = TEXT_OBJ_BLOCK_PATTERNS[&filetype][block_type]['end']
    start_pattern = $'^\C\s*\%({start_pattern}\)'
    end_pattern = $'\C\%({end_pattern}\)\s*$'

    # let's find the start and end of the block
    var curpos: list<number> = getcurpos()
    var curlnum: number = curpos[1]
    var curindent: number = indent(curlnum)
    var start: number = curlnum + 1
    var end: number
    var last: number = line('$')
    # this loop is meant to handle the case where there is a nested function before
    while !(start <= curlnum && curlnum <= end)
        --start
        while start > 0 && getline(start) !~ start_pattern
            --start
        endwhile

        if start == 0
            setpos('.', curpos)
            return
        endif

        var start_indent: number = indent(start)
        end = start + 1
        if &filetype == 'python'
            # We can't look  directly for the last line of  the block, because
            # it doesn't  match any  particular pattern.  Instead,  let's look
            # for the first line which we know to be *after* the block.
            while end <= last
                    && (
                        # a line in a Python block must have a greater indentation than its start
                        indent(end) > start_indent
                        # unless it's an empty line
                        || getline(end) !~ '\S'
                        # or unless it's in the middle of a multiline string
                        || synstack(end, 1)
                        ->indexof((_, id: number): bool => id->synIDattr('name') =~ '\cstring') >= 0
                    )
                ++end
            endwhile
            # we've found  the first line *after*  the block, but we  want its
            # last line; fix that off-by-one error
            --end
        else
            # we're looking for the last line of the block
            while end <= last
                    && (indent(end) != start_indent || getline(end) !~ end_pattern)
                ++end
            endwhile
        endif
    endwhile

    # if we only want the inside of a block, discard its header and footer
    if inside
        # If the  header is split  on multiple  lines, find the  opening paren
        # which starts  the arguments,  then jump to  the closing  paren which
        # ends them.
        if &filetype == 'fish'
            ++start
            --end
        else
            execute $'normal! {start}Gf(%'
            start = line('.') + 1

            if &filetype == 'python'
                # there  might be  multiple  empty lines  after the  function;
                # discard them all
                while getline(end) !~ '\S'
                    --end
                endwhile
            else
                --end
            endif
        endif
    endif

    # happens if we ask for the inside of an empty function
    if end < start
        setpos('.', curpos)
        return
    endif

    # `0`: make  sure the  cursor ends  up in  a deterministic  and consistent
    # position.  Without, after `=if`, the cursor might not be where you would
    # expect (compare with `yif`).
    execute $'normal! 0{start}GV{end}G'
enddef

const TEXT_OBJ_BLOCK_PATTERNS: dict<dict<dict<string>>> = {
    awk: {
        function: {
            start: 'function\s\+\w\+(',
            end: '}',
        },
    },
    bash: {
        function: {
            start: 'function\s\+\w',
            end: '}',
        },
        # bash does  not support  classes, but  it does  provide `case`/`esac`
        # blocks which in practice can be quite long.
        class: {
            start: 'case\s',
            end: 'esac',
        },
    },
    c: {
        function: {
            start: '{',
            end: '}',
        },
    },
    fish: {
        function: {
            start: '^{',
            end: '^}',
        },
    },
    python: {
        function: {
            start: 'def\s\+\w',
            end: '',
        },
        class: {
            start: 'class\s\+\w',
            end: '',
        },
    },
    vim: {
        function: {
            start: '\%(fu\%[nction](\@!\|\%(export\s\+\)\=def\)\>!\=\s\+\w',
            end: 'endfu\%[nction]\|enddef',
        },
        class: {
            start: 'class\s\+\w',
            end: 'endclass',
        },
    },
}
# }}}1

# BoxCreate / BoxDestroy {{{1

# TODO:
# We could improve these functions by reading:
# https://github.com/vimwiki/vimwiki/blob/dev/autoload/vimwiki/tbl.vim
#
# In particular, it could update an existing table.
#
# ---
#
# Also, we should improve it to generate this kind of table:
#
#    ┌───────────────────┬─────────────────────────────────────────────────┐
#    │                   │                    login                        │
#    │                   ├─────────────────────────────────┬───────────────┤
#    │                   │ yes                             │ no            │
#    ├─────────────┬─────┼─────────────────────────────────┼───────────────┤
#    │ interactive │ yes │ zshenv  zprofile  zshrc  zlogin │ zshenv  zshrc │
#    │             ├─────┼─────────────────────────────────┼───────────────┤
#    │             │ no  │ zshenv  zprofile         zlogin │ zshenv        │
#    └─────────────┴─────┴─────────────────────────────────┴───────────────┘
#
# The peculiarity here, is the variable number of cells per line (2 on the first
# one, 3 on the second one, 4 on the last ones).
export def BoxCreate(type = ''): string
    if type == ''
        &operatorfunc = BoxCreate
        return 'g@'
    endif

    # draw `|` on the left of the paragraph
    execute "normal! _vip\<C-V>^I|"
    # draw `|` on the right of the paragraph
    normal! gv$A|

    # align all (*) the pipe characters (`|`) inside the current paragraph
    silent :'[,'] EasyAlign *|

    # If we wanted to center the text inside each cell, we would have to add
    # hit `CR CR` after `gaip`:
    #
    #     execute "silent normal gaip\<CR>\<CR>*|"

    # Capture all the virtual column  positions in the current line matching
    # a `|` character:
    var vcol_pos: list<number>
    var cnt: number = 0
    var lnum: number = line('.')
    var line: string = getline('.')
    for char: string in line
        if char == '|'
            ++cnt
            # We don't need  to do anything special to get  the index of the
            # first cell, because `|` only occupies 1 cell.
            # Also,  `+ 1`  is necessary  because `virtcol()`  and `match()`
            # don't start indexing from the  same number (1 for `virtcol()`,
            # 0 for `match()`).
            vcol_pos->add(virtcol([lnum, line->match('|', 0, cnt) + 1]))
        endif
    endfor

    if empty(vcol_pos)
        return ''
    endif

    # Draw the upper border of the box '┌────┐':
    BoxCreateBorder('top', vcol_pos)

    # Draw the lower border of the box '└────┘':
    BoxCreateBorder('bottom', vcol_pos)

    # Replace the remaining `|` with `│`:
    var firstlnum: number = line("'{") + 2
    var lastlnum: number = line("'}") - 2
    for l: number in range(firstlnum, lastlnum)
        for c: number in vcol_pos
            execute $'normal! {l}G{c}|r│'
        endfor
    endfor

    BoxCreateSeparations()
    return ''
enddef

def BoxCreateBorder(where: string, vcol_pos: list<number>)
    if where == 'top'
        # duplicate first line in the box
        normal! '{+yyP
        # replace all characters with `─`
        substitute/^\s*\zs.*/\=BoxCreateBorderRep()/
        # draw corners
        execute $'normal! {vcol_pos[0]}|r┌{vcol_pos[-1]}|r┐'
    else
        # duplicate the `┌────┐` border below the box
        copy '}-
        # draw corners
        execute $'normal! {vcol_pos[0]}|r└{vcol_pos[-1]}|r┘'
    endif

    # draw the '┬' or '┴' characters:
    for pos: number in vcol_pos[1 : -2]
        execute $'normal! {pos}|r{where == 'top' ? '┬' : '┴'}'
    endfor
enddef

def BoxCreateBorderRep(): string
    var col: number = virtcol('.', true)[0] - 1
    var cnt: number = submatch(0)->strdisplaywidth(col)
    return repeat('─', cnt)
enddef

def BoxCreateSeparations()
    # Create a separation line, such as:
    #
    #     |    |    |    |
    #
    # ... useful to make our table more readable.
    normal! '{++yyp
    getline('.')->substitute('[^│┼]', ' ', 'g')->setline('.')

    # Delete it in the `s` (s for space) register, so that it's stored inside
    # default register and we can paste it wherever we want.
    d s

    # Create a separation line, such as:
    #
    #     ├────┼────┼────┤
    #
    # ... and store it inside `x` register.
    # So that we can paste it wherever we want.
    var line: string = (line("'{") + 1)
        ->getline()
        ->substitute('\S', '├', '')
        ->substitute('.*\zs\S', '┤', '')
        ->tr('┬', '┼')

    # Make the contents of the register linewise, so we don't need to hit
    # `"x]p`, but simply `"xp`.
    setreg('x', [line], 'l')
enddef

export def BoxDestroy(type = ''): string
    if type == ''
        &operatorfunc = BoxDestroy
        return 'g@'
    endif

    var lnum1: number = line("'[")
    var lnum2: number = line("']")
    var range: string = $':{lnum1},{lnum2}'
    # remove box (except pretty bars: │)
    execute $'silent {range}substitute/[─┴┬├┤┼└┘┐┌]//ge'

    # replace pretty bars with regular bars
    # necessary, because we will need them to align the contents of the
    # paragraph later
    execute $'silent {range}substitute/│/|/ge'

    # remove the bars at the beginning and at the end of the lines
    # we don't want them, because they would mess up the creation of a box
    # later
    execute $'silent {range}substitute/|//e'
    execute $'silent {range}substitute/.*\zs|//e'

    execute $'silent! {range}TrimWhitespace'
    # remove empty lines
    execute $'silent {range}-1 global/^\s*$/delete _'

    append(lnum1 - 1, [''])

    # position the cursor on the upper left corner of the paragraph
    execute $'normal! {lnum1}Gj_'
    return ''
enddef

export def DeleteMatchingLines(to_delete: string, reverse = false) #{{{1
    if !&l:modifiable
        echohl ErrorMsg
        # useful in a terminal buffer running a non-finished interactive shell
        echo 'cannot delete lines in a non-modifiable buffer'
        echohl NONE
        return
    endif
    # TODO: Bail out if we try to delete lines matching the last search, and the
    # latter is a multi line pattern including `\zs` after a newline:
    # https://github.com/vim/vim/issues/3695#issuecomment-1459166366

    var register: string = v:register
    var view: dict<number> = winsaveview()
    var foldenable_save: bool = &l:foldenable
    &l:foldenable = false

    # Purpose:{{{
    #
    # The deletions will leave the cursor on  the line below the last line where
    # a match was found.   This line may be far away  from our current position.
    # This  is distracting;  let's try  to stay  as close  as possible  from our
    # current position.
    #
    # To achieve this goal, we need to find the nearest character which won't be
    # deleted, and set a mark on it.
    #}}}
    var pos: list<number> = getcurpos()
    var global: string = reverse ? 'v' : 'g'
    var cml: string
    if &filetype == 'vim'
        cml = b:current_syntax == 'vim9' ? '#' : '"'
    else
        cml = $'\V{&l:commentstring->matchstr('\S*\ze\s*%s')->escape('\')}\m'
    endif
    var to_search: dict<list<string>> = {
        empty: ['^\s*$', '^'],
        comments: [
            $'^\s*{cml}'
                # preserve start of folds when deleting comments
                .. $'\%(.*{&l:foldmarker->split(',')->get(0, '')}\d\+$\)\@!',
            $'^\%(\s*{cml}\)\@!'
            ],
        search: [@/, $'^\%(.*{@/}\m\)\@!'],
    }
    var wont_be_deleted: string = to_search[to_delete][global == 'g' ? 1 : 0]
    # necessary if the pattern matches on the current line, but the match starts
    # before our current position
    execute $'normal! {pos[1] == 1 ? '1|' : 'k$'}'
    search(wont_be_deleted, pos[1] == 1 ? 'c' : '')
    # if the match is on our original line, restore the column position
    if line('.') == pos[1]
        setpos('.', pos)
    endif
    normal! m'
    setpos('.', pos)

    var mods: string = 'silent! keepjumps keeppatterns '
    var range: string
    var lnum1: number
    var lnum2: number
    if mode() =~ "^[vV\<C-V>]$"
        var coords: dict<list<number>> = lg.GetSelectionCoords()
        lnum1 = coords.start[0]
        lnum2 = coords.end[0]
        range = $':{lnum1},{lnum2}'
    else
        range = ':%'
    endif
    # if  we've  specified an  alphabetical  register,  we  want it  to  contain
    # whatever is going to be deleted
    if register =~ '[a-z]'
        # clear the register, so that it ends up with only relevant data
        setreg(register, {})
        register = register->toupper()
    else
        register = '_'
    endif
    var pat: string = to_search[to_delete][0]
    if to_delete == 'comments'
        for [lnum: number, line: string]
                in (range == ':%' ? getline(1, '$')->items() : getline(lnum1, lnum2)->items())
            var col: number = line->match('\S')
            var is_commented: bool = synstack(lnum + 1, col + 1)
                ->indexof((_, id: number): bool => id->synIDattr('name') =~ '\ccomment') >= 0
            if reverse && !is_commented
                    || !reverse && is_commented
                var new_contents: list<string> = getreginfo(register)
                    ->get('regcontents')
                    ->add(line)
                setreg(register, {regcontents: new_contents})
                # It would be tricky to delete the line right away.{{{
                #
                # We would need to iterate over the lines in their reverse order
                # to support block comments like in Lua.
                # Also, note  that when you delete  the first or last  line of a
                # block comment, you change the syntax of the lines below.
                #}}}
                execute $':{lnum + 1} substitute/$/\="\x01"/'
            endif
        endfor
        execute $'{mods}global /\%x01$/ delete _'
    else
        # Don't use `/` as a delimiter.{{{
        #
        # It's tricky.
        #
        # Suppose you've just searched for a pattern containing a slash with a
        # `/` command.  Vim  will have automatically escaped the  slash in the
        # search register.   So, you should not  escape it a second  time with
        # `escape()`.
        #
        # But suppose  `pat` comes from sth  else, like a `?`  search; in that
        # case, there's no reason to believe that Vim has already escaped `/`,
        # and you do need to do it yourself.
        #
        # Let's avoid this conundrum altogether, by using a delimiter which is
        # not `/` nor `?`.
        #}}}
        execute $'{mods}{range}{global};{escape(pat, ';')};delete {register}'
    endif

    # bang to suppress `:help E32`
    silent! update
    &l:foldenable = foldenable_save
    winrestview(view)
    # `silent!` because if the pattern was so broad that all the lines were removed,
    # the original line doesn't exist anymore, and the `'` mark is invalid
    silent! normal! `'zv
    if mode() =~ "^[vV\<C-V>]$"
        feedkeys("\<C-\>\<C-N>", 'n')
    endif
enddef

export def EditReadme() #{{{1
    # Special Case: terminal buffer used to parse ANSI escape codes
    if &buftype == 'terminal'
            && filereadable(g:ParseAnsiEscapeCodesFile)
        window.OpenOrFocus(g:ParseAnsiEscapeCodesFile, 'split')
        return
    endif

    var curdir: string = expand('%:p:h')

    if curdir =~ '/navi/snippets$'
        var fname: string = $'{curdir}/{expand('%:p:t:r')}/README.md'
        if fname->filereadable()
            window.OpenOrFocus(fname, 'split')
        else
            fname = fname->fnamemodify(':h')
            if fname->isdirectory()
                window.OpenOrFocus(fname, 'split')
                return
            endif
            echo 'Could not find a README'
        endif
        return
    endif

    if curdir == $HOME
        # If we're in `~/.mailcap`, we want to read `~/.README/mailcap.md`.
        var fname: string = expand('%:p:t:r')
            ->trim('.', 1)
            ->printf($'{$HOME}/.README/%s.md')
        if fname->filereadable()
            window.OpenOrFocus(fname, 'split')
            return
        endif
        window.OpenOrFocus('~/.README/', 'split')
        return
    endif

    var dirs: list<string> = [curdir]
    if curdir =~ $'^{$HOME}/\.config/\S\+/'
        var pgm: string = curdir
            ->matchstr($'^{$HOME}/\.config/\zs[^ /]\+\ze/')
        dirs->add($'{$HOME}/.config/{pgm}')
    endif

    if exists('b:repo_root')
        dirs->add(b:repo_root)
    endif

    # sanitize whatever list our heuristics  have given us, for `readdir()` to
    # succeed
    dirs
        ->filter((_, d: string): bool => d->isdirectory())
        ->sort()
        ->uniq()

    var kwd: string = '\%([_.]\=README\|CONTENTS\)'
    var pat: string = $'^\c{kwd}\%(\..*\)\=$'
    var READMEs: list<string>
    for d: string in dirs
        READMEs += d
            ->readdir((fname: string): bool => fname =~ pat, {sort: 'none'})
            ->map((_, fname: string) => $'{d}/{fname}')
            ->filter((_, fname: string): bool => fname->filereadable() || fname->isdirectory())
    endfor

    if READMEs->empty()
        echo 'Could not find a README'
        return
    endif

    window.OpenOrFocus(READMEs, 'split')
enddef

export def TogglePunctuation() #{{{1
    if pumvisible()
        feedkeys("\<C-P>", 'in')
        return
    endif

    #                  cursor
    #                  v
    #     For example, |
    #     ⇒
    #     For example: |
    #     ⇒
    #     For example, |
    #     ...
    var line: string = getline('.')
    var punctuation: list<any> = line
        ->matchstrpos('[[:punct:]]\s*\%.c')

    if punctuation == []
        return
    endif

    var new_line: string
    if punctuation[0] =~ '^[,:]'
        new_line = line
            ->substitute($'.*\zs\%{punctuation[1] + 1}c.',
            (m: list<string>): string => ({[':']: ',', [',']: ':'}[m[0]]), '')
        setline('.', new_line)
    endif
enddef

export def Cfg(pgm: string) #{{{1
    # check whether we've got some stale paths in `CFGFILES`
    if !did_check_cfg
        for [_, files: list<string>] in CFGFILES->items()
            for file: string in files
                if !file->expand()->filereadable()
                        && !file->expand()->isdirectory()
                    var warning: list<string> =<< trim eval END
                    "{file}" does not exist, but you refer to it in CFGFILES
                    If you no longer use some program, remove it from CFGFILES, and from there too:
                    {$HOME}/.config/fish/completions/cfg.fish
                    END
                    for line: string in warning
                        echowindow $'Cfg: {line}'
                    endfor
                endif
            endfor
        endfor
        did_check_cfg = true
    endif

    # check whether `:Cfg` supports the given program
    if !CFGFILES->has_key(pgm)
        var errormsg: string = $'{pgm} is not supported'
        if has('vim_starting')
            execute $'silent !echo {errormsg}'
            cquit
        else
            echowindow $'Cfg: {errormsg}'
        endif
        return
    endif

    # if the given program is systemd, compute and cache its config directories now
    if pgm == 'systemd' && CFGFILES.systemd == []
        var shell_cmd: string = 'systemctl show --property=UnitPath --value --no-pager'
        shell_cmd ..= $'; {shell_cmd->substitute('^systemctl', 'systemctl --user', '')}'
        silent CFGFILES.systemd = system(shell_cmd)
            ->split()
            ->map((_, dir: string) => dir->resolve())
            ->sort()
            ->uniq()
            ->filter((_, dir: string): bool => dir->isdirectory() && dir->readdir() != [])
    endif

    # split the window if necessary
    var has_no_name: bool = expand('%:p') == ''
    var is_empty: bool = (line('$') + 1)->line2byte() <= 2
    if !(has_no_name && is_empty)
        new
    endif

    # set the arglist with the config files
    var paths: list<string> = CFGFILES[pgm]
        ->copy()
        ->map((_, path: string) => path->expand())
        ->filter((_, path: string): bool => path->filereadable() || path->isdirectory())
    if paths->empty()
        echomsg 'Cfg: could not find any config file/directory'
    endif
    execute $'arglocal {paths->join()}'

    # for systemd, open annotations too
    if pgm == 'systemd'
        var annotations: string = $'{$HOME}/Wiki/systemd/directories.md'
        execute $'aboveleft split {annotations}'
        wincmd p
    endif
enddef

export def CfgComplete(_, _, _): string
    return CFGFILES->keys()->sort()->join("\n")
enddef

var did_check_cfg: bool

var CFGFILES: dict<list<string>> = {
    apt: [
        '/etc/apt/apt.conf.d/99zz-local',
        '~/.config/etc/apt/apt.conf.d/99zz-local',
    ],
    autostart: [
        '~/bin/user-session',
        '~/.config/autostart/',
        '/etc/xdg/autostart/'
    ],
    bat: ['~/.config/bat/config'],
    bash: ['~/.bashrc', '~/.bashrc_local'],
    cargo: ['~/.cargo/config.toml'],
    conky: [
        '~/.config/conky/system.lua',
        '~/.config/conky/system_rings.lua',
        '~/.config/conky/time.lua'
    ],
    cmus: ['~/.config/cmus/rc'],
    ctags: ['~/.config/ctags/*'],
    feh: ['~/.config/feh/keys'],
    fish: ['~/.config/fish/config.fish', '~/.config/fish/conf.d/environment.fish'],
    fzf: ['~/.config/fish/plugins/fzf/conf.d/fzf.fish'],
    gdb: ['~/.config/gdb/gdbearlyinit', '~/.config/gdb/gdbinit'],
    git: ['~/.config/git/config', '~/.cvsignore'],
    htop: ['~/.config/htop/htoprc'],
    info: ['~/.infokey'],
    intersubs: [
        '~/.config/mpv/scripts/interSubs.lua',
        '~/.config/mpv/scripts/interSubs.disable/interSubs.py',
        '~/.config/mpv/scripts/interSubs.disable/interSubs_config.py',
        '~/.config/mpv/scripts/interSubs.disable/README.md'
    ],
    kernel: ['/etc/sysctl.d/'],
    keyd: ['/etc/keyd/default.conf', '~/.config/etc/keyd/default.conf'],
    kitty: ['~/.config/kitty/kitty.conf'],
    latexmk: ['~/.config/latexmk/latexmkrc'],
    less: ['~/.config/less/keys'],
    ls: ['~/.config/dircolors/config'],
    mpv: ['~/.config/mpv/input.conf', '~/.config/mpv/mpv.conf'],
    navi: ['~/.config/navi/config.yaml', '~/.config/navi/snippets/'],
    ncdu: ['~/.config/ncdu/config'],
    newsboat: [
        '~/.config/newsboat/config',
        '~/.config/newsboat/urls',
        '~/.config/newsboat/book_podcast'
    ],
    nnn: ['~/.config/nnn/'],
    pam: ['/etc/pam.conf', '/etc/pam.d/'],
    podman: [
        # `containers.conf`  in `/usr/share`,  `/etc`, `~/.config`  are merged
        # together; in case of conflict, the last one wins.
        '~/.config/containers/containers.conf',  # ONLY for rootless containers
        '/usr/share/containers/containers.conf',
        # entirely replaces `/etc/containers/registries.conf`
        '~/.config/containers/registries.conf',
    ],
    pudb: ['~/.config/pudb/theme.py'],
    pylint: ['~/.config/pylintrc'],
    radare2: ['~/.config/radare2/radare2rc'],
    readline: ['~/.config/inputrc'],
    redshift: ['~/.config/redshift.conf', '~/.config/redshift/hooks/'],
    s: ['~/.config/s/config'],
    shellcheck: ['~/.config/shellcheckrc'],
    ssh: [
        # user client config
        '~/.ssh/config',
        # all following files/directories are system-wide
        #
        # client config
        '/etc/ssh/ssh_config',
        # server config
        '/etc/ssh/sshd_config',
        # client config overrides (file extension must be `.conf`)
        '/etc/ssh/ssh_config.d/',
        # server config overrides (file extension must be `.conf`)
        '/etc/ssh/sshd_config.d/99-local.conf',
        # PAM module
        '/etc/pam.d/sshd',
    ],
    # too complex to set here; let's compute it later
    systemd: [],
    tig: ['~/.config/tigrc'],
    tmux: ['~/.config/tmux/tmux.conf'],
    trans: ['~/.config/translate-shell/init.trans'],
    urlscan: ['~/.config/urlscan/config.json'],
    vim: [$MYVIMRC],
    w3m: ['~/.w3m/keymap'],
    weechat: ['~/.config/weechat/config'],
    xfce-terminal: ['~/.config/xfce4/terminal/terminalrc'],
    xterm: ['~/.Xresources'],
    yt-dlp: ['~/.config/yt-dlp/config'],
    zathura: ['~/.config/zathura/zathurarc'],
}

export def DiffLines( #{{{1
    bang: bool,
    arg_lnum1: number,
    arg_lnum2: number,
    option: string
)
    if option == '-h' || option == '--help'
        var usage: list<string> =<< trim END
            :DiffLines lets you see and cycle through the differences between 2 lines

            usage:
                :5,10 DiffLines    diff between lines 5 and 10
                :DiffLines         diff between current line and next one
                :DiffLines!        clear the match

            The differences are in the location list (press [l, ]l, [L, ]L to visit them)
        END
        echo usage->join("\n")
        return
    endif

    if expand('%:p')->empty()
        echohl ErrorMsg
        # `:lvimgrep` fails in an unnamed buffer
        echomsg 'Save the buffer in a file'
        echohl None
        return
    endif

    if exists('w:xl_match')
        matchdelete(w:xl_match)
        unlet! w:xl_match
    endif

    if bang
        return
    endif

    # if `arg_lnum1 == arg_lnum2`, it means `:DiffLines` was called without a range
    var lnum1: number
    var lnum2: number
    if arg_lnum1 == arg_lnum2
        lnum1 = line('.')
        lnum2 = lnum1 + 1
    else
        lnum1 = arg_lnum1
        lnum2 = arg_lnum2
    endif
    if lnum1 > line('$') || lnum2 > line('$')
        echohl ErrorMsg
        echomsg $'line {[lnum1, lnum2]->max()} does not exist'
        echohl None
        return
    endif
    var line1: string = getline(lnum1)
    var line2: string = getline(lnum2)
    var chars1: list<string> = split(line1, '\zs')
    var chars2: list<string> = split(line2, '\zs')
    var min_chars: number = min([len(chars1), len(chars2)])

    # build a pattern matching the characters which are different
    var pat: string
    var col1: number
    var col2: number
    for i: number in range(min_chars)
        if chars1[i] != chars2[i]
            # FIXME: We need to write `c.` instead of just `c`.{{{
            #
            # Otherwise, we may have duplicate entries.
            # The problem seems to come from `:lvimgrep` and the `g` flag.
            #
            # MRE: This adds 2 duplicate entries in the location list instead of one:
            #
            #     :lvimgrep /\%1l\%2c/gj %
            #
            # This adds 2  duplicate entries in the location list,  3 in total
            # instead of two:
            #
            #     :lvimgrep /\%1l\%2c\|\%1l\%3c/gj %
            #
            # This adds 2 couple of duplicate  entries in the location list, 4
            # in total instead of two:
            #
            #     :lvimgrep /\%1l\%2c\|\%1l\%4c/gj %
            #
            # It seems each time a `%{digit}c` anchor matches the beginning of a group
            # of consecutive characters, it adds 2 duplicate entries instead of one.
            #}}}
            # Don't use `virtcol()` and `\%v`.{{{
            #
            # It wouldn't work as expected  if the lines contain literal control
            # characters, and more generally any multicell characters.
            #}}}
            col1 = byteidx(line1, i) + 1
            pat ..= $'\%{lnum1}l\%{col1}c.\|'
            col2 = byteidx(line2, i) + 1
            pat ..= $'\%{lnum2}l\%{col2}c.\|'
        endif
    endfor

    # if one of the lines is longer than the other, we have to add its end in the pattern
    if strlen(line1) > strlen(line2)
        # It's better to write `\%>123c.` than `\%123c.*`.{{{
        #
        # `\%>123c.` = any character after the 50th character.
        # This will add one entry in the loclist for *every* character.
        #
        # `\%123c.*` = the *whole* set of characters after the 123th.
        # This will add only *one* entry in the loclist.
        #}}}
        pat ..= $'\%{lnum1}l\%>{strlen(line2) + 1}c.\|'

    elseif strlen(line1) < strlen(line2)
        pat ..= $'\%{lnum2}l\%>{strlen(line1) + 1}c.\|'
    endif

    pat = pat->substitute('\\|$', '', '')

    # give the result
    if !empty(pat)
        # Why silent?{{{
        #
        # If the  lines are long,  `:lvimgrep` will  print a long  message which
        # will cause a hit-enter prompt:
        #
        #     (1 of 123): ...
        #}}}
        execute $'silent lvimgrep /{pat}/g %'
        w:xl_match = matchadd('SpellBad', pat, 0)
    else
        echohl WarningMsg
        echomsg 'Lines are identical'
        echohl None
    endif
enddef

export def DumpWiki(arg_url: string) #{{{1
    if arg_url == ''
        var usage =<< trim END
            usage:
                :DumpWiki <url>

            example:
                :DumpWiki https://github.com/junegunn/fzf
        END
        echo usage->join("\n")
        return
    endif

    # TODO: Regarding triple backticks.{{{
    #
    # Look at this page: https://github.com/ranger/ranger/wiki/Keybindings
    #
    # Some lines of code are surrounded by triple backticks:
    #
    #     ```map X chain shell vim -p ~/.config/ranger/rc.conf %rangerdir/config/rc.conf;
    #        source ~/.config/ranger/rc.conf```
    #
    # It's an error.
    # They should be surrounded by simple backticks.
    # AFAIK, triple backticks are for fenced code blocks.
    # For inline code, a single backtick is enough.
    #
    # More  importantly, these  wrong  triple backticks  are  recognized as  the
    # beginning of a fenced code block by our markdown syntax plugin.
    # As a result, the syntax of all the following lines will be wrong.
    #
    # After dumping a wiki in a buffer, give a warning about that.
    # Give the recommendation to manually inspect the syntax highlighting at the
    # end of the buffer.
    #}}}
    if arg_url[: 3] != 'http'
        return
    endif

    var x_save: list<number> = getpos("'x")
    var y_save: list<number> = getpos("'y")
    try
        # in the argument URL, we  sometimes write `/wiki` by accident; remove
        # it with `substitute()`
        var url: string = $'{arg_url->trim('/')->substitute('/wiki/\=$', '', '')}.wiki'
        dumpwiki_dir = tempname()->substitute('.*/\zs.\{-}', '', '')
        silent $'git clone {shellescape(url)} {dumpwiki_dir}'->system()
        var files: list<string> = dumpwiki_dir
            ->readdir((fname: string): bool => fname !~ '^\.'
            # `fname` could actually be a directory
            && $'{dumpwiki_dir}/{fname}'->filereadable())
        if empty(files)
            echohl ErrorMsg
            echomsg $'Could not find any wiki at:  {url}'
            echohl NONE
            return
        endif
        files->filter((_, v: string): bool => v !~ '\c_\=footer\%(\.md\)\=$')

        normal! mx
        append('.', files + [''])
        cursor(line('.') + 2 * (len(files) + 1), 1)
        normal! my

        silent keepjumps keeppatterns :'x+1,'y-1 substitute/^/# /
        silent keepjumps keeppatterns :'x+1,'y-1 global/^./execute $'keepalt read {dumpwiki_dir}/{getline('.')[2 :]}'
        silent! keepjumps keeppatterns :'x+1,'y-1 global/^=\+\s*$/delete _
            | (line('.') - 1)->getline()->substitute('^', '## ', '')->setline(line('.') - 1)
        silent! keepjumps keeppatterns :'x+1,'y-1 global/^-\+\s*$/delete _
            | (line('.') - 1)->getline()->substitute('^', '### ', '')->setline(line('.') - 1)
        silent keepjumps keeppatterns :'x+1,'y-1 substitute/^#.\{-}\n\zs\s*\n\ze##//

        silent keepjumps keeppatterns :'x+1,'y-1 global/^#\%(#\)\@!/append(line('.') - 1, '#')

        # Don't conflate a comment inside a fenced code block as the start of a fold.
        set filetype=markdown
        execute 'FixFormatting'

        if &buftype == '' && expand('%:p') != ''
            silent update
        endif

    finally
        setpos("'x", x_save)
        setpos("'y", y_save)
    endtry
enddef
var dumpwiki_dir: string

export def ExpandShortOptionsInShellCmd(in_visual_mode = false, type = ''): string #{{{1
    # TODO: Consider turning most of this code into a python/awk/sed script.
    # Also, consider parsing the troff source code directly:
    #
    #     $ zcat $(man --where ls)
    #
    # Note that not all man pages are compressed.
    # Counter-example:
    #
    #     $ man --where string-trim
    #     /usr/local/share/fish/man/man1/string-trim.1
    #                                                 ^
    #                                                 no .gz
    #
    # We would need an algorithm.
    # For example, suppose we're looking to expand `-m`:
    #
    #    - find lines matching `\\-m\\`
    #    - on each line, look for `\\-\\-\%(\w\|-\)\+\\`
    #    - for every line where there is no match, look for a match on the line above/below
    #    - use the most frequent match

    var visual: bool = mode() =~ "^[vV\<C-V>]$"
    if visual && getcurpos()[1] != getpos('v')[1]
        echo 'cannot operate on multi-line shell command'
        return ''
    endif
    if type == ''
        &operatorfunc = function(ExpandShortOptionsInShellCmd, [visual])
        return $'g@{visual ? '' : 'l'}'
    endif

    var shell_cmd: string
    var reg_save: dict<any>
    if in_visual_mode
        reg_save = getreginfo('"')
        normal! gvy
        shell_cmd = getreg('"')
    else
        shell_cmd = getline('.')
    endif

    if shell_cmd =~ '\S\s*|\s*\w'
        # Supporting a pipeline seems too tricky:{{{
        #
        # For example:
        #
        #     a -d | b -e | c -f
        #
        # Here, to expand `-d`, `-e`, `-f`, we would need to look in several man
        # pages: `man a`, `man b`, `man c`.
        #}}}
        echo 'found a pipeline, but can only operate on one command at a time'
        return ''
    endif

    var cmd: string = shell_cmd->matchstr('\l\%(\w\|-\)\+')
    if cmd == 'string' && &filetype == 'fish'
        cmd ..= '-' .. shell_cmd->matchstr('\l\%(\w\|-\)\+\s\+\zs\%(\w\|-\)\+')
    endif
    silent var man_page_location: string = system($'man --where {cmd}')
    if man_page_location =~ '/fish/' && &filetype == 'bash'
        echo 'the man page is for fish, but the script is for bash'
        return ''
    endif
    # TODO: Before  bailing   out,  check  whether  the   command  provides  its
    # documentation via `-help` or `--h`.
    if cmd == '' || v:shell_error != 0
        echo 'could not find any shell command'
        return ''
    endif
    if shell_cmd !~ '\s\+.*-.*'
        echo 'no short option to expand in this shell command'
        return ''
    endif

    silent man_page = systemlist($'man {cmd}')

    # For commands such as:{{{
    #
    #     $ git commit -am 'message'
    #           ^----^ ^^^
    #           subcmd options to expand
    #
    #     $ git --git-dir=$HOME/.cfg/ --work-tree=$HOME commit -am 'update'
    #           ^-------------------^ ^---------------^
    #                  options for main command
    #}}}
    var option_for_main_command: string = '--\%(\w\|-\)\+\S*\s\+'
    var subcmd: string = shell_cmd
        ->matchstr($'{cmd}\s\+\%({option_for_main_command}\)*\zs\l\%(\w\|-\)\+')
    if subcmd != ''
        silent man_page_location = system($'man --where {cmd}-{subcmd}')
        if v:shell_error == 0
            silent man_page += systemlist($'man {cmd}-{subcmd}')
        endif
    endif

    var cmd_with_long_options: string = shell_cmd
        ->matchstr('\l\%(\w\|-\)\+.*')
        # `sort -rnk2` → `sort -rn -k2`
        ->substitute('\s-[a-zA-Z]\+\zs[a-zA-Z]\d\+\ze\%(\s\|$\)', () => $' -{submatch(0)}', 'g')
        # `ls -A1q` → `ls -A -1 -q`
        ->substitute('\s-[a-zA-Z]\+\zs\d\+\ze[a-zA-Z]\+\%(\s\|$\)', () => $' -{submatch(0)} -', 'g')
        # `-iw` → `--ignore-case --word-regexp`
        ->substitute('\s\zs-[a-zA-Z]\+\ze\%(\s\|$\)', () => submatch(0)->ESOISC_Rep(), 'g')
        # `-C3` → `--context=3`
        # `-k1,2` → `--key=1,2'`
        # `-t\t` → `--field-separator=\t`
        # `-F'|'` → `--field-separator='|'`
        ->substitute($'\s\zs-[a-zA-Z]{OPTION_ARG}\ze\%(\s\|$\)',
            () => submatch(0)->ESOISC_Rep(true), 'g')

    if in_visual_mode
        setreg('"', cmd_with_long_options)
        normal! gv""P
        setreg('"', reg_save)
    else
        execute $'substitute/\l\%(\w\|-\)\+.*/{cmd_with_long_options}/'
    endif
    return ''
enddef
var man_page: list<string>
const OPTION_ARG: string = '\%('
    # `-C3` (`--context=3`, `grep(1)`)
    # `-f2-` (`--fields=2-`, `cut(1)`)
    # `-k1,2` (`--key=1,2`, `sort(1)`)
    .. '\d\+-\=\%(,\d\+\)\='
    # `-t\t`
    .. '\|' .. '\\\l'
    # `-F'|'`
    .. '\|' .. "'[^']*'"
    .. '\|' .. '"[^"]*"'
    # `dpkg-query --show -f='${Status}' dkms`
    #                     ^----------^
    .. '\|' .. '=\S\+'
    .. '\)'

def ESOISC_Rep(match: string, with_arg = false): string
    # `-C3` → `--context=3`
    # `-k1,2` → `--key=1,2'`
    # `-t\t` → `--field-separator=\t`
    # `-F'|'` → `--field-separator='|'`
    # `-f='${Status}` → `--showformat='${Status}`
    if with_arg
        var arg: string = match
            ->matchstr($'{OPTION_ARG}$')
            ->substitute('^=', '', '')
        var flag: string = match->matchstr('-\zs[a-zA-Z]')
        var long_name: string = flag->GetLongName()
        if long_name == ''
            return match
        endif
        return $'{long_name}={arg}'
    endif

    # `-iw` → `--ignore-case --word-regexp`
    var expansion: string
    var flags: string = match->matchstr('-\zs[a-zA-Z]\+')
    for flag: string in flags
        var long_name: string = flag->GetLongName()
        if long_name == ''
            expansion ..= $'-{flag} '
            continue
        endif
        expansion ..= $'{long_name} '
    endfor
    return expansion->trim()
enddef

def GetLongName(flag: string): string
    var man_page_last_lnum: number = len(man_page) - 1
    var relevant_doc: list<string> = man_page
        ->copy()
        ->filter((lnum: number, line: string): bool =>
            # The long name of an option might not be documented on the same line as the short one.{{{
            #
            # It could also be documented on the previous line.
            #
            # For example, for `gawk(1)`, `--assign` is the long form of `-v`.
            # But at `man awk`, `--assign` is documented on the line *after* `-v`:
            #
            #    > -v var=val
            #    > --assign var=val
            #    >        Assign  the  value  val to the variable var, before execution of
            #    >        the program begins.  Such variable values are available  to  the
            #    >        BEGIN rule of an AWK program.
            #
            # Or it could be on the previous one.
            # For example, for `gpg(1)`, `--symmetric` is the long form of `-c`.
            # But at `man gpg`, `--symmetric` is documented on the line *before* `-c`:
            #
            #    > --symmetric
            #    > -c     Encrypt  with a symmetric cipher using a passphrase.
            #
            # That's why, we can't just match `line` against our pattern.
            # We also  need to match the  previous one (`man_page[lnum - 1]`),
            # and the next one (`man_page[lnum + 1]`).
            #}}}
            ([line]
            + [lnum > 0 ? man_page[lnum - 1] : []]
            + [lnum >= man_page_last_lnum ? [] : man_page[lnum + 1]])
                # to support `jq(1)`
                #                v
                ->match($'^\s*\%(○\s\+--\%(\w\|-\)\+\s*/\s*\)\=-\C{flag}\>'
                # to support `set(1)` (fish shell builtin)
                .. $'\|^\s*--\%(\w\|-\)\+ or -\C{flag}\>') >= 0
        )

    # make sure to ignore whitespace, `=`, and `,`
    var long_form: string = '--\%(\w\|-\)\+'
    var i: number = relevant_doc->match(long_form)
    var long_name: string = relevant_doc
        ->get(i, '')
        ->matchstr(long_form)

    if long_name == ''
        # A flag (or its long form) might be documented only in the synopsis section.{{{
        #
        # That's the case, for example, for the `-t` flag of `netstat(1)`:
        #
        #     netstat [address_family_options] [--tcp|-t]  [--udp|-u]  [--udplite|-U]
        #                                       ^------^
        #
        # And for the `-l` flag of `pstree(1)`:
        #
        #     [-l, --long] [-n, --numeric-sort] [-N, --ns-sort ns] [-p, --show-pids]
        #     ^----------^
        #}}}
        var synopsis_start: number = man_page->index('SYNOPSIS')
        var synopsis_end: number = man_page->index('DESCRIPTION')
        relevant_doc = man_page
            ->slice(synopsis_start, synopsis_end)
        var opening_bracket: string = '[[(]'
        var closing_bracket: string = '[])]'
        for line: string in relevant_doc
            if line =~ $'{opening_bracket}-{flag}\s*[|,]\s*--\%(\w\|-\)\+{closing_bracket}'
                return line->matchstr($'{opening_bracket}-{flag}\s*[|,]\s*\zs--\%(\w\|-\)\+\ze{closing_bracket}')
            endif
            if line =~ $'{opening_bracket}--\%(\w\|-\)\+\s*[|,]\s*-{flag}{closing_bracket}'
                return line->matchstr($'{opening_bracket}\zs--\%(\w\|-\)\+\s*\ze[|,]\s*-{flag}{closing_bracket}')
            endif
        endfor
        # could not find anything
        return ''
    endif

    return long_name
enddef

export def FileTypePlugins() #{{{1
    FILETYPE_PLUGINS
        ->copy()
        ->map((_, text: string): dict<any> => ({
            text: text,
            props: [{col: 1, length: 1, type: 'FileTypeAccelerators'}],
        }))
        ->popup_menu({
            borderchars: ['─', '│', '─', '│', '┌', '┐', '┘', '└'],
            callback: FileTypeCallback,
            filter: FileTypeFilter,
            highlight: 'Normal',
        })
enddef

const FILETYPE_PLUGINS: list<string> = ['all', 'indent', 'syntax', 'ftplugin']
prop_type_add('FileTypeAccelerators', {highlight: 'Title'})

def FileTypeFilter(winid: number, key: string): bool
    var accelerators: list<string> = FILETYPE_PLUGINS
        ->copy()
        ->map((_, v: string) => v[0])

    var choice: number = accelerators->index(key)
    if choice >= 0
        popup_close(winid, choice + 1)
        return true
    endif

    return popup_filter_menu(winid, key)
enddef

def FileTypeCallback(_, choice: number)
    if choice <= 0
        return
    endif

    var all_scripts: list<string> = getscriptinfo({
        name: $'/\%(ftplugin\|indent\|syntax\)/\%(.*/\)\={&filetype}.vim$'
    })->map((_, info: dict<any>): string => info.name)

    var used_scripts: list<string>
    var found_ftplugin: bool
    var found_indent: bool
    var found_syntax: bool
    for script: string in all_scripts
        if (
           found_ftplugin && script =~ '/ftplugin/'
        || found_indent && script =~ '/indent/'
        || found_syntax && script =~ '/syntax/'
        )
        && script !~ '/after/'
            continue
        endif

        if script =~ '\%(/after/.*\)\@<!' .. '/ftplugin/'
            found_ftplugin = true
        endif
        if script =~ '\%(/after/.*\)\@<!' .. '/indent/'
            found_indent = true
        endif
        if script =~ '\%(/after/.*\)\@<!' .. '/syntax/'
            if script =~ '/vim9-syntax/'
                    && "\n" .. getline(1, 10)->join("\n") !~ '\n\s*vim9\%[script]\>'
                continue
            endif
            found_syntax = true
        endif

        used_scripts->add(script)
    endfor

    var qfl: list<dict<any>> = used_scripts
        ->copy()
        ->map((_, fname: string): dict<any> => ({
            filename: fname->expand(),
            valid: true
        }))

    var which: string = FILETYPE_PLUGINS[choice - 1]
    if which != 'all'
        qfl->filter((_, entry: dict<any>): bool => entry.filename =~ $'/{which}/')
    endif
    if qfl->empty()
        echo 'could not find any relevant script'
    endif

    setqflist([], ' ', {items: qfl, title: 'FileType Plugins'})
    doautocmd <nomodeline> QuickFixCmdPost cwindow
enddef

export def HighlightColorValues(pat: string, clear = false) #{{{1
    var buf: number = bufnr('%')

    # remove existing virtual colors to start from a clean state
    var prop_types: list<string> = prop_type_list({bufnr: buf})
        ->filter((_, type: string): bool => type =~ '^virtual_color_')
    if !prop_types->empty()
        {types: prop_types, bufnr: buf, all: true}
            ->prop_remove(1, line('$'))
    endif

    if clear || search(pat, 'nc') == 0
        if exists('#HighlightColorValues')
            [{
                group: 'HighlightColorValues',
                event: 'BufWritePost',
                pattern: '<buffer>',
            }]->autocmd_delete()
        endif
        return
    endif

    # iterate over the lines of the buffer
    for [lnum: number, line: string] in getline(1, '$')->items()
        var old_end: number = -1
        # iterate over color codes/names on a given line
        while true
            # look for a color code/name
            var [color_code: string, start: number, end: number] = matchstrpos(line, pat, old_end)

            # bail out if there aren't (anymore)
            if start == -1
                break
            endif

            # remember where the  last virtual color ended  (useful in the
            # next iteration  to find the  next virtual color on  the same
            # line)
            old_end = end

            # our virtual color needs a highlight group
            var color_name: string = $'virtual_color_{color_code}'
            if pat =~ '^#'
                if color_code->len() == 3
                    color_code = color_code->repeat(2)
                endif
                [{name: color_name, guifg: $'#{color_code}'}]->hlset()
            else
                [{name: color_name, ctermfg: color_code}]->hlset()
            endif
            # and a property type
            if prop_type_get(color_name, {bufnr: buf}) == {}
                prop_type_add(color_name, {highlight: color_name, bufnr: buf})
            endif

            # We  can  finally add  the  virtual  color.  *Before*  the  color
            # code/name,  not after,  so that  if we  delete it,  we have  the
            # guarantee that the virtual color is deleted too.
            #       do not add 1 when there is a number sign
            #                           v-----------------v
            prop_add(lnum + 1, start + (pat =~ '^#' ? 0 : 1), {
                type: color_name,
                text: " \u25A0 ",
                combine: false,
            })
        endwhile
    endfor

    # make sure the colors are updated whenever we write the buffer
    if !exists('#HighlightColorValues')
        [{
            group: 'HighlightColorValues',
            event: 'BufWritePost',
            pattern: '<buffer>',
            cmd: $'HighlightColorValues(''{pat}'')',
            replace: true,
        }]->autocmd_add()
    endif
enddef

export def LongDataJoin(type = ''): string #{{{1
    # This function should do the following conversion:{{{
    #
    #     let list = [1,
    #     \ 2,
    #     \ 3,
    #     \ 4]
    # →
    #     let list = [1, 2, 3, 4]
    #}}}
    if type == ''
        &operatorfunc = LongDataJoin
        return 'g@'
    endif

    var lnum1: number = line("'[")
    var lnum2: number = line("']")
    var range: string = $':{lnum1},{lnum2}'

    var bullets: string = '[-*+]'
    var join_bulleted_list: bool = getline('.') =~ $'^\s*{bullets}'

    var mods: string = 'silent keepjumps keeppatterns '
    if join_bulleted_list
        execute $'{mods}{range} substitute/^\s*\zs{bullets}\s*//'
        execute $'{mods}{range}-1 substitute/$/,/'
        execute $'{mods}{range} join'
    else
        execute $'{mods}{range} substitute/\n\s*/ /ge'
        cursor("'[", 1)
        silent keepjumps keeppatterns substitute/\zs\s*,\ze\s\=[\]}]//e
    endif
    return ''
enddef

export def LongDataSplit(type = ''): string #{{{1
    if type == ''
        &operatorfunc = LongDataSplit
        return 'g@l'
    endif
    var line: string = getline('.')

    # special case: popup options or position (probably)
    if line =~ '^\s*{''highlight''' || line =~ '^\s*{''core_col'''
        :% j!
        var first_line: string = getline(1)
        if first_line[0] == '{' && first_line[-1] == '}'
            silent keepjumps keeppatterns substitute/.*/\=first_line->substitute('^{\|}$', '', 'g')/e
            silent keepjumps keeppatterns substitute/\%(^\%(\[[^[\]]*\]\|[^[\]]\)*\)\@<=,/\="\<CR>"/ge
            silent keepjumps keeppatterns :% substitute/^\s*'\([^']*\)'/\1/
            :% sort
        endif
        return ''
    endif

    # This pattern is useful to split long stacktrace such as:{{{
    #
    #     Error detected while processing function doc#mapping#Main[52]..<SNR>205_handle_special_filetype[11]..<SNR>205_use_man_page[21]..function doc#mapping#Main[52]..<SNR>205_handle_special_filetype[11]..<SNR>205_use_man_page:
    #}}}
    var stack_pat: string = '\%(^\s*Error detected while .*\)\@<=[.]\@1<!\.\.[.]\@!'
    var is_stacktrace: bool = match(line, stack_pat) > -1
    if is_stacktrace
        var save_regs: dict<any> = getreginfo('"')
        var indent: string = line->matchstr('^\s*')
        var split: list<string> = line
            ->substitute(stack_pat, $'\n{indent}..', 'g')
            ->split('\n')
        setreg('"', split)
        normal! Vp
        setreg('"', save_regs)
        return ''
    endif

    var is_list_or_dict: bool = match(line, '\[.*\]\|{.*}') > -1
    var has_comma: bool = stridx(line, ',') > -1
    if is_list_or_dict
        var first_line_indent: string = repeat(' ', match(line, '\S'))
        # If the  first item in the  list/dictionary begins right after  the opening
        # symbol (`[` or `{`), add a space:
        silent keepjumps keeppatterns substitute/\%(\%x5b\|\%x7b\)\s\@!\zs/ /e
        # Move the first item in the list on a dedicated line.
        silent keepjumps keeppatterns substitute/\%(\%x5b\|\%x7b\)\zs/\="\n" .. first_line_indent .. '   '/e
        # split the data
        silent keepjumps keeppatterns substitute/,\zs/\="\n" .. first_line_indent .. '   '/ge
        # move the closing symbol on a dedicated line
        silent keepjumps keeppatterns substitute/\zs\s\=\ze[\]}]/\=",\n" .. first_line_indent/e

    elseif has_comma
        # We use `strdisplaywidth()` because the indentation could contain tabs.
        var indent_lvl: number = line->matchstr('^\s*')->strdisplaywidth()
        var indent_txt: string = repeat(' ', indent_lvl)
        silent keepjumps keeppatterns substitute/\ze\S/- /e
        var pat: string = '\s*,\s*\%(et\|and\s\+\)\=\|\s*\<\%(et\|and\)\>\s*'
        LongDataSplitRep = (): string => "\n" .. indent_txt .. '- '
        execute 'silent keepjumps keeppatterns substitute/' .. pat .. '/\=LongDataSplitRep()/ge'
    endif

    return ''
enddef

var LongDataSplitRep: func

export def OnlySelection(lnum1: number, lnum2: number) #{{{1
    var lines: list<string> = getline(lnum1, lnum2)
    silent keepjumps :% delete _
    lines->setline(1)
enddef

# OpenGuiFileManager / OpenTerm {{{1

def Error(msg: string)
    echohl ErrorMsg
    echomsg msg
    echohl None
enddef

export def OpenGuiFileManager(dir: string)
    if !DirIsValid(dir)
        return
    endif
    silent system('xdg-open ' .. shellescape(dir) .. ' &')
enddef

def DirIsValid(dir: string): bool
    if !isdirectory(dir) # this happens if a directory was deleted outside of vim.
        Error('invalid/missing directory: ' .. dir)
        return false
    endif
    return true
enddef

export def OpenTerm(dir: string)
    if !DirIsValid(dir)
        return
    endif
    if IS_TMUX
        silent system('tmux split-window -v -c ' .. shellescape(dir))
    elseif IS_X_RUNNING
        silent printf('xterm -e "cd %s; %s"', shellescape(dir), &shell)->system()
    else
        Error('failed to open terminal')
    endif
enddef

const IS_TMUX: bool = !empty($TMUX)
# terminal Vim running within a GUI environment
const IS_X_RUNNING: bool = !empty($DISPLAY) && &term != 'linux'

export def PluginGlobalVariables(keyword: string) #{{{1
    if keyword == ''
        var usage: list<string> =<< trim END
            usage:

                :PluginGlobalVariables ulti
                display all global variables containing the keyword `ulti`
        END
        echo usage->join("\n")
        return
    endif
    var variables: list<string> = deepcopy(g:)
        ->filter((k: string, _): bool =>
                k =~ '\c\V' .. keyword->escape('\')
             && k !~ '\%(loaded\|did_plugin_\)')
        ->items()
        ->map((_, v: list<any>): string => v[0] .. ' = ' .. string(v[1]))
    if variables->empty()
        echo $'found no variables for: {keyword}'
        return
    endif
    new
    &l:buftype = 'nofile'
    &l:buflisted = false
    &l:swapfile = false
    &l:wrap = false
    variables->setline(1)
enddef

export def RemoveTabs(lnum1: number, lnum2: number) #{{{1
    var view: dict<number> = winsaveview()
    var mods: string = 'silent keepjumps keeppatterns'
    var range: string = ':' .. lnum1 .. ',' .. lnum2
    RemoveTabsRep = (): string =>
          synstack('.', col('.'))
        ->indexof((_, id: number): bool => synIDattr(id, 'name') =~ '\cheredoc') >= 0
        # Don't remove a leading tab in a heredoc.{{{
        #
        # They have a special meaning in bash and zsh.
        # See `man bash /<<-`.
        #
        # ---
        #
        # We don't use a complex pattern, just: `heredoc`.
        # We could  try sth like  `^\Cz\=shHereDoc$`, but it seems  there exists
        # other possible syntax groups (e.g. `shHereDoc03`).
        #}}}
            ? "\<Tab>"
            # FIXME: `strdisplaywidth()` doesn't handle conceal.{{{
            #
            # It works as if `'conceallevel'` was set to 0.
            # This matters, e.g., for a blockquote containing a tab character in
            # a  markdown file,  where the  leading  `> `  is concealed  because
            # `'conceallevel'` is 3.
            #}}}
            : repeat(' ', strdisplaywidth("\<Tab>", virtcol('.', true)[0] - 1))
    execute $'{mods} {range} substitute/\t/\=RemoveTabsRep()/ge'
    winrestview(view)
enddef
var RemoveTabsRep: func

export def RunCompiler() #{{{1
    if get(b:, 'current_compiler', '') == 'desktop-file-validate'
        silent update
        silent var out: string = system($'desktop-file-validate {expand('%:p:S')}')
        if v:shell_error != 0
            echo out
        else
            echo 'desktop-file-validate: OK'
        endif
        return
    endif

    # For `$ awk --lint ...` to  produce meaningful warnings, we  need to pass
    # it an `.input` file.  Its contents  should be representative of what the
    # script will have to deal with in practice.
    if get(b:, 'current_compiler', '') == 'awk'
            && expand('%:p:h')
            ->readdir((fname: string): bool => fname =~ '.\.input$', {sort: 'none'})
            ->empty()
        echohl ErrorMsg
        echo 'awk: missing *.input file(s)'
        echohl NONE
        return
    endif

    var loclist: list<dict<any>> = []
    var compile_cmd: string = 'custom linter'
    if &l:makeprg != ''
        silent update
        compile_cmd = &l:makeprg->expandcmd()
        var errors: list<string> = compile_cmd->systemlist()
        if errors->len() > 1'000
            echohl ErrorMsg
            echo 'too many errors'
            echohl NONE
            return
        endif

        silent loclist = getqflist({
            lines: errors,
            efm: &l:errorformat
        })->get('items', [])
        # `compile_cmd->systemlist()` has run the compiler.
        # If it has changed the file, we want the buffer to be immediately updated.{{{
        #
        # That's useful  for the `black` python  formatter.  Without `:checktime`,
        # the buffer is not updated before a few seconds (next `CursorHold`?).
        #}}}
        execute $':{bufnr('%')} checktime'
    endif

    # create new empty list
    setloclist(0, [])
    # Our custom linter might report its own extra errors.
    # Cache their regexes, numbers, and descriptions.
    if !MY_LINTER_DB->has_key(&filetype)
        MY_LINTER_DB[&filetype] = GetMyLinterDB(&filetype)
    endif
    # append our extra errors
    for [regex: string, nr: number, msg: string] in MY_LINTER_DB[&filetype]
        var old_size: number = getloclist(0, {size: 0}).size
        # `:noautocmd`: Don't open the location  window.  That would cause `%`
        # to  expand to  an  empty  file name  (because  Vim  would focus  the
        # location window) in the next iteration, giving an error.
        #
        # ---
        #
        # `\C`:  `:vimgrep` &  friends  ignore `'smartcase'`,  which can  give
        # false  positives.   That's  because  we set  `'ignorecase'`,  so  by
        # default  the case  is always  ignored,  even if  our regex  contains
        # uppercase letters.
        execute $'silent! noautocmd lvimgrepadd /\C{regex->escape('/')}/gj %'
        var new_size: number = getloclist(0, {size: 0}).size
        var new_entries: list<dict<any>>
        if new_size > old_size
            for entry: dict<any> in getloclist(0)[old_size :]
                # ignore a commented match
                if synstack(entry.lnum, entry.col)
                        ->indexof((_, id: number): bool =>
                            # Do not ignore strings.{{{
                            #
                            # A string  might embed code via  an interpolation
                            # syntax.  For  example, parameter  expansions and
                            # command substitutions in bash/fish.
                            #
                            # Technically, a heredoc  might also contain code,
                            # but in practice that rarely happens.
                            #}}}
                            synIDattr(id, 'name') =~ '\ccomment\|heredoc') >= 0
                    continue
                endif
                entry->extend({
                    text: msg,
                    nr: nr,
                    user_data: MY_LINTER_USER_DATA,
                })
                new_entries->add(entry)
            endfor
            loclist->extend(new_entries)
        endif
    endfor

    setloclist(0, loclist, 'r')
    setloclist(0, [], 'a', {title: compile_cmd})
    doautocmd <nomodeline> QuickFixCmdPost lwindow

    if &filetype != 'qf'
        return
    endif

    # Install `gx` mapping, to let us open the wiki page where the error under
    # the cursor is documented.
    nnoremap <buffer><nowait> gx <ScriptCmd>ErrorMeaning()<CR>
enddef

const MY_LINTER_ROOT_DIR: string = $'{$HOME}/Wiki/linter'
const MY_LINTER_USER_DATA: string = 'MyLinter'
var MY_LINTER_DB: dict<list<list<any>>>
def GetMyLinterDB(filetype: string): list<list<any>>
    var my_linter_dir: string = $'{$HOME}/Wiki/linter/{filetype}'
    if !isdirectory(my_linter_dir)
        return []
    endif
    var lints: list<string> = my_linter_dir
        ->readdir((fname: string) => fname =~ '\.md$', {sort: 'none'})
        ->map((_, fname: string) => $'{my_linter_dir}/{fname}')
    var entry: list<list<any>>
    for lint: string in lints
        var lines: list<string> = lint->readfile()
        var i: number = lines->index('# Regex:')
        if i == -1
            echohl ErrorMsg
            echomsg $'{lint}: missing regex'
            echohl NONE
            continue
        endif
        var regex: string
        if lines[i + 1] == '```vim'
            var start: number = i + 2
            var end: number = lines
                ->indexof((lnum: number, line: string): bool => line == '```' && lnum > start)
            --end
            regex = lines[start : end]
                ->filter((_, line: string): bool => line !~ '^\s*#')
                ->join()
                ->eval()
        else
            regex = lines[i + 2]->substitute('^    ', '', '')
        endif
        if regex == ''
            echohl ErrorMsg
            echomsg $'{lint}: missing regex'
            echohl NONE
            continue
        endif
        var nr: number = lint->fnamemodify(':t:r')->str2nr()
        var msg: string = lines[0]->substitute('^Msg: ', '', '')
        entry->add([regex, nr, msg])
    endfor
    return entry
enddef

def ErrorMeaning()
    var error: dict<any> = getloclist(0)[line('.') - 1]
    # the error is given by our custom linter
    if error->has_key('user_data')
            && error.user_data->typename() == 'string'
            && error.user_data == MY_LINTER_USER_DATA
        var buf: number = getloclist(0, {filewinid: 0}).filewinid
            ->winbufnr()
        if !buf->bufexists()
            return
        endif
        var filetype: string = getbufvar(buf, '&filetype')
        var lints_dir: string = $'{MY_LINTER_ROOT_DIR}/{filetype}'
        if !lints_dir->isdirectory()
            return
        endif
        # The lint file  name is not necessarily `123.md`, where  `123` is the
        # error number.   The latter  might be  padded with  `0`s on  the left
        # (e.g. `0123.md`).
        var lint_basename: string = lints_dir
            ->readdir((fname: string): bool => fname =~ $'^0*{error.nr}.md$')
            ->get(0, '')
        var lint_file = $'{lints_dir}/{lint_basename}'
        if !lint_file->filereadable()
            return
        endif
        window.OpenOrFocus(lint_file, 'aboveleft split')
        return
    endif

    # the error is given by a third-party linter
    var makeprg: string = getloclist(0, {'filewinid': 0}).filewinid
        ->winbufnr()
        ->getbufvar('&makeprg')
    var url: string
    if makeprg =~ '^\Cshellcheck\>'
        var error_code: string = getline('.')
            ->matchstr('.\{-}|.\{-}\zs\d\+\ze\s*|')
        url = $'https://github.com/koalaman/shellcheck/wiki/SC{error_code}'

    elseif makeprg =~ '^\Cpylint\>'
        var matchlist: list<string> = getline('.')
            ->matchlist('.\{-}|.\{-}\d\+\s*|\s*\[\([CEFIRW]\)\d\+(\([^)]*\))')
        if matchlist->empty()
            return
        endif
        var [type: string, error_name: string] = matchlist[1 : 2]
        # https://pylint.pycqa.org/en/latest/user_guide/messages/index.html#messages-categories
        type = {
            C: 'convention',
            E: 'error',
            F: 'fatal',
            I: 'information',
            R: 'refactor',
            W: 'warning'
        }[type]
        url = $'https://pylint.pycqa.org/en/latest/user_guide/messages/{type}/{error_name}.html'

    elseif makeprg =~ '^\Cluacheck\>'
        var curline: string = getline('.')
        if curline =~ '(W111)'
            echo 'Avoid setting a global item, when a local one would be enough.  Use local.'
            return
        endif
        url = 'https://luacheck.readthedocs.io/en/stable/warnings.html'

    else
        return
    endif

    var open_url: string = $'xdg-open {url->shellescape()}'
    silent system(open_url)
enddef

export def RunSudoShellCommand(cmd: string, on_vimenter = false) #{{{1
    if on_vimenter
        redrawstatus
    endif
    var prompt: string = printf('[sudo] password for %s (%s): ', $USER, cmd)
    var pass: string = inputsecret(prompt)
    if pass->empty()
        return
    endif
    # What does the `--stdin` option mean for `sudo(8)`?{{{
    #
    # It reads the password from the standard input instead of using the terminal device.
    # The password must be followed by a newline character.
    #
    # See: `man sudo /--stdin`
    #}}}
    silent var output: string = system($'sudo --stdin {cmd}', $"{pass}\n")
    redraw!
    echo output
enddef

export def SearchTodo(where: string) #{{{1
    try
        execute 'silent lvimgrep /\C\<\%(FIXME\|TODO\)\s*[(:]/j '
            .. (where == 'buffer' ? '%' : './**/*')
    catch /^Vim\%((\a\+)\)\=:E480:/
        echomsg 'no TODO or FIXME'
        return
    endtry

    var items: list<dict<any>> = getloclist(0)
        # Tweak the text of  each entry when there's a line  with just `todo` or
        # `fixme`.  Replace it with the text of the next non empty line instead.
        ->map((_, v: dict<any>) =>
            SearchTodoText(v)
            # remove indentation (reading lines with various indentation levels is jarring)
            ->extend({text: v.text->substitute('^\s*', '', '')}))
    var what: dict<any> = {
        items: items,
        title: 'FIX' .. 'ME & TO' .. 'DO',
        context: {
            origin: 'mine',
            matches: [['Todo', '\cfixme\|todo']]
                + (where == 'buffer' ? [['Conceal', 'location']] : [])
        }
    }
    setloclist(0, [], 'r', what)

    # Because we've prefixed `:lvimgrep`  with `:noautocmd`, our autocmd which
    # opens a quickfix window hasn't kicked in.  We must manually open it.
    doautocmd <nomodeline> QuickFixCmdPost lwindow
enddef

def SearchTodoText(dict: dict<any>): dict<any>
    # if the text only contains `fixme` or `todo`
    if dict.text =~ $'\c\%(fixme\|todo\):\=\s*\%({&l:foldmarker->split(',')[0]}\)\=\s*$'
        var bufnr: number = dict.bufnr
        # get the text of the next line, which is not empty (contains at least one keyword character)
        # Why using `readfile()` instead of `getbufline()`?{{{
        #
        # `getbufline()` works only if the buffer is listed.
        # If the buffer is NOT listed, it returns an empty list.
        # There's no guarantee that all buffers in which a fixme/todo is present
        # is currently listed.
        #}}}
        var lines: list<string> = bufname(bufnr)
            ->readfile('', dict.lnum + 4)[-4 :]
        var idx: number = lines->indexof((_, l: string): bool => l =~ '\k')
        dict.text = idx == -1 ? '' : lines[idx]
    endif
    return dict
enddef

export def SendToTabPage(vcount: number) #{{{1
    var curtab: number = tabpagenr()
    var count: number
    if vcount == curtab
        redraw
        echo 'current window is already in current tab page'
        return
    endif

    if vcount > tabpagenr('$')
        redraw
        echo $'no tab page with number {vcount}'
        return
    endif

    # if we don't press a count before the LHS, we want the chance to provide it afterward
    if vcount == 0
        # TODO: It would be nice if we could select the tab page via fzf.{{{
        #
        #     # prototype
        #     nnoremap <F3> <ScriptCmd>fzf#run({
        #         \ source: range(1, tabpagenr('$')),
        #         \ sink: Func,
        #         \ options: '+m',
        #         \ left: 30,
        #         \ })<CR>
        #
        #     def Func(line: string)
        #         execute $'{line}tabnext'
        #     enddef
        #
        # We  still need  to figure out  how to  preview all the  windows opened  in the
        # selected tab page.
        #}}}
        var input: string = input('send to tab page nr: ')
        if input == '$'
            count = tabpagenr('$')
        elseif input =~ '$-\+$'
            var offset: number = input->matchstr('-\+')->strlen()
            count = tabpagenr('$') - offset
        elseif input =~ '$-\d\+$'
            var offset: number = input->matchstr('-\d\+')->str2nr()
            count = tabpagenr('$') - offset
        elseif input =~ '^[+-]\+$'
            count = tabpagenr() + count(input, '+') - count(input, '-')
        elseif input !~ '^[+-]\=\d*[1-9]\d*$'
            redraw
            if input != ''
                echo 'not a valid number'
            endif
            return
        # parse a `+2` or `-3` number as an index relative to the current tabpage
        elseif input[0] =~ '+\|-'
            count = $'{curtab} {input[0]} {input->matchstr('\d\+')}'->eval()
        else
            count = input->matchstr('\d\+')->str2nr()
        endif
    endif
    var bufnr: number = bufnr('%')
    # let's save the winid of the window we want to move
    var closedwinid: number = win_getid()
    # Do *not* try to close it now.{{{
    #
    # Closing a tab page changes the positions of the next ones.
    # So, you would need  to apply an offset when moving to  a later tabpage, if
    # the current one only contains 1 window.
    #
    # Also, you don't know whether `:tabnext` will succeed.
    # If it fails, there's no reason to close the current window.
    #}}}
    # focus target tab page
    try
        # clear output of `input()` from the command-line
        redraw
        execute $'tabnext {count}'
    catch /^Vim\%((\a\+)\)\=:E475:/
        lg.Catch()
        return
    endtry
    # Open new window displaying the buffer from the closed window in the target tab page.{{{
    #
    # `silent!` suppresses  `E211`; the latter might  be given if you've  sent a
    # temporary file from a different Vim instance, which has been quit since.
    #}}}
    silent! execute $'sbuffer {bufnr}'
    var curwinid: number = win_getid()
    win_gotoid(closedwinid)
    close
    win_gotoid(curwinid)
enddef

export def SendToServer() #{{{1
    if v:servername == 'VIM'
        return
    endif

    var bufname: string = expand('%:p')
    var file: string
    var cmd: string
    # parse ansi escape codes; useful for when you run sth like `$ trans word | vipe`
    if &buftype == 'terminal'
        if !exists('g:ParseAnsiEscapeCodesFile')
            echomsg 'g:ParseAnsiEscapeCodesFile is not defined'
            return
        endif
        var expressions: list<string> =<< trim eval END
            execute('tabnew')
            term_start('cat {g:ParseAnsiEscapeCodesFile}', {{'curwin': v:true}})
        END
        cmd = expressions
            ->join(', ')
            ->printf('vim --remote-expr "[%s]"')

    elseif bufname == '' || bufname =~ '^\C/proc/'
        file = tempname()
        getline(1, '$')->writefile(file)
        cmd = $'vim --remote-tab {shellescape(file)}'

    else
        file = bufname
        cmd = $'vim --remote-tab {shellescape(file)}'
    endif

    silent system(cmd)

    if v:shell_error != 0
        echohl ErrorMsg
        echomsg printf('the command "%s" failed', cmd)
        echohl NONE
        return
    endif

    var msg: string = printf('the %s was sent to the Vim server',
        bufname == '' ? 'buffer' : 'file')
    redraw
    echohl ModeMsg
    echomsg msg
    echohl NONE
enddef

