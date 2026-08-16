vim9script

import '../import/weechat.vim'

b:did_ftplugin = true

&l:commentstring = '# %s'

weechat.HighlightColorValues()

# Teardown {{{1

b:undo_ftplugin = (get(b:, 'undo_ftplugin') ?? 'execute')
    .. '| set commentstring<'
