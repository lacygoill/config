vim9script noclear

if exists('loaded') | finish | endif
var loaded = true

import 'lg.vim'
import autoload '../autoload/terminal.vim'
import autoload '../autoload/terminal/togglePopup.vim'
import autoload '../autoload/terminal/unnest.vim'

# FAQ {{{1
# How to change the function name prefix `Tapi_`? {{{2
#
# Use the `term_setapi()` function.
#
#     term_setapi(buf, 'Myapi_')
#                 ^^^
#                 number of terminal buffer for which you want to change the prefix
#
# Its effect  is local  to a given  buffer, so if  you want  to apply it  to all
# terminal buffers, you'll need an autocmd.
#
#     autocmd TerminalWinOpen * expand('<abuf>')->str2nr()->term_setapi('Myapi_')
#}}}1

# Mappings {{{1

# Why not `C-g C-g`?{{{
#
# It would interfere with our zsh snippets key binding.
#}}}
# And why `C-g C-j`?{{{
#
# It's easy to press with the current layout.
#}}}
# Why do you use a variable?{{{
#
# To have the guarantee to always be  able to toggle the popup from normal mode,
# *and* from Terminal-Job mode with the same key.
# Have a look at `TerminalJobMapping()` in `autoload/terminal/toggle_popup.vim`.
#}}}
g:_termpopup_lhs = '<C-G><C-J>'
execute 'nnoremap <unique> ' .. g:_termpopup_lhs .. ' <ScriptCmd>togglePopup.Main()<CR>'

# Options {{{1

# When in a terminal buffer, whenever the shell's CWD changes, sync it with Vim's CWD.{{{
#
# For the  feature to work,  you also  need to configure  your shell so  that it
# sends an OSC 7 sequence to the Vim job whenever its CWD changes.
# See `:help 'autoshelldir'`
#}}}
&autoshelldir = true

# What does `'termwinkey'` do?{{{
#
# It controls which key can be pressed to issue a command to Vim rather than the
# foreground shell process in the terminal.
#}}}
# Why do yo change its value?{{{
#
# By default,  its value is  `<C-W>`; so  you can press  `C-w :` to  enter Vim's
# command-line; but I don't like that `C-w` should delete the previous word.
#}}}
# Warning: do *not* use `C-g`{{{
#
# If you do, when we want to use one of our zsh snippets, we would need to press
# `C-g` 4 times instead of twice.
#}}}
&termwinkey = '<C-S>'

# Hard-wrap as few long lines as possible.{{{
#
# Notably, this is useful when we pipe the output of `less(1)` to Vim, and the
# former contains ANSI escape codes (see our `ParseAnsiEscapeCodes` autocmd).
#
# ---
#
# Ideally, instead of  1000, we could write something like  `-1` for infinity;
# but 1000 is the maximum valid value.
#
#                                          v--v
#     :vim9 term_start('true', {term_cols: 1001})
#     E475: Invalid value for argument term_cols
#           ^-----^
#
# ---
#
# To join back broken lines in a tree-like output (e.g. `systemd-cgls(1)`):
#
#     :global /^│.*\n[^│├└]/ :.,/[^│├└]/-1 join!
#}}}
&termwinsize = '0*1000'

# Autocmds {{{1

augroup MyTerminal
    autocmd!
    autocmd TerminalWinOpen * terminal.Setup()
augroup END

# Why do you install a mapping whose LHS is `Esc Esc`?{{{
#
# In Vim, we can't use `Esc` in the  LHS of a mapping, because any key producing
# a sequence  of key codes  containing `Esc`, would  be subject to  an undesired
# remapping (`M-b`, `M-f`, `Left`, `Right`, ...).
#
# Example:
# `M-b` produces `Esc` (enter Terminal-Normal mode) + `b` (one word backward).
# We *do* want to go one word backward, but we also want to stay in Terminal-Job
# mode.
#}}}
# Why do you use an autocmd and buffer-local mappings?{{{
#
# When fzf opens a terminal buffer, we don't want our mapping to be installed.
#
# Otherwise,  we need  to press  Escape  twice, then  press `q`;  that's 3  keys
# instead of one single Escape.
#
# We need our `Esc  Esc` mapping in all terminal buffers,  except the ones whose
# filetype is fzf; that's why we use a buffer-local mapping (when removed,
# it only affects the current buffer), and that's why we remove it in an autocmd
# listening to `FileType fzf`.
#}}}
# TODO: Find a way to send an Escape key to the foreground program running in the terminal.{{{
#
# Maybe something like this:
#
#     execute "set <M-[>=\<Esc>["
#     tnoremap <M-[> <Esc>
#
# It doesn't work, but you get the idea.
#}}}
augroup InstallEscapeMappingInTerminal
    autocmd!
    # Do *not* install this mapping:  `tnoremap <buffer> <Esc>: <C-\><C-N>:`{{{
    #
    # Watch:
    #
    #     z<      open a terminal
    #     Esc :   enter command-line
    #     Esc     get back to terminal normal mode
    #     z>      close terminal
    #
    # The meta keysyms are disabled.
            # }}}
    autocmd TerminalWinOpen * tnoremap <buffer><nowait> <Esc><Esc> <C-\><C-N>
    autocmd TerminalWinOpen * tnoremap <buffer><nowait> <C-\><C-N> <C-\><C-N>
    autocmd FileType fzf silent! tunmap <buffer> <Esc><Esc>
augroup END

# We sometimes – accidentally – start a nested Vim instance inside a Vim terminal.
# Let's fix this by re-opening the file(s) in the outer instance.
if !empty($VIM_TERMINAL)
    # Why delay until `VimEnter`?{{{
    #
    # During my limited tests, it didn't  seem necessary, but I'm concerned that
    # Vim hasn't loaded the file yet when this plugin is sourced.
    #
    # Also, without the  autocmd, sometimes, a bunch of empty  lines are written
    # in the terminal.
    #}}}
    autocmd VimEnter * unnest.Main()
endif

# Functions {{{1
# Interface {{{2
# Warning: Do *not* create a `g:Tapi_exe()` function which would be able to execute an arbitrary Ex command.{{{
#
# It  would allow  the shell  to make  Vim  run anything  it wants,  which is  a
# security risk.
#}}}

def g:Tapi_drop(_, file_listing: string) #{{{3
    # Open a file in the *current* Vim instance, rather than in a nested one.{{{
    #
    # The function  is called  automatically by  `unnest.Main()` if  Vim detects
    # that it's running inside a Vim terminal.
    #
    # Useful to avoid  the awkward user experience inside a  nested Vim instance
    # (and all the pitfalls which come with it).
    #}}}
    var files: list<string>
    if empty(file_listing)
        return
    endif
    files = readfile(file_listing)
    if empty(files)
        return
    endif
    try
        if win_gettype() == 'popup'
            win_getid()->popup_close()

            var is_first_file_displayed: bool = !files[0]
                ->bufnr()
                ->win_findbuf()
                ->empty()
            # don't hide the current buffer
            if !is_first_file_displayed
                split
            endif
        endif
        execute 'drop ' .. files
            ->map((_, v: string) => fnameescape(v))
            ->join()
    # `E994`, `E863`, ...
    catch
        lg.Catch()
    endtry
enddef

def g:Tapi_man(_, page: string) #{{{3
    # open man page in outer Vim
    if exists(':Man') != 2
        echomsg ':Man needs to be installed'
        return
    endif
    try
        execute 'tab Man ' .. page
    catch
        lg.Catch()
    endtry
enddef

def g:Tapi_unnest() #{{{3
    doautocmd <nomodeline> StdinReadPost
enddef

#}}}2
