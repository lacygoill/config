vim9script

# Options {{{1
# window options {{{2

# TODO: Set them from an autocmd listening to `BufWinEnter`?{{{
#
# ---
#
# `winfixwidth` is not a buffer option.  Move it here?
#
# ---
#
# Review `~/Wiki/vim/todo.md`.
# Did we write that window-local options should be set from an autocmd listening
# to `BufWinEnter`? If not, should we?
#}}}
&l:number = false
&l:relativenumber = false
&l:spell = false
&l:wrap = false

# buffer options {{{2

# TODO: Should we set `'bufhidden'` to `delete`?{{{
#
# If we do it, we lose the ability to retrieve the buffer when pressing `C-^` twice.
# Unless we populate the buffer via an autocmd listening to `BufNewFile`.
# If we don't, then review `~/Wiki/vim/todo.md`.
#
# ---
#
# If you use `delete`, you lose the auto-open-fold feature after pressing `C-^` twice.
# In that case, you should probably set the feature from this filetype plugin.
#}}}
# TODO: Does `'bufhidden'`  have an  influence on  how window-local  options are
# applied when a  cheatkeys buffer is displayed in a  window, while it's already
# displayed somewhere else, or when we press `C-^` twice?
#
# ---
#
# It doesn't seem to cause an issue:
#
#     # press:  C-g C-k
#     # select tmux
#     :setlocal list
#     C-l
#     C-^
#
# `'list'` is set in the second window, even when we use `bufhidden=delete`.

# TODO: What  about moving  the comments  of a  `cheatkeys` file  inside popup
# windows opened dynamically when hovering the relevant line?
&l:bufhidden = 'hide'
&l:buflisted = false
&l:swapfile = false
&l:readonly = true
&l:winfixwidth = true

&l:commentstring = '# %s'
&l:textwidth = 80
# TODO: I *think* the default plugin adds `-`, `/`, and `.` in `'iskeyword'`.
# Should we too?
# }}}1
# Mappings {{{1

nnoremap <buffer><nowait> q <ScriptCmd>quit<CR>

# Teardown {{{1

b:undo_ftplugin = (get(b:, 'undo_ftplugin') ?? 'execute')
    .. '| call cheatkeys#UndoFtplugin()'
