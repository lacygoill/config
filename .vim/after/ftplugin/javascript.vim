vim9script

# Options {{{

&l:formatprg = 'js-beautify'

# Teardown {{{1

b:undo_ftplugin = (get(b:, 'undo_ftplugin') ?? 'execute')
    .. '| set formatprg<'
