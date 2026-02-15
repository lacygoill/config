vim9script noclear

if exists('loaded') | finish | endif
var loaded = true

import autoload '../autoload/iabbrev.vim'

const AUTOLOAD_FILE: string = expand('<sfile>')->fnamemodify(':h:h') .. '/autoload/iabbrev.vim'

# Mappings {{{1

# We need a mapping instead of an `InsertCharPre` autocmd.{{{
#
# When we  press `<Space>`,  `InsertCharPre` is fired  right before  the space
# character is inserted, but *after* the abbreviation has been expanded.
# As  a result,  it's too  late  to determined  whether  we forgot  to use  an
# abbreviation.
#}}}
inoremap <expr><unique> <Space> iabbrev.Space()

# Only expand an abbreviation after we press `<Space>`.
# Expanding when we quit insert mode  is too unexpected, in particular when we
# write code.
inoremap <unique><expr> <Esc> v:count1 > 1 ? '<Esc>' : '<C-\><C-N>'
#                                            ^-----^
#                                               |
# But don't break  the repetition of an  insertion via a count  in normal mode
# (e.g. `3iword<Escape>`).

# `:help i^]` doesn't always work.
# For example, if the abbreviation was  not expanded when it was inserted, and
# you press `<C-]>` after quitting/re-entering insert mode.  Let's fix that.
inoremap <expr><unique> <C-]> iabbrev.ForceExpansion()

# Autocmds {{{1

augroup MyAbbreviations
    autocmd!
    # to install our digraphs immediately
    autocmd InsertEnter * ++once execute $'source {AUTOLOAD_FILE}'

    autocmd InsertCharPre * {
        # if the  inserted char  is a  keyword character,  there can't  be any
        # abbreviation expansion; no need to do anything
        if v:char !~ '\k'
                # we probably don't  need these functions to be  run when keys
                # are pressed from  the RHS of a mapping;  the less frequently
                # we  run this  code, the  lower  the risk  we encounter  some
                # unexpected side-effect
                && state() !~ 'm'
            iabbrev.SuppressUnexpectedExpansion()
        endif
    }
augroup END
