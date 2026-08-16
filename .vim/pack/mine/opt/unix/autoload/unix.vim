vim9script

import 'lg.vim'

export def Chmod(mode: string) #{{{1
# TODO: Look at how tpope implemented this function.
    var fname: string = expand('%:p')
    # Do *not* use `system()` and `chmod(1)` instead of `setfperm()`.{{{
    #
    # We did it in the past, and we  regularly had a warning telling us that the
    # file had changed outside of Vim, and  asking us whether we should read the
    # file again.  That's too distracting.   Let's change the file from *inside*
    # Vim.
    #}}}
    if !fname->setfperm(mode)
        Error('cannot change file mode bits')
        return
    endif

    # to avoid a (delayed) message such as: “/tmp/file 1L, 6C”
    execute $'silent :{bufnr('%')} checktime'
enddef

export def Cp(arg_dst: string, bang: bool) #{{{1
    var src: string = expand('%:p')
    var dir: string = expand('%:p:h')
    var dst: string = stridx(arg_dst, '/') == 0
        ?     arg_dst
        :     dir .. '/' .. simplify(arg_dst)

    if filereadable(dst) && !bang
        Error(string(dst) .. ' already exists; add a bang to overwrite it')
        return
    endif
    silent system('cp'
        # follow symbolic links
        .. ' --dereference'
        # do not overwrite an existing file
        .. (bang ? '' : ' --no-clobber')
        .. ' --preserve=mode,ownership,timestamps'
        .. ' ' .. shellescape(src) .. ' ' .. shellescape(dst))

    if v:shell_error != 0
        Error('Failed to copy ' .. string(src) .. ' to ' .. string(dst))
    endif
enddef

export def Mkdir(dir: string, bang: bool) #{{{1
    var dest: string = empty(dir)
        ?     expand('%:p:h')
        : dir[0] == '/'
        ?     dir
        :     expand('%:p') .. dir

    try
        mkdir(dest, bang ? 'p' : '')
    catch
        lg.Catch()
    endtry
enddef

export def Move(arg_dst: string, bang: bool) #{{{1
    var src: string = expand('%:p')
    var dst: string = arg_dst->fnamemodify(':p')

    # If the destination is a directory, it must be completed, by appending
    # the current filename.

    #  the destination is an existing directory
    #         |            or a future directory (we're going to create it)
    #  v--------------v    v------------v
    if isdirectory(dst) || dst[-1] == '/'
        #       make sure there's a slash
        #       between the directory and the filename
        #       v-------------------------v
        dst ..= (dst[-1] == '/' ? '' : '/') .. src->fnamemodify(':t')
        #                                      ^--------------------^
        #                                      add the current filename
        #                                      to complete the destination
    endif

    # If the directory of the destination doesn't exist, create it.
    if !dst->fnamemodify(':h')->isdirectory()
        dst->fnamemodify(':h')->mkdir('p')
    endif

    dst = simplify(dst)->substitute('^\.\/', '', '')

    # `:Mv` and `:Rename` should behave like `:saveas`.
    #
    #     :Mv     existing_file    ✘
    #     :Rename existing_file    ✘
    #     :saveas existing_file    ✘
    #
    # The operation shouldn't overwrite the file.
    # Except if we added a bang:
    #
    #     :Mv!     existing_file   ✔
    #     :Rename! existing_file   ✔
    #     :saveas! existing_file   ✔

    # The destination is occupied by an existing file, and no bang was added.
    # The command must fail.
    if filereadable(dst) && !bang
        SaveAs(dst)
        return
    endif

    # Try to rename current file.
    # What are the differences between `:saveas` and `rename()`:
    #
    #    - `rename()` gets rid of the old file, after the renaming; `:saveas` does *not*
    #    - `rename()` can move a file to a different filesystem; `:saveas` ?
    if rename(src, dst) != 0
        # If a problem occurred, inform us.
        Error('Failed to rename ' .. string(src) .. ' to ' .. string(dst))
        return
    endif

    # TODO: Why set the buffer as modified?
    &l:modified = true
    SaveAs(dst)

    # Get rid of old buffer (it's not linked to a file anymore).
    # But only if it's not the current one.
    # It could be the current one if we accidentally execute:
    #
    #     :Mv     /path/to/current/file
    #     :Rename current_filename
    if src != expand('%:p')
        execute 'silent! bwipeout ' .. fnameescape(src)
    endif

    # Rationale:{{{
    #
    # If we change  the filetype of the file (e.g.  `foo.sh` → `foo.py`), we
    # want to load the right filetype/syntax/indent plugins.
    #}}}
    filetype detect
    # re-apply fold settings
    doautocmd <nomodeline> BufWinEnter
enddef

def SaveAs(dst: string)
    # Suppress E139 error: "File is loaded in another buffer"
    # It's given if the name that we pass to `:Rename` matches a Vim buffer.
    if bufloaded(dst)
        execute 'bwipeout ' .. fnameescape(dst)
    endif
    execute 'keepalt saveas! ' .. fnameescape(dst)
enddef

export def Rename(qargs: string, bang: bool) #{{{1
    var curfile: string = expand('%:p')
    var curdir: string = curfile->fnamemodify(':h')
    # We intentionally don't support renaming in a different directory:{{{
    #
    #             ignored
    #             v--v
    #     :Rename a/b/c
    #     ⇔
    #     :Rename c
    #
    # In the past, when we supported this feature, it caused more issues than it
    # helped.  Regularly, we passed a  path expecting only the trailing filename
    # to be  taken into account.  Instead,  the whole path was  used, moving our
    # file  in  a  deeply  nested  subdirectory;  that  was  too  confusing  and
    # cumbersome to fix.
    #}}}
    var fname: string = qargs->fnamemodify(':t')

    if !curfile->filereadable()
        execute $'keepalt file {fname}'
    else
        execute $'Mv{bang ? '!' : ''} {curdir}/{fname}'
    endif
enddef

export def RenameComplete(arglead: string, _, _): string #{{{1
    var prefix: string = expand('%:p:h') .. '/'
    var files: list<string> = glob(prefix .. arglead .. '*', false, true)
        ->map((_, v: string) => v[strcharlen(prefix) :] .. (isdirectory(v) ? '/' : ''))
    return (files + ['../'])->join("\n")
    #                ^---^
    # TODO: How does Vim handle that?
enddef

def ShouldWriteBuffer(seen: dict<bool>): bool #{{{1
    # `'buftype'` is a buffer-local option, whose value determines the type of
    # buffer.  We want to write a  buffer currently displayed in a window, if,
    # and only if:
    #
    #    - it is a regular buffer (&buftype = '')
    #
    #    - an autocmd listening to `BufWriteCmd` determines how it must be
    #      written (&buftype = 'acwrite')

    if !&readonly
    && &modifiable
    && (&buftype == '' || &buftype == 'acwrite')
    && !expand('%')->empty()
    && !seen->has_key(bufnr('%'))
        return true
    endif
    return false
enddef

export def Wall() #{{{1
    var cur_winid: number = win_getid()
    seen = {}
    if !&readonly && !expand('%')->empty()
        seen[bufnr('%')] = true
        write
    endif
    tabdo windo if ShouldWriteBuffer(seen)
        |     write
        |     seen[bufnr('%')] = true
        | endif
    win_gotoid(cur_winid)
enddef

var seen: dict<bool>

def Error(msg: string) #{{{2
    echohl ErrorMsg
    echomsg msg
    echohl NONE
enddef
