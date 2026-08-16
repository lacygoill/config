# How to specify
## a short option (e.g. `-h`)?

    complete --command=my-cmd --short-option=h
                              ^--------------^

## a long option (e.g. `--help`)?

    complete --command=my-cmd --long-option=help
                              ^----------------^

## an old-style option (e.g. `-help`)?

    complete --command=my-cmd --old-option=help
                              ^---------------^

##
# What happens to a string assigned to `--arguments` if it contains spaces/tabs?

It will be split on whitespace at completion time to generate a list of tokens.

## What kind of syntax can I use inside such a string?

Variable expansion, command substitution and other forms of parameter expansion.

##
# What do these helper functions do?
## `__fish_use_subcommand`

It tests whether there is **any** subcommand, between the command and the cursor
position.  It succeeds if there is **n**one.

It can  be useful to  prevent a subcommand from  being suggested while  there is
already  one on  the command-line,  which  might end  up in  an invalid  command
(unless your subcommand accepts sub-subcommands).

## `__fish_seen_subcommand_from`

It tests whether  there is a subcommand **from an  arbitrary list**, between the
command and the cursor position.  It succeeds if there is **one**.

It can be useful to specify:

   - the subcommands of a command
   - the completions of a given subcommand

## `__fish_prev_arg_in`

It tests whether the previous argument is one of the supplied arguments.
Example:

    --condition='__fish_prev_arg_in foo bar baz'

This adds completions if, and only if, the previous argument is `foo`, `bar` or `baz`.
