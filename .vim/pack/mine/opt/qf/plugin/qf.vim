vim9script noclear

if exists('loaded') | finish | endif
var loaded = true

import autoload '../autoload/qf.vim'
import autoload '../autoload/qf/preview.vim'

# TODO: Implement a mapping/command which would fold all entries belonging to the same file.
# See here for inspiration: https://github.com/fcpg/vim-kickfix

# TODO: Fold invalid entries and/or highlight them in some way.
# Should  we prevent  `qf.Align()`  from trying  to aligning  the  fields of  an
# invalid entry (there's nothing to align anyway...)?

# TODO: Add  custom  syntax highlighting  so  that  entries  from one  file  are
# highlighted  in one  way, while  the next  extries from  a different  file are
# highlighted in another way.
# See here for inspiration: https://github.com/fcpg/vim-kickfix

# TODO: Add a command to sort qf entries in some way?
# Inspiration: https://github.com/vim/vim/issues/6412 (look for `qf#sort#qflist()`)

# TODO: Automatically add a sign for each entry in the qfl.
# Inspiration: https://gist.github.com/BoltsJ/5942ecac7f0b0e9811749ef6e19d2176

# Options {{{1

# don't let the default qf filetype plugin set `'statusline'`, we'll do it ourselves
g:qf_disable_statusline = 1

&quickfixtextfunc = 'qf.Align'

# Commands {{{1

command -bar CFreeStack qf.CfreeStack()
command -bar LFreeStack qf.CfreeStack(true)

# Autocmds {{{1

# Automatically open the qf/ll window after a quickfix command.
augroup MyQuickfix
    autocmd!

    # Do *not* remove the `++nested` flag.{{{
    #
    # Other plugins might need to be informed when the quickfix window is opened.
    # See: https://github.com/romainl/vim-qf/pull/70
    #}}}
    autocmd QuickFixCmdPost * ++nested expand('<amatch>')->qf.OpenAuto()
    #       ^-------------^                    ^------^
    #       after a quickfix command is run    name of the command which was run

    autocmd FileType qf preview.Mappings()
    # I can't find any  event which is late enough for the  context to be set,
    # hence the timer.
    autocmd FileType qf timer_start(0, (_) => qf.Context())
augroup END
