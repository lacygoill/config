vim9script

&l:shiftwidth = 2

compiler luacheck

# Teardown {{{1

b:undo_ftplugin = (get(b:, 'undo_ftplugin') ?? 'execute')
    .. '| set errorformat< makeprg< shiftwidth<'
