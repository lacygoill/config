# How to set the cursor at an arbitrary position after the insertion of a completion?

When you write your  completion, write `⌖` wherever you want  the cursor to be
positioned.

For example, for `git(1)`:

    clone --depth=1 ⌖ && cdd
                    ^
                    cursor position

# I don't want to *complete* `cmd`.  I want to replace it with an entirely different command!

When you write your completion, write `^W` at the very beginning (it will delete
the `cmd`  word written before  the cursor).   Then, write whatever  command you
want.

This is useful in two cases:

   - in the new desired command-line, `cmd` is in an arbitrary position (not
     right before where the cursor was originally)

   - the new desired command-line does not contain `cmd`; but it's conceptually
     close (e.g. `dfc(1)` is not `df(1)`, but it serves the same purpose)

---

For example, for `sort(1)`, you could write:

    ^W xargs --delimiter='\n' stat --format='%z %n' -- | sort
    ^^                                                   ^--^

Now, if your original command-line is:

    ls | sort

It will be replaced with:

    ✔
    ls | xargs --delimiter='\n' stat --format='%z %n' -- | sort

And not with:

    ls | sort xargs --delimiter='\n' stat --format='%z %n' -- | sort
         ^--^
          ✘
