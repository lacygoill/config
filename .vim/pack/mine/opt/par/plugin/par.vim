vim9script noclear

if exists('loaded') | finish | endif
var loaded = true

import autoload '../autoload/par.vim'

# TODO: Shouldn't we rename the plugin `vim-format`?

# Mappings {{{1
# gq {{{2

nnoremap <expr><unique> gq par.Op()
xnoremap <expr><unique> gq par.Op()

# gqq {{{2

nmap <unique> gqq gq_

# gqs {{{2

nnoremap <expr><unique> gqs par.RemoveDuplicateSpaces() .. '_'
# }}}1
# Options {{{1
# formatprg {{{2

# `par(1)` is more powerful than Vim's internal formatting function.
# The latter has several drawbacks:
#
#    - it uses a greedy algorithm, which makes it fill a line as much as it
#      can, without caring about the discrepancies between the lengths of
#      several lines in a paragraph
#
#    - it doesn't handle well multi-line comments, (like /* */)
#
# So, when hitting `gq`, we want `par` to be invoked.

# By   default,   `par`   reads   the  environment   variable   `PARINIT`   to
# set   some    of   its   options.     Its   current   value   is    set   in
# `~/.config/fish/conf.d/environment.fish` like this:
#
#     rTbgqR B=.,?_A_a Q=_s>|

augroup formatprg
    autocmd!
    #                                                          ┌ no line bigger than 80 characters in the output paragraph{{{
    #                                                          │
    #                                                          │  ┌ fill empty comment lines with spaces (e.g.: /*    */)
    #                                                          │  │
    #                                                          │  │┌ justify the output so that all lines (except the last)
    #                                                          │  ││ have the same length, by inserting spaces between words
    #                                                          │  ││
    #                                                          │  ││┌ delete (expel) superfluous lines from the output
    #                                                          │  │││
    #                                                          │  │││┌ handle nested quotations, often found in the
    #                                                          │  ││││ plain text version of an email}}}
    autocmd FileType * &l:formatprg = $'par -w{&l:textwidth ?? 80}rjeq'
augroup END

# formatoptions {{{2

# 'formatoptions' handles the automatic formatting of text.
#
# I  don't   use  them,  but  the   `c`  and  `t`  flags   control  whether  Vim
# auto-wrap  Comments (using  textwidth,  inserting the  current comment  leader
# automatically), and Text (using textwidth).

# If:
#    1. we're in normal mode, on a line longer than `&l:textwidth`
#    2. we switch to insert mode
#    3. we insert something at the end
#
# ... don't break the line automatically
&formatoptions = 'l'

#                  ┌ insert comment leader after hitting o O in normal mode, from a commented line
#                  │┌ same thing when we hit Enter in insert mode
#                  ││
set formatoptions+=or

#                  ┌ don't break a line after a one-letter word
#                  │┌ where it makes sense, remove a comment leader when joining lines
#                  ││
set formatoptions+=1jnq
#                    ││
#                    │└ allow formatting of comments with "gq"
#                    └ when formatting text, use 'formatlistpat' to recognize numbered lists

# Don't insert  the comment leader  after pressing `o` on  a line ending  with a
# `//` inline comment.
set formatoptions+=/

augroup FormatoptionsSameEverywhere
    autocmd!
    # We've configured the global value of 'formatoptions'.
    # Do the same for its local value in ANY filetype.
    autocmd FileType * &l:formatoptions = &g:formatoptions
augroup END
