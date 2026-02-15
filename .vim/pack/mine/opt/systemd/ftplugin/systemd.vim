vim9script

b:did_ftplugin = true

import autoload '../autoload/systemd.vim'

# The default plugin actually loads the dosini settings:{{{
#
#     # $VIMRUNTIME/ftplugin/systemd.vim
#     runtime! ftplugin/dosini.vim
#
# The latter is short and sets `;` as the comment leader.
# Technically, that's not wrong, but in practice, `#` is used more often.
#
#     # $VIMRUNTIME/ftplugin/dosini.vim
#}}}
&l:commentstring = '# %s'
&l:omnifunc = systemd.Complete

# We need to set a compiler for our custom lints to be used when we press `|c`.
compiler none

# Teardown {{{1

b:undo_ftplugin = (get(b:, 'undo_ftplugin') ?? 'execute')
    .. '| set commentstring< errorformat< makeprg< omnifunc<'
