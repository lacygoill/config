vim9script

# Options {{{1

&l:formatprg = 'js-beautify --css'

# google style guide
&l:shiftwidth = 2

# Variables {{{1

b:mc_chain =<< trim END
    file
    omni
    keyn
    ulti
    abbr
    C-n
    dict
END

# Teardown {{{1

b:undo_ftplugin = (get(b:, 'undo_ftplugin') ?? 'execute')
    .. '| set formatprg< shiftwidth< | unlet! b:mc_chain'
