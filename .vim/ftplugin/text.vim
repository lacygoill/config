vim9script

b:did_ftplugin = true

&l:wrap = true

# Teardown {{{1

b:undo_ftplugin = (get(b:, 'undo_ftplugin') ?? 'execute')
    .. '| set wrap<'
