# How to redirect in a file all the messages and errors of the processes started from the current script?

    $ exec >file 2>&1

Don't use it for the current shell.
It works, but it messes up interactive programs such as Vim.
Maybe because they expect their STDOUT to be connected to a terminal...

## How to do the same thing, but without losing the ability of printing a message or error on the terminal?

    exec 3>&1 4>&2
    exec 1>file 2>&1

Now, when you want  a command to print a message/error on  the terminal, use fd3
and/or fd4.

Example:

    cmd >&3 2>&1

It works, because before redirecting the STDOUT/STDERR of the script, we've made
duplicates of  the files to  which they  were originally connected  to.  Through
them, we can still write on the terminal.

---

Note that usually, STDIN and STDOUT are both connected to the terminal.
So, you probably don't need to duplicate fd4 from fd2.

##
# What does `3>&-` do?

It closes fd3.

`>&-` is an alternative syntax to `>/dev/null`.

# What does `4>&3` do?

It duplicates fd4 from fd3.

IOW, it opens  fd4 (if it didn't  exist) or reconnects it (if  it existed), with
write mode, to the same file to which fd3 is connected.

##
# How to redirect the output of `$ ls /tmp /foo` to `less(1)`, and the errors to `$ wc -m`?

    $ { { ls /tmp /foo | less >&3 ;} 2>&1 | wc -m ;} 3>&1

Explanation:

First naive attempt:

    $ ls /tmp /foo | less | wc -m
    ✘: the STDERR of `ls(1)` is written on the terminal
    ✘: the STDOUT of `ls(1)` is written on the STDIN of `wc(1)`

Second attempt:

    $ { ls /tmp /foo | less ;} 2>&1 | wc -m
      ^                      ^ ^--^
    ✔: the STDERR of `ls(1)` is written on the STDIN of `wc(1)`
    ✘: the STDOUT of `ls(1)` is written on the STDIN of `wc(1)`

Why the `{ ... ;} 2>&1`?

We need to redirect the errors from `ls(1)`, so we'll use `2>`.
We want to redirect them to the input of `wc(1)`.
Which fd is connected to the input of `wc(1)`? The STDOUT of `less(1)`.
So, we need to redirect the errors to the STDOUT of `less(1)`:

    $ ls /tmp /foo | less 2>&1 | wc -m
                          ^--^
                          ✘ this doesn't redirect the errors of `ls(1)`, but of `less(1)`

We need a way to refer to the STDERR of `ls(1)` from the `less(1)` command.
That's why we use `{ ... ;}`.

Note that this wouldn't work:

    $ ls /tmp /foo 2>&1 | less | wc -m
                     ^^
                     ✘ after the pipe, the STDOUT and the STDERR will be mixed,
                       you won't have any way to determine which text is an error

Third attempt:

    # ✔
    $ { { ls /tmp /foo | less >&3 ;} 2>&1 | wc -m ;} 3>&1
      ^                       ^^^                  ^ ^--^

Why `{ ... ;} 3>&1`?

Now, we need to prevent the STDOUT of `ls(1)` to be redirected from `less(1)` to
`wc(1)`.  So, we'll use  `>` in the `less(1)` command to  redirect its output to
the terminal.  But we don't have a fd for the terminal, so we create a duplicate
with `{ ... ;} 3>&1`.

# How to close the fd 3 for all commands where it's unused?

    $ { { ls /tmp /foo 3>&- | less >&3 3>&- ;} 2>&1 | wc -l 3>&- ;} 3>&1
                       ^--^            ^--^                 ^--^

# If the `less(1)` command gives an error, it will be sent to `wc(1)`.  How to send it to the terminal instead?

Duplicate  the fd  used initially  for the  errors of  the shell  (using fd  4),
because we  know it's connected to  what we need:  the terminal.  And use  it to
reconnect the errors of `less(1)` to the terminal:

    $ { { ls /tmp /foo | less >&3 2>&4 ;} 2>&1 | wc -l ;} 3>&1 4>&2
      ^                           ^-----^               ^      ^--^

##
# Pitfalls
## How to move the contents of `file1` in `file2` without breaking the hard link `$ ln file2 hardlink`?

    $ cp file1 file2

Or:

    $ cat file1 >file2 && rm file1

`cp(1)` and a  redirection will both preserve the hard  link, because they don't
create a new file if they don't need to.
They just overwrite the contents of an existing file when they can.
So the inode number is left unchanged.

Do *not* use `mv(1)`.  If `file2` is  a hard link referring to an existing file,
`mv(1)` will  break the link because  it creates a  new file `file2` with  a new
inode number.

---

In the following examples, `file2` is a hard link.
Watch what happens to it in the three following commands:

    $ echo 'hello' >file1  && \
      echo 'bye'   >file3  && \
      ln file3 file2       && \
      mv file1 file2       && \
      cat file2 file3
      hello˜
      bye˜

    # `file2` and `file3` do NOT have the same inode number anymore


    $ echo 'hello' >file1  && \
      echo 'bye'   >file3  && \
      rm file2             && \
      ln file3 file2       && \
      cp file1 file2       && \
      cat file2 file3
      hello˜
      hello˜

    $ echo 'hello' >file1           && \
      echo 'bye'   >file3           && \
      rm file2                      && \
      ln file3 file2                && \
      cat file1 >file2 && rm file1  && \
      cat file2 file3
      hello˜
      hello˜

In the last two commands, `file2` and `file3` STILL have the same inode number.
