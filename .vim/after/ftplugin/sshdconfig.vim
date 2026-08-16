vim9script

&commentstring = '# %s'

compiler sshd

# Teardown {{{1

b:undo_ftplugin = (get(b:, 'undo_ftplugin') ?? 'execute')
    .. '| set commentstring< errorformat< makeprg<'
