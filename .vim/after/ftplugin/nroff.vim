vim9script

&l:commentstring = '.\" %s'
# necessary to make Vim auto-insert the comment leader when we open a new line
&l:comments = ':.\"'

# Teardown {{{1

b:undo_ftplugin = (get(b:, 'undo_ftplugin') ?? 'execute')
    .. '| set commentstring< comments<'
