vim9script

if expand('%:p') =~ $'^{$HOME}/Wiki/C/'
    compiler gcc
    &l:makeprg = 'gcc -o /dev/null $GCC_OPTS %s'
endif

# When indenting a label statement, use the prevailing indent.
# Otherwise, a label statement would always be indented back to column 1.
&l:cinoptions = 'L0'

# Why not `/*%s*/`?{{{
#
# It would add too much complexity  in our syntax comment customizations, and in
# `vim-comment`; not worth the effort.
#}}}
&l:commentstring = '// %s'

# Teardown {{{1

b:undo_ftplugin = (get(b:, 'undo_ftplugin') ?? 'execute')
    .. '| set cinoptions< commentstring< errorformat< makeprg<'
