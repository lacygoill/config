vim9script

import autoload '../../autoload/gitcommit.vim'

if expand('<afile>:p')->fnamemodify(':t') == 'COMMIT_EDITMSG'
    gitcommit.SaveNextMessage('OnBufWinLeave')
endif

# Options {{{1

# Highlight the screen column right after `&textwidth`, so that we know when our commit
# message becomes too long.
&l:colorcolumn = '+1'

# Teardown {{{1

b:undo_ftplugin = (get(b:, 'undo_ftplugin') ?? 'execute')
    .. 'set colorcolumn<'
