vim9script

b:compilers = ['pylint', 'mypy', 'black']

# preserve the currently chosen compiler across buffer reloads
if b:compilers->index(&l:makeprg->matchstr('\S\+')) == -1
    compiler pylint
endif

# Teardown {{{1

b:undo_ftplugin = (get(b:, 'undo_ftplugin') ?? 'execute')
    .. '| unlet! b:compilers'
    .. '| set errorformat< makeprg<'
