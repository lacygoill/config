complete --command=navi --no-files

# options {{{1

complete --command=navi --long-option=best-match \
    --description='Bypass interactive prompt and output best match'

complete --command=navi --long-option=cheatsh \
    --description='Search for shell snippets using cheat.sh repository'

# `--require-parameter` prevents fish from creating 2 completions instead of 1:
# `--finder` and `--finder=`
complete --command=navi --long-option=finder \
    --description='Finder application to use' \
    --arguments='fzf skim' \
    --require-parameter

complete --command=navi --long-option=fzf-overrides \
    --description='Override options of finder when selecting snippet'

complete --command=navi --long-option=fzf-overrides-var \
    --description='Override options of finder when selecting argument value'

complete --command=navi --long-option=help \
    --short-option=h \
    --description='Print help information'

complete --command=navi --long-option=path \
    --short-option=p \
    --description='Colon-separated list of paths containing .cheat files' \
    --force-files

complete --command=navi --long-option=print \
    --description='Instead of executing snippet, print it to stdout'

complete --command=navi --long-option=query \
    --short-option=q \
    --description='Prepopulate the search field'

complete --command=navi --long-option=tag-rules \
    --description='Comma-separated list of filtering tags: this,or_that,!but_not_this'

complete --command=navi --long-option=tldr \
    --description='Search for shell snippets using the tldr-pages repository'

complete --command=navi --long-option=version \
    --short-option=V \
    --description='Print version information'

# subcommands {{{1

#     $ navi fn
complete --command=navi \
    --condition='__fish_use_subcommand' \
    --arguments=fn \
    --description='Call internal functions'

#     $ navi help
complete --command=navi \
    --condition='__fish_use_subcommand' \
    --arguments=help \
    --description='Print general help or help of given subcommand(s)'

#     $ navi info
complete --command=navi \
    --condition='__fish_use_subcommand' \
    --arguments=info \
    --description='Show info'

#     $ navi repo
complete --command=navi \
    --condition='__fish_use_subcommand' \
    --arguments=repo \
    --description='Manage shell snippet repositories'

#     $ navi widget
complete --command=navi \
    --condition='__fish_use_subcommand' \
    --arguments=widget \
    --description='Output shell widget source code'

# subcommands arguments {{{1

#     $ navi fn ...
complete --command=navi \
    --condition='__fish_seen_subcommand_from fn' \
    --arguments='url::open welcome widget::last_command map::expand'

#     $ navi help ...
complete --command=navi \
    --condition='__fish_seen_subcommand_from help' \
    --arguments='fn help info repo widget'

#     $ navi info ...
complete --command=navi \
    --condition='__fish_seen_subcommand_from info' \
    --arguments='cheats-example cheats-path config-path config-example'

#     $ navi repo ...
complete --command=navi \
    --condition='__fish_seen_subcommand_from repo' \
    --arguments='add browse help'

#     $ navi widget ...
complete --command=navi \
    --condition='__fish_seen_subcommand_from widget' \
    --arguments='bash zsh fish elvish'
