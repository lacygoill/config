vim9script

&l:commentstring = '# %s'

compiler desktop-file-validate

# Teardown {{{1

b:undo_ftplugin = (get(b:, 'undo_ftplugin') ?? 'execute')
    .. '| set commentstring< makeprg<'
