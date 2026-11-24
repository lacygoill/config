vim9script noclear

# Don't try to save/restore a quickfix list automatically across Vim's restarts.{{{
#
# Restarting the main Vim instance would take more time if a big quickfix list
# needs to be restored.  And it might interfere with a quickfix list which was
# already on the stack (`-q ...`, `-S ...`, `+'vimgrep ...'`, ...).
#
# Besides, a  quickfix list saved  by our main  Vim instance should  not cause
# other Vim instances to start slowly.
#}}}

# Init {{{1

const QFL_DIR: string = $'{$HOME}/.local/share/vim/quickfix_lists'
if !isdirectory(QFL_DIR)
    if !mkdir(QFL_DIR, 'p', 0o700)
        echomsg $'vim-qf: failed to create directory {QFL_DIR}'
        finish
    endif
endif

# Interface {{{1
export def Complete(_, _, _): string #{{{2
    return QFL_DIR
        ->readdir((n: string): bool => n =~ '\.txt$')
        ->map((_, v: string) => v->fnamemodify(':t:r'))
        ->join("\n")
enddef

export def Save(arg_fname: string, bang: bool) #{{{2
    if win_gettype() == 'loclist'
        Error('Csave: sorry, only a quickfix list can be saved, not a location list')
        return
    endif
    var fname: string = Expand(arg_fname)
    if filereadable(fname) && !bang
        Error($'Csave: {fname} is an existing file; add ! to overwrite')
        return
    endif
    g:LAST_QFL = fname
    var items: list<dict<any>> = getqflist({items: 0}).items
    if empty(items)
        echo 'Csave: no quickfix list to save'
        return
    endif
    # Explanation:{{{
    #
    # `remove(v, 'bufnr')` does 2 things:
    #
    #    - it removes the `bufnr` key from every entry in the quickfix list
    #    - it evaluates to the value which was bound to that key (i.e. the
    #      buffer number of the quickfix list entry)
    #
    # `bufname(...)` converts the buffer number into a buffer name.
    # `fnamemodify(...)` makes sure that the  name is absolute, and not relative
    # to the current working directory.
    #}}}
    items
        ->map((_, v: dict<any>) => extend(v, {
                filename: remove(v, 'bufnr')
                        ->bufname()
                        ->fnamemodify(':p')
        }))
    var qfl: dict<any> = {items: items, title: getqflist({title: 0}).title}
    # Warning: If you replace `eval` with a later call to `substitute()`, don't forget to `escape()` `&` and `\`.{{{
    #
    #                                     no eval
    #                                     v
    #     var lines: list<string> =<< trim END
    #     ...
    #         var qfl: dict<any> = %s
    #     ...
    #     END
    #     lines[1] = lines[1]
    #         ->substitute('%s', string(qfl)->escape('&\'), '')
    #                                       ^------------^
    #
    # Without, there would  be a risk of getting null  characters, which would
    # later break the sourcing of the  file.  That's because a backslash has a
    # special meaning, even in the replacement part of a substitution.
    #
    # From `:help :s%`
    #
    #    > The special meaning is also used inside the third argument {sub} of
    #    > the |substitute()| function with the following exceptions:
    #    > ...
    #
    # MRE:
    #
    #     :let dict = {'a': 'b\nc'}
    #     :echo '%s'->substitute('%s', string(dict), '') =~ '\%x00'
    #     1˜
    #
    # We need to make sure it's parsed literally.
    #
    # ---
    #
    # You would still need `escape()` if you replaced `string()` with `json_encode()`.
    # Indeed, the latter might add backslashes to escape literal double quotes:
    #
    #     :let dict = {'a': 'b"c'}
    #     :echo json_encode(dict)
    #     {"a":"b\"c"}˜
    #            ^
    #
    # And again, those backslashes must be parsed literally by `substitute()`.
    #
    # ---
    #
    # Similar issue with `&` which has a special meaning.
    #}}}
    var lines: list<string> =<< trim eval END
        vim9script
        var qfl: dict<any> = {string(qfl)}
        var items: list<dict<any>> = qfl.items
        var title: string = qfl.title
        setqflist([], ' ', {{items: items, title: title}})
    END
    writefile(lines, fname)
    echo $'Csave: quickfix list saved in {fname}'
enddef

export def Restore(arg_fname: string) #{{{2
    var fname: string
    if arg_fname == ''
        fname = get(g:, 'LAST_QFL', '')
    else
        fname = Expand(arg_fname)
    endif

    if fname == ''
        echo 'Crestore: do not know which quickfix list to restore'
        return
    endif
    if !filereadable(fname)
        echo $'Crestore: {fname} is not readable'
        return
    endif
    execute $'source {fnameescape(fname)}'
    cwindow
    echo $'Crestore: quickfix list restored from {fname}'
enddef

export def Remove(arg_fname: string, bang: bool) #{{{2
    # Rationale:{{{
    #
    # `:Cremove` and `:Crestore` begins with  the same 3 characters.  We could
    # insert `:Cre` then tab complete, and choose `:Cremove` by accident while
    # we  wanted `:Crestore`.   Asking for  a bang  reduces the  risk of  such
    # accidents.
    #}}}
    if !bang
        Error('Cremove: add a bang')
        return
    endif
    var fname: string = Expand(arg_fname)
    if !filereadable(fname)
        echo $'Cremove: cannot remove {fname} ; file not readable'
        return
    endif
    if delete(fname)
        echo $'Cremove: failed to remove {fname}'
    else
        echo $'Cremove: removed {fname}'
    endif
enddef
#}}}1
# Util {{{1
def Error(msg: string) #{{{2
    echohl ErrorMsg
    echomsg msg
    echohl NONE
enddef

def Expand(fname: string): string #{{{2
    # Do *not* use the `.vim` extension.{{{
    #
    # It would  lead to  too many spurious  matches when we  use this  kind of
    # `:vimgrep` command:
    #
    #     :vimgrep /pat/gj $MYVIMRC ~/.vim/**/*.vim ~/.vim/**/*.snippets ~/.vim/template/**
    #}}}
    return $'{QFL_DIR}/{fname}.txt'
enddef
