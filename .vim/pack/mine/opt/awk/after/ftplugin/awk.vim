vim9script

import autoload '../../autoload/awk.vim'

# Options {{{1

&l:omnifunc = awk.Complete
&l:shiftwidth = 2
&l:textwidth = 80

compiler awk

# Variables {{{1

b:mc_chain =<< trim END
    file
    omni
    keyn
    tags
    ulti
    abbr
    C-n
    dict
END

# Teardown {{{1

b:undo_ftplugin = (get(b:, 'undo_ftplugin') ?? 'execute')
    .. '| set errorformat< makeprg< omnifunc< shiftwidth< textwidth<'
    .. '| unlet! b:mc_chain'
