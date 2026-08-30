vim9script noclear

if exists('loaded') | finish | endif
var loaded = true

# Options {{{1

# What does `'autoread'` do?{{{
#
# When  a file  is detected  to have  been changed  outside of  the current  Vim
# instance but not changed inside the latter, automatically read it again.
# Basically, it answers `Yes`, to the question where we usually answer `Load`.
#}}}
# When does Vim check whether a file has been changed outside the current instance?{{{
#
# In the terminal, when you:
#
#    - try to write the buffer
#    - execute a `:!` command
#    - execute `:checktime`
#    (without argument or with an argument matching the changed file)
#
# Also when you give  the focus to a Vim instance where the  file is loaded; but
# only in  the GUI,  or in a  terminal which supports  the focus  event tracking
# feature, such as xterm (and if `'t_fd'` and `'t_fe'` are correctly set).
# See `:help xterm-focus-event`.
#}}}
&autoread = true

# Autocmds {{{1

augroup HoistNas
    autocmd!
    autocmd User MyFlags g:StatusLineFlag('global',
        \ '%{!exists("#AutoSaveAndRead") ? "[NAS]" : ""}', 7, expand('<sfile>:p') .. ':' .. expand('<sflnum>'))
augroup END

augroup MyChecktime
    autocmd!
    # Why `InsertEnter`?{{{
    #
    # The autocmd is adapted from blueyed's vimrc.
    #
    # I guess it makes sense because when  you're about to insert some text, you
    # want to be  sure you're editing the  most recent version of  the file, and
    # not an old one.  Editing an old one would cause a conflict when you'll try
    # to save the buffer.
    #}}}
    autocmd BufEnter,CursorHold,InsertEnter * ++nested AutoChecktime()
augroup END

# Functions {{{1
def SaveBuffer() #{{{2
    # Can't go back to old saved states with undotree mapping `}` if we save automatically.{{{
    #
    # If you  disable this `if`  block, when  you press `}`  to get back  to old
    # saved states,  you'll probably be  stuck in a  loop which includes  only 2
    # states, the last one and the last but one.
    #}}}
    if tabpagebuflist()
     ->map((_, v: number): string => bufname(v))
     ->match('^undotree_\d\+') >= 0
        return
    endif

    # Don't try to use `expand('<abuf>')`.
    # `:update` only works on the current buffer anyway.
    if &readonly
        || bufname('%') == ''
        || &buftype != ''
        return
    endif

    # Don't replace this `try/catch` with `silent!`.{{{
    #
    # `silent!` can lead to weird issues.
    #
    # For  example, once  we had  an issue  where a  regular buffer  was wrongly
    # transformed into a qf buffer: https://github.com/vim/vim/issues/7352
    #}}}
    try
        silent lockmarks update
    # Vim(update):E505: "/path/to/file/owned/by/root" is read-only (add ! to override)
    catch /^Vim\%((\a\+)\)\=:E505:/
        # let's ignore this error
    catch
        echohl ErrorMsg
        echomsg v:exception
        echohl NONE
    endtry
enddef

def IsRecoveringSwapfile(): bool #{{{2
    silent return v:argv->index('-r') >= 0
enddef

def g:SaveToggleAuto(enable = false) #{{{2
    if enable && !exists('#AutoSaveAndRead')
        augroup AutoSaveAndRead
            autocmd!
            # Save current buffer if it has been modified.
            # Warning: Do *not* delay `SaveBuffer()` with a timer.{{{
            #
            # Even if you have an issue for which delaying seems like a good fix.
            #
            # If you do use a timer, and:
            #
            #    1. the current buffer A is modified
            #    2. you press `]q` to move to the next entry in the qfl
            #    3. you end up in a new buffer B
            #
            # The buffer A won't be saved.
            #
            # But we could wrongly think that it has, and commit the old version
            # of A: this would make us lose all the changes we did in A.
            #}}}
            # Could `nested` be useful here?{{{
            #
            # It could when  you modify your vimrc, and you  want the changes to
            # be sourced automatically.
            # More  generally,  it  could  be  useful  when  you  have  autocmds
            # listening to `BufWritePre` or `BufWritePost`.
            #}}}
            # Why `++nested`?{{{
            #
            # It can help fix a bug in `vim-repeat`:
            #
            #     $ vim -Nu <(tee <<'EOF'
            #         vim9script
            #         silent edit /tmp/file2
            #         :% delete
            #         ['abcdef', 'abcdef']->setline(1)
            #         silent vsplit /tmp/file1
            #         :% delete
            #         ['abcdef', 'abcdef']->setline(1)
            #         windo :1
            #         set updatetime=1000
            #         autocmd CursorHold * update
            #         set runtimepath-=~/.vim
            #         set runtimepath-=~/.vim/after
            #         set runtimepath^=~/.vim/pack/mine/opt/repeat
            #         set runtimepath^=~/.vim/pack/vendor/opt/vim-sneak
            #     EOF
            #     )
            #     # press: dzcd j
            #     # wait for 'CursorHold' to be fired, and ':update' to be run
            #     # press: .
            #     # vim-sneak asks you for a pair of characters – again
            #     # it should not; it should automatically re-use the last one
            #
            # See: https://github.com/tpope/vim-repeat/issues/59#issuecomment-402012147
            #}}}
            autocmd BufLeave,CursorHold,WinLeave,FocusLost * ++nested SaveBuffer()
        augroup END

    elseif !enable && exists('#AutoSaveAndRead')
        autocmd! AutoSaveAndRead
        augroup! AutoSaveAndRead
    endif
    # We have a flag in the tab line; we want it to be updated immediately.
    if v:vim_did_enter
        redrawtabline
    endif
enddef

def AutoChecktime() #{{{2
    var abuf: number = expand('<abuf>')->str2nr()
    var name: string = bufname(abuf)
    if name == ''
    || getbufvar(abuf, '&buftype', '') != ''
    # to avoid:  E211: File "..." no longer available
    || !name->filereadable()
        return
    endif
    # What does it do?{{{
    #
    # Check whether  the current file has  been modified outside of  Vim.  If it
    # has, Vim will automatically re-read it because we've set 'autoread'.
    #
    # A modification  does not necessarily  involve the *contents* of  the file.
    # Changing its *permissions* is *also* a modification.
    #}}}
    #   Why `abuf`?{{{
    #
    # This function  will be  called frequently,  and if  we have  many buffers,
    # without specifiying a  buffer, Vim would check *all*  buffers.  This could
    # be too time-consuming.
    #}}}
    execute ':' .. abuf .. 'checktime'
enddef
# }}}1
# Mappings {{{1

nnoremap <unique> <C-S> <ScriptCmd>SaveBuffer()<CR>
nnoremap <unique> [o<C-S> <ScriptCmd>g:SaveToggleAuto()<CR>
nnoremap <unique> ]o<C-S> <ScriptCmd>g:SaveToggleAuto(true)<CR>
nnoremap <unique> co<C-S> <ScriptCmd>g:SaveToggleAuto(!exists('#AutoSaveAndRead'))<CR>
# }}}1

# Enable the automatic saving of a buffer.
# But not when we're trying to recover a swapfile.{{{
#
# When  we're trying  to recover  a swapfile,  we don't  want the  recovered
# version to automatically overwrite the original file.
#
# We prefer to save it in a temporary file, and diff it against the original
# to check that the  recovered version is indeed newer, and  that no line is
# missing.
#}}}
if !IsRecoveringSwapfile()
    g:SaveToggleAuto(true)
endif
