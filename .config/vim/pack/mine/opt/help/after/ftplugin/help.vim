vim9script

import autoload '../../autoload/help.vim'

# Mappings {{{1

# avoid error `E21` when pressing `p` by accident
nnoremap  <buffer><nowait> p <ScriptCmd>help.PreviewTag()<CR>
xnoremap  <buffer><nowait> p <Nop>
nmap <buffer><nowait> q <Plug>(my-quit)
nnoremap  <buffer><nowait> u <Nop>

nnoremap <buffer><nowait> <CR> <C-]>
nnoremap <buffer><nowait> <BS> <C-T>

nnoremap <buffer><nowait> ( <ScriptCmd>help.JumpToTag('hypertext', 'previous')<CR>
nnoremap <buffer><nowait> ) <ScriptCmd>help.JumpToTag('hypertext', 'next')<CR>
# double the angle brackets to not conflict with global mappings starting with `>`, `<`
nnoremap <buffer><nowait> << <ScriptCmd>help.JumpToTag('option', 'previous')<CR>
nnoremap <buffer><nowait> >> <ScriptCmd>help.JumpToTag('option', 'next')<CR>
nnoremap <buffer><nowait> z} <C-W>z<C-W>_

# Options {{{1
# buffer-local {{{2

# don't comment a diagram
&l:commentstring = ''

# Do *not* alter `'iskeyword'`.{{{
#
# It's too tricky to do it reliably.
# If you try, test your code in these situations:
#
#     $ vim +help +edit
#     $ vim +'help' +'edit | close | help'
#
# Check that the option is set as you expect.
# If it's  not, you'll  probably get  a red  flag in  the statusline  because we
# monitor the option in our `statusline` plugin.
#
# ---
#
# The reason why it's tricky is because Vim automatically sets the option (along
# with a few others) at a late stage (including after the `FileType` event).
# From `:help help-buffer-options`:
#
#    > When the help buffer is created, several local options are set to make sure
#    > the help text is displayed as it was intended:
#    >     'iskeyword'		nearly all ASCII chars except ' ', '*', '"' and '|'
#    >...
#
# To do  it reliably, you would  need to set  it directly from this  script, and
# from an autocmd listening to `BufWinEnter`.
#
# ---
#
# The default value (hard-coded in Vim's C source code) is `!-~,^*,^|,^",192-255`:
#
#     $ vim -es -Nu NONE -i NONE +'help pattern' +'set verbose=1 | echomsg &l:iskeyword | qa!'
#     !-~,^*,^|,^",192-255
#
# Except in the main help file, *if* you have let the modline mechanism enabled.
# In which case, the bottom modeline reset the option to `!-~,^*,^|,^"`.
#}}}

# default program to call when pressing `K` on a word
&l:keywordprg = ':help'

# Make sure the text is correctly aligned.
&l:tabstop = 8

# default value in the modeline of Vim help files
&l:textwidth = 78

# window-local {{{2

augroup MyHelpWindow
    autocmd! * <buffer>
    # Make sure the conceal feature works as expected no matter what.{{{
    #
    # Most of the  time, a help buffer  is loaded by a `:help`  command, but not
    # necessarily.  For example, our `<Space>U` mapping (which restores a closed
    # window) simply executes `:buffer 123`.  And without `:help`, `FileType` is
    # not fired.
    #
    # ---
    #
    # Also, in  the past, I  think we had issues  when we re-displayed  the same
    # help buffer in a 2nd window.
    #}}}
    autocmd BufWinEnter <buffer> &l:concealcursor = 'nc' | &l:conceallevel = 3

    # Why resetting these options to their default values in a popup?  Doesn't Vim do it automatically?{{{
    #
    # Apparently, not always.
    #
    #     $ vim -Nu NONE \
    #         +'set signcolumn=yes previewpopup=height:10,width:60' \
    #         +help \
    #         +'call search("bar")' \
    #         +'wincmd }'
    #}}}
    autocmd BufWinEnter <buffer> {
        if win_gettype() == 'popup'
            setlocal signcolumn&vim wrap&vim conceallevel&vim
        endif
    }
augroup END
#}}}1
# Teardown {{{1

b:undo_ftplugin = (get(b:, 'undo_ftplugin') ?? 'execute')
    .. '| call help#UndoFtplugin()'
