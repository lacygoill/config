complete --command=frec --no-files

# short options {{{1

complete --command=frec --short-option=f --exclusive --description='match files only'
complete --command=frec --short-option=d --exclusive --description='match directories only'
complete --command=frec --short-option=l --exclusive --description='list all paths from database'
# TODO: We should disallow meaningless suggestions such as `-ed`, `-ef`, `-el`.
# But we can't use `--exclusive`: it  would prevent `editor` and `xdg-open` from
# being suggested after `-e`.
complete --command=frec --short-option=e --description='run given command on chosen path'

# long options {{{1

complete --command=frec --long-option=clean --description='remove stale paths from database'
complete --command=frec --long-option=add --description='add given path(s) into database'
complete --command=frec --long-option=delete --description='remove given path(s) from database'

# option arguments {{{1

# frecent files anywhere after `frec -f`
complete --command=frec \
    --condition='__fish_contains_opt -s f && ! __fish_prev_arg_in -e' \
    --arguments='$(frec -l -f)'

# frecent directories anywhere after `frec -d`
complete --command=frec \
    --condition='__fish_contains_opt -s d && ! __fish_prev_arg_in -e' \
    --arguments='$(frec -l -d)'

# `editor` and `xdg-open` after `-e`
complete --command=frec \
    --condition='__fish_prev_arg_in -e' \
    --arguments='editor xdg-open'

# Useful to open file in current directory, even if frec never saw it before:{{{
#
#     $ frec -f -e xdg-open ./<Tab>
#
# The benefit over a bare `xdg-open`, is that frec will now remember the file.
# Next time, you won't need `./`.
#}}}
complete --command=frec \
    --condition='__fish_prev_arg_in editor xdg-open && _complete_current_arg_starts_with \./' \
    --force-files

# files after `--add`
complete --command=frec --condition='__fish_prev_arg_in --add' --force-files

# frecent paths after `--delete`
complete --command=frec \
    --condition='__fish_prev_arg_in --delete' \
    --arguments='$(frec -l)'
