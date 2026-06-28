vim9script

compiler shellcheck

# Teardown {{{1

b:undo_ftplugin = (get(b:, 'undo_ftplugin') ?? 'execute')
    .. '| set errorformat< makeprg<'
