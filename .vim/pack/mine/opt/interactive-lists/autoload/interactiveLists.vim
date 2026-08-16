vim9script

import 'lg/window.vim'

const BOOKMARKS_FILE: string = $'{$HOME}/.local/share/vim/bookmarks'

# Interface {{{1
export def Main(cmd: string, bang = false): string #{{{2
    var cmdline: string = getcmdline()
    var output: list<any> = Capture(cmd, bang)
    var list: list<any> = Convert(output, cmd, bang)

    if empty(list)
        if cmd == 'args'
            Error('No arguments')
            return ''
        endif
        Error('No output')
        return ''
    endif

    var pat: string = {
        args:      '.*|\s*|\s*',
        oldfiles:  '.\{-}|\s*|\s*',
        registers: '^\s*|\s*|\s*',
    }[cmd]

    setloclist(0, [], ' ', {
        items: list
            ->map((_, v: any): dict<any> =>
                v->has_key('lnum')
                ? extend(v, {lnum: v.lnum})
                : v
            ),
        title: ':' .. cmd .. (bang ? '!' : ''),
        context: {
            origin: 'mine',
            matches: [['Conceal', pat]]
                + (cmd == 'registers' ? [['qfFileName', '^\s*|\s*|\s\zs\S\+']] : []),
        }
    })

    # We don't want  to open the qf  window directly, because it's  the job of
    # our `vim-qf` plugin.  The latter uses  some logic to decide the position
    # and the  size of the qf  window. `:lopen` or `:lwindow`  would just open
    # the window with its default position/size without any custom logic.
    #
    # So, we  just emit the  event `QuickFixCmdPost`. `vim-qf` has  an autocmd
    # listening to it.
    doautocmd <nomodeline> QuickFixCmdPost lopen

    return ''
enddef

def Error(msg: string)
    echohl ErrorMsg
    echomsg msg
    echohl NONE
enddef

export def AllMatchesInBuffer() #{{{2
    # Alternative:
    #
    #     keepjumps global//number

    try
        if bufname('%')->empty() || &buftype == 'terminal'
            var tmp_file: string = tempname()
            getline(1, '$')->writefile(tmp_file)
            execute $'silent noautocmd lvimgrep //gj {tmp_file}'
            var buf: number = bufnr('%')
            var items: any = getloclist(0)
                ->map((_, entry: dict<any>) => entry->extend({bufnr: buf}))
            setloclist(0, [], 'r', {items: items, title: $'lvimgrep /{@/}/gj %'})
        else
            # Why `:execute`?{{{
            #
            # It removes excessive spaces in the title of the qf window, between
            # the colon and the rest of the command.
            #}}}
            #   Why is it necessary?{{{
            #
            # Because Vim copies the indentation of the command.
            #
            # MRE:
            #
            #     silent help
            #     lvimgrep /pat/ %
            #     lopen
            #     echo w:quickfix_title
            #     :lvimgrep /pat/ ...˜
            #     ✔
            #
            #     def Func()
            #         silent help
            #         lvimgrep /pat/ %
            #         lopen
            #         echo w:quickfix_title
            #     enddef
            #     Func()
            #     title = ':    lvimgrep /pat/ ...'˜
            #               ^--^
            #               ✘ because `:lvimgrep` is executed from a line˜
            #                 with a level of indentation of 4 spaces˜
            #}}}
            #   Is there an alternative?{{{
            #
            # Yes, but it's more complicated:
            #
            #     if &buftype == 'quickfix'
            #         w:quickfix_title = ':' .. w:quickfix_title->matchstr(':\s*\zs\S.*')
            #     endif
            #}}}
            execute 'silent noautocmd lvimgrep //gj %'
        endif
        var items: list<dict<any>> = getloclist(0)
        var what: dict<any> = {
            items: items,
            context: {
                origin: 'mine',
                matches: [['Conceal', 'location']],
            }
        }
        setloclist(0, [], 'r', what)
        doautocmd <nomodeline> QuickFixCmdPost lwindow
    catch /^Vim\%((\a\+)\)\=:E480:/
        Error(v:exception)
    endtry
    if winnr('#')->winbufnr()->getbufvar('&buftype', '') == 'quickfix'
        wincmd p
    endif
