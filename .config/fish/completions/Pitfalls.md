# At completion time, I have 2 suggestions for the same option!  (e.g. `--option` and `--option=`)

When  defining  the   completion  for  this  option,  make  sure   to  pass  the
`--require-parameter` to the `complete` builtin.

# Why does `--arguments=$(cmd)` only produce 1 suggestion, even though `cmd` gives more?

This evaluates to the cartesian product of `--arguments=` and `$(cmd)`; i.e.:

    --arguments=suggestion1 --arguments=suggestion2 --arguments=suggestion3 ...

If you want that:

    --arguments='suggestion1 suggestion2 suggestion3 ...'

Then quote the command substitution:

    --arguments='$(cmd)'
                ^      ^

# Why doesn't `--keep-order` work?

It's because we override the Tab key with the `my-complete` function.
The latter contains:

    set -f completions $(
        printf '%s\n' $completions \
        | sort --key=1b,1 --field-separator=\t --unique \
    )

IOW, we sort manually.
