vim9script

# Rationale:{{{
#
# ATM,  we set  `'termwinkey'` with  the value  `<C-S>` (see  `vim-readline`),
# because we don't use this key in the shell.
#
# However, we  can use `<C-s>` in  an fzf buffer,  to open the path  under the
# cursor in a split; and an fzf buffer is a terminal buffer.
#}}}
&l:termwinkey = ''

b:undo_ftplugin = (get(b:, 'undo_ftplugin') ?? 'execute')
    .. ' | set termwinkey<'
