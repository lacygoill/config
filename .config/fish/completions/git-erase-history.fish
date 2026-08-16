complete --command=git-erase-history --no-files

# subcommands {{{1
# `$ git-erase-history config` {{{2

complete --command=git-erase-history \
    --condition='__fish_use_subcommand' \
    --arguments=config \
    --description='erase git history of config repository'

# `$ git-erase-history repo` {{{2

complete --command=git-erase-history \
    --condition='__fish_use_subcommand' \
    --arguments=repo \
    --description='erase git history of current regular repository'
