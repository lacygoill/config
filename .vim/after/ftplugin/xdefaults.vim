vim9script

# Autocmds {{{1

augroup Xdefaults
    autocmd! * <buffer>
    # Remove single quotes as they cause some errors:{{{
    #
    #     # ~/.xsession-errors
    #     /home/lgc/.Xresources:8:8: warning: missing terminating ' character
    #         8 | ! I don't care atm, but if you do later, then redefine the item without `keepend`:
    #           |        ^
    #
    # Those are given by the X server.
    # Same issue when we reload xterm's config via `xrdb(1)`.
    # In practice, these  errors don't seem to cause any  issue, but better be
    # safe than sorry (also, I don't like the noise they create in logs).
    #}}}
    autocmd BufWritePost <buffer> {
        var pos: list<number> = getcurpos()
        silent keepjumps keeppatterns :% substitute/'/ʼ/ge
        setpos('.', pos)
    }
augroup END

# Options {{{1

&l:commentstring = '! %s'

# Teardown {{{1

b:undo_ftplugin = (get(b:, 'undo_ftplugin') ?? 'execute')
    .. '| set commentstring<'
    .. '| execute "autocmd! Xdefaults * <buffer>"'
