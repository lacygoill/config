vim9script

b:did_ftplugin = true

if expand('%:t') == 'redshift.conf'
    setlocal commentstring=;\ %s
    # So that a comment leader is automatically inserted when we press the `o`
    # normal command to open a new commented line.
    setlocal comments=b:;
else
    setlocal commentstring=#\ %s
endif

b:undo_ftplugin = (get(b:, 'undo_ftplugin') ?? 'execute')
    .. '| set comments< commentstring<'
