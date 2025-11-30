# Config {{{1

# Don't try to `--add` too many paths; it could slow down the shell, and add too
# much  noise in  frec  DB (e.g.  copy-pasting  a huge  command  with many  file
# arguments).
set _FREC_ADD_MAX 10

# We need to ignore any `frec` command.{{{
#
# For example, if we run:
#
#     $ frec --add /a/b/c
#
# There is no point in adding `/a/b/c` to the database from a fish hook.
# The `frec --add` command executed interactively is already going to do that.
#
# And if we run:
#
#     $ frec --delete /a/b/c
#
# We don't want the fish hook to add `/a/b/c` back again into the database.
#
# ---
#
# Note that we do want to add `/a/b/c` when we run:
#
#     $ frec -e xdg-open /a/b/c
#
# But we already take care of that in the `frec` script.
#}}}
# Similar thing for `frec-cd`{{{
#
# The latter is a fish function which calls the `frec` script:
#
#     set -f dir $(frec -d -e 'printf %s' $query)
#                  ^--^
#
# In the end, this invocation will `--add` the directory in which we jump:
#
#     for needle in $needles; do
#       ${cmd:-printf '%s\n'} "$needle"
#       frec --add "$needle"
#       ^------------------^
#     done
#}}}
set _FREC_CMD_IGNORED 'frec frec-cd echo ls touch'

# Abbreviations {{{1

abbr --add e 'frec -f -e editor'
abbr --add o 'frec -f -e xdg-open'

abbr --add j 'frec-cd'

# Hook {{{1

function _frec_process_paths --on-event=fish_postexec
# Every time a shell command is  run interactively, this function should extract
# file/directory paths from it, and add them to frec DB.
# It's passed the executed command as `$argv`.

    set -f higher_order_cmd 'env sudo'

    set -f tokens $(string split -- ' ' $argv)
    while string match --quiet -- "* $tokens[1] *" " $higher_order_cmd "
        set --erase tokens[1]
    end
    set -f cmd $tokens[1]

    # Only remember the most meaningful interactions with files/directories.
    if string match --quiet -- "* $cmd *" " $_FREC_CMD_IGNORED "
        return
    end

    # In the collection inside the pattern of the grep command, we need to ignore a single quote.{{{
    #
    # Otherwise:
    #
    #                                       necessary to reproduce the issue
    #                                       v     v
    #     $ abbr --show | string replace -- '--pos' ''
    #     ...
    #     frec: unrecognized option '--pos'
    #
    # MRE:
    #
    #     $ getopt --options= --long=add: -- --add string --pos
    #     getopt: unrecognized option '--pos'
    #      --add 'string' --
    #}}}
    set -f args $(
        printf '%s' $argv \
        | fish_indent --dump-parse-tree 2>&1 \
        | grep '^[! ]*argument: '\''[^-'\'']' \
        | string match --regex "'.*'" \
        | string trim --chars="'" \
    )

    if test "$(count $args)" -gt $_FREC_ADD_MAX \
            || test "$(count $args)" -eq 0
        return
    end

    # There is no guarantee that `$args` contain actual file/directory paths.
    # We rely on `frec --add` sanitizing the input.{{{
    #
    # You could test whether it's a path:
    #
    #     if test -f "$arg" || test - "$arg"
    #
    # But it would  fail if `$arg` contains special characters  which need to be
    # expanded (like `~`  or `$HOME`).  To force an expansion,  you could try to
    # `eval` the argument:
    #
    #     eval set -f arg $arg
    #
    # But evaluating arbitrary text is too dangerous.
    # Anyway, `frec --add` already does its best to tackle this issue.
    #}}}
    frec --add $args
    # Don't write `--` before `$args`; it's useless.{{{
    #
    #     frec --add -- $args
    #                ^^
    #                ✘
    #
    # The purpose of `--` is to separate optional arguments from positional ones.
    # But `frec` already deals with this issue when it calls `getopt(1)`.
    # Besides, it would  create a bit of noise when  debugging, because it would
    # add an extra `--` argument.  There is already one because of this:
    #
    #     eval set -- "$opts"
    #              ^^
    #}}}
end
