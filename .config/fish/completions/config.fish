complete --command=config --no-files

# subcommands {{{1
# `$ config add` {{{2

complete --command=config \
    --condition='__fish_use_subcommand' \
    --arguments=add \
    --description='stage changes'

# `$ config commit` {{{2

complete --command=config \
    --condition='__fish_use_subcommand' \
    --arguments=commit \
    --description='commit changes'

# `$ config diff` {{{2

complete --command=config \
    --condition='__fish_use_subcommand' \
    --arguments=diff \
    --description='show unstaged changes'

# `$ config grep` {{{2

complete --command=config \
    --condition='__fish_use_subcommand' \
    --arguments=grep \
    --description='grep for given pattern in all config files'

# `$ config jump` {{{2

complete --command=config \
    --condition='__fish_use_subcommand' \
    --arguments=jump \
    --description='jump to interesting elements in an editor'

# `$ config log` {{{2

complete --command=config \
    --condition='__fish_use_subcommand' \
    --arguments=log \
    --description='show commit logs'

# `$ config ls-files` {{{2

complete --command=config \
    --condition='__fish_use_subcommand' \
    --arguments=ls-files \
    --description='list all version-controlled config files'

# `$ config push` {{{2

complete --command=config \
    --condition='__fish_use_subcommand' \
    --arguments=push \
    --description='stage all changes, commit, push'

# `$ config rm` {{{2

complete --command=config \
    --condition='__fish_use_subcommand' \
    --arguments=rm \
    --description='remove file(s)'

# `$ config status` {{{2

complete --command=config \
    --condition='__fish_use_subcommand' \
    --arguments=status \
    --description='show working tree status'

# `$ config untracked` {{{2

complete --command=config \
    --condition='__fish_use_subcommand' \
    --arguments=untracked \
    --description='list untracked files'
#}}}1
# subcommands arguments {{{1
# `$ config add <file> ...` {{{2

complete --command=config \
    --condition='__fish_seen_subcommand_from add' \
    --force-files

# `$ config diff <file> ...` {{{2

complete --command=config \
    --condition='__fish_seen_subcommand_from diff' \
    --force-files

# `$ config jump <mode>` {{{2

complete --command=config \
    --condition='__fish_seen_subcommand_from jump' \
    --arguments='diff' \
    --description='diff hunks; arguments are given to $ diff --check'

complete --command=config \
    --condition='__fish_seen_subcommand_from jump' \
    --arguments='merge' \
    --description='merge conflicts; arguments are ignored'

complete --command=config \
    --condition='__fish_seen_subcommand_from jump' \
    --arguments='grep' \
    --description='grep hits; arguments are given to git-grep(1)'

complete --command=config \
    --condition='__fish_seen_subcommand_from jump' \
    --arguments='ws' \
    --description='whitespace errors; arguments are given to diff(1)'

# `$ config ls-files --filetype <filetype>` {{{2

complete --command=config \
    --condition='__fish_seen_subcommand_from ls-files && ! __fish_prev_arg_in --filetype' \
    --arguments='--filetype' \
    --require-parameter

complete --command=config \
    --condition='__fish_seen_subcommand_from ls-files && __fish_prev_arg_in --filetype' \
    --arguments='$(jq "keys" $CONFIG_FILETYPES | string replace --all --regex "\W" "")'

# `$ config rm <file> ...` {{{2

complete --command=config \
    --condition='__fish_seen_subcommand_from rm' \
    --arguments='$(config ls-files)'
