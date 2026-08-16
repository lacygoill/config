complete --command=trash --no-files

# subcommands {{{1
# `$ trash empty` {{{2

complete --command=trash \
    --condition='__fish_use_subcommand' \
    --arguments=empty \
    --description='empty trash bin'

# `$ trash list` {{{2

complete --command=trash \
    --condition='__fish_use_subcommand' \
    --arguments=list \
    --description='print contents of trash bin'

# `$ trash put` {{{2

complete --command=trash \
    --condition='__fish_use_subcommand' \
    --arguments=put \
    --description='put file in trash bin'

# `$ trash restore` {{{2

complete --command=trash \
    --condition='__fish_use_subcommand' \
    --arguments=restore \
    --description='restore file from trash bin'
# }}}1
# subcommands arguments {{{1
# `$ trash put <file>` {{{2

complete --command=trash \
    --condition='__fish_seen_subcommand_from put' \
    --force-files
