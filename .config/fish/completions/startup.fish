complete --command=startup --no-files

# `$ startup fish` {{{1

complete --command=startup \
    --condition='__fish_use_subcommand' \
    --arguments=fish \
    --description='fish shell'

# `$ startup vim` {{{1

complete --command=startup \
    --condition='__fish_use_subcommand' \
    --arguments=vim \
    --description='vim text editor'
