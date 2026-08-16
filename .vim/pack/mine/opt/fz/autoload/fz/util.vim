vim9script

export def PutInQuickfixList(fpaths: list<string>) # {{{1
    new
    arglocal
    execute 'args ' .. fpaths
        ->map((_, fpath: string) => fnameescape(fpath))
        ->join()
enddef

export def Error(msg: string) #{{{1
    echohl ErrorMsg
    echo msg
    echohl NONE
enddef

export def Escape(s: string, char: string): string #{{{1
    # `char` can  be a literal character  (e.g. `[`), or a  pattern matching a
    # single character (e.g. `['"]`).
    return s
        # make sure the  character is escaped (i.e. there is  an odd number of
        # backslashes in front of it)
        ->substitute($'\(\\*\)\({char}\)', (m) =>
            m[1] .. (m[1]->len() % 2 == 0 ? '\' : '') .. m[2], 'g')
enddef

export def Expand(path: string): string #{{{1
    # Warning: Don't use `expand()`.{{{
    #
    # It creates too many issues.
    #
    #                     v
    #     :echo expand('~/[a-1]/file.txt')
    #     E944: Reverse range in character class
    #
    # Even though `[a-1]` is an ugly directory name, it's still valid, and
    # no error should be given.
    #
    # ---
    #
    #                    v
    #     :echo expand('a{b')
    #     E220: Missing }.
    #
    # ---
    #
    #                          vv v
    #     :Time echo expand('~/**/*vimindent')
    #     0.317 seconds to run :echo expand('~/**/*vimindent')
    #     ^---^
    #     too slow
    #
    # ---
    #
    # One solution would be to escape special characters:
    #
    #     return path
    #         ->Escape('[[{*]')
    #         ->expand()
    #
    # But we would  probably still be missing some of  them.  Also, notice
    # how they  all create  different issues;  I don't  want to  lose time
    # debugging each of them.
    #}}}
    # Don't use `fnameemodify(':p')` either.{{{
    #
    # That doesn't work at  all:
    #
    #     :echo '$HOME/Wiki/Todo.md'->fnamemodify(':p')
    #     /home/lgc/.vim/pack/mine/opt/fz/$HOME/Wiki/Todo.md
    #                                     ^---^
    #                                       ✘
    #
    # Not sure why  we used that, but this mistake  prevented us from visiting
    # `~/Wiki/Todo.md` for far too long.
    #}}}
    return path
        ->substitute('^\%(\~\|$HOME\)\%($\|/\)\@=', $HOME, '')
enddef
