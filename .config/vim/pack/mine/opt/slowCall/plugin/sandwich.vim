vim9script noclear

# Why not moving the code from here to `~/.vim/plugin/sandwich.vim`?{{{
#
# It causes several `autoload/` files to be sourced.  Too slow.
#}}}

if stridx(&runtimepath, '/vim-sandwich,') == -1
    finish
endif

# Highlighting in the delete operator is often distracting.
operator#sandwich#set('delete', 'all', 'highlight', 0)