enddef

export def SetOrGoToMark(action: string) #{{{2
    # ask for a mark
    var mark: string = getcharstr()
    if mark == "\<Esc>" || mark->strlen() > 1
        return
    endif

    # If it's not a global one, just type the keys as usual (with one difference):{{{
    #
    #    - mx
    #    - `x
    #      ^
    #      let's use backtick instead of a single quote, so that we land on the exact column
    #      rationale: the single quote key is easier to type
    #}}}
    if range(char2nr('A'), char2nr('Z'))->index(char2nr(mark)) == -1
        feedkeys((action == 'set' ? 'm' : "`") .. mark .. 'zv', 'in')
        return
    endif

    # now, we process a global mark
    # first, get the path to the file containing the bookmarks
    if !filereadable(BOOKMARKS_FILE)
        echo BOOKMARKS_FILE .. ' is not readable'
        return
    endif

    # we *set* a global mark
    if action == 'set'
        var new_bookmarks: list<string> = BOOKMARKS_FILE
            ->readfile()
            # eliminate old mark if it's present
            ->filter((_, v: string): bool => v[0] != mark)
            # and bookmark current file
            + [mark .. ':' .. expand('%:p')->substitute('\V' .. $HOME, '$HOME', '')]

        new_bookmarks
            ->sort()
            ->writefile(BOOKMARKS_FILE)

    # we *jump* to a global mark
    else
        var lpath: list<string> = BOOKMARKS_FILE
            ->readfile()
            ->filter((_, v: string): bool => v[0] == mark)
        if lpath == [] || lpath[0][2 :] == ''
            return
        endif
        var path: string = lpath[0][2 :]
        execute 'edit ' .. path
        # bang to suppress `:help E20` (mark not set)
        silent! normal! g`.zvzz
    endif
    # re-mark the file, to fix Vim's frequent and unavoidable lost marks
    feedkeys('m' .. mark, 'in')
enddef
#}}}1
# Core {{{1
def Capture(cmd: string, bang: bool): list<any> #{{{2
    var list: list<any>
    if cmd == 'args'
        list = argv()
            ->map((_, v: string): dict<string> => ({
                filename: v,
                text: v->fnamemodify(':t'),
            }))

    elseif cmd == 'oldfiles'
        list = execute('oldfiles')->split('\n')

    elseif cmd == 'registers'
        list =<< trim END
            #
            +
            -
            *
            /
            =
        END
        list->extend(
                (range(48, 57) + range(97, 122))
                ->map((_, v: number): string => nr2char(v)))
    endif
    return list
enddef

def Convert( #{{{2
    arg_output: list<any>,
    cmd: string,
    bang: bool
): list<any>

    var output: list<any>
    if cmd == 'args'
        output = arg_output

    elseif cmd == 'oldfiles'
        output = arg_output
            ->map((_, v: string): dict<string> => ({
                     filename: v->matchstr('^\d\+:\s\zs.*')->expand(),
                     text: v->matchstr('^\d\+:\s\zs.*')->fnamemodify(':t'),
            }))

    elseif cmd == 'registers'
        # Do *not* use the `filename` key to store the name of the registers.{{{
        #
        # After pressing `g:r`, Vim would load buffers `a`, `b`, ...
        # They would pollute the buffer list (`:ls!`).
        #}}}
        output = arg_output
            ->map((_, v: string): dict<string> => ({text: v}))

        # We pass `1` as a 2nd argument to `getreg()`.
        # It's ignored  for most registers,  but useful for the  expression register.
        # It allows to get the expression  itself, not its current value which could
        # not exist anymore (e.g.: arg)
        output->map((_, v: dict<string>) =>
                        extend(v, {
                                    text: v.text .. '    ' .. getreg(v.text, true)
                                  }))

    endif
    return output
enddef
