# sh -c 'CMD ... "$@" ...' CMD
## `$@` lets you specify where you want the arguments to be positioned.

See last example at `info xargs`.

## The last `CMD` is for `sh(1)` to set `$0`:

    sh -c 'CMD ... "$@" ...' CMD
                             ^^^

Without, `sh(1)` would wrongly consume the first input line passed by `xargs(1)`
for that.

This syntax is documented here:

   > -c               Read commands from the command_string operand in‐
   >                  stead of from the standard input.  Special parame‐
   >                  ter 0 will be set from the command_name operand
   >                  and the positional parameters ($1, $2, etc.)  set
   >                  from the remaining argument operands.

Source: `man dash /DESCRIPTION/;/Argument List Processing/;/-c`

It's similar to the syntax which lets you pass arguments to a script:

    $ /path/to/script a b c
                      ^ ^ ^
                      assigned to $1, $2, $3

The only difference  is that the first  argument is used to set  `$0` instead of
`$1`:

    $ sh -c 'echo $0 $1' a b
    a b

The value will be used if an error must be given from anywhere in the script:

    $ sh -c '
        printf "%s\n" "$@"
        invalid
        ' my_script_name a b
    a
    b
    my_script_name: 3: invalid: not found
    ^------------^

## Consider prepending `CMD` with `exec`.

    sh -c 'exec CMD ... "$@" ...' CMD
           ^--^

Unless it contains a syntax which needs to be parsed by a shell.

`exec` makes  sense if `CMD` is  an interactive application (e.g.  text editor).
Rationale: Once `CMD`  has been started,  `sh(1)` no longer serves  any purpose.
There is  no reason to  keep it around.   And there is  no reason to  create yet
another process to run  `CMD`; we can just re-use the one  which was created for
`sh(1)`.

## Consider prepending `$@` with `--`.

To signal to `CMD`  the end of options, which is useful if  one of the arguments
(resulting from the expansion of `"$@"`) starts with a hyphen:

    ... | xargs sh -c 'CMD ... -- "$@" ...' CMD
                               ^^

But *only* if `CMD` supports `--`.  For example, `xdg-open(1)` does not:

    $ xdg-open -- url
    xdg-open: unexpected option '--'

## Consider appending `|| exit 1` to `CMD`.

Even  though  we can  pass  multiple  arguments  to  a single  `sh(1)`  process,
`xargs(1)`  might  still need  to  start  several of  them  (*).  In that  case,
`|| exit 1` will make  `xargs(1)` stop running `sh(1)` processes as  soon as one
of them detects an error when executing `CMD`:

    sh -c 'CMD ... "$@" ... || exit 1' CMD
                            ^-------^

(*) For example, that can happen:

    $ find /usr/include -name '*.h' | xargs echo | wc -l
    3

... if  `xargs(1)` reads so  many input  files that it  exceeds the size  of the
command buffer:

                          just to prevent xargs(1) from executing /usr/bin/echo
                          v---------------v
    $ xargs --show-limits --no-run-if-empty </dev/null 2>&1 | grep buffer
    Size of command buffer we are actually using: 131072
                                                  ^----^

## Here are a few examples:

Suppose you want to archive all files  under the CWD which haven't been read for
more than a year.  You might try:

    $ find . -atime +364 -exec /usr/bin/mv ./'{}' /path/to/archive \;

But that  would only move  one file at a  time which is  inefficient.  You
can't  use `-exec command {} +`  either,  because the  latter syntax  only
allows found files to be appended at  the end of the executed command; but
for `mv(1)` (*), they must be positioned before the destination.

You  need `xargs(1)`,  but without  using `--replace`  because the  latter
implies `--max-lines=1`, which  – again – means you  would execute one
`mv(1)` command for each found file (inefficient):

    $ find . -atime +364 -print0 \
        | xargs --null sh -c 'mv "$@" /path/to/archive' mv

(*) Actually,  `mv(1)` supports a `-t`  option which lets you  specify the
destination before the  source(s).  But we ignore this  here, because it's
not a  solution to the  initial problem in the  general case (i.e.  for an
arbitrary command; not necessarily `mv(1)`).

---

    $ find ... -print0 | xargs --null bash -c 'printf "%q\n" "$@"' printf
                                      ^--^
                                      %q is only supported by bash's printf

This outputs the paths in a format that can be re-used as shell input, which can
be useful if they contain whitespace:

    # find(1)'s -print
    /path/to/file with spaces
                 ^    ^

    # bash(1)'s -printf '%q\n'
    /path/to/file\ with\ spaces
                 ^     ^

Only the  last form  can be passed  directly as an  argument to  another command
(like `ls(1)`):

    ✘
    $ ls /path/to/file with spaces

    ✔
    $ ls /path/to/file\ with\ spaces

##
# --arg-file=INPUTFILE
## Here is an example:

Grep for a pattern in files whose paths have been written in a `LISTING` file:

    $ xargs --arg-file=LISTING grep -- PAT
            ^----------------^

It's as if you had run:

    $ grep -- PAT file1 file2 ...
                  ^-------------^
                  paths stored in `LISTING`

Or:

    $ grep -- PAT $(cat <LISTING)
                    ^--^
                    can be dropped in bash

## Alternatively, you can use `<INPUTFILE`:

    $ xargs grep -- PAT <INPUTFILE
                        ^--------^

## Warning: This assumes that no file path contains a newline.

Otherwise, you  need the paths to  be written on a  single line, separated
with  NULLs, and  pass `--null`  to `xargs(1)`.   Also, there  must be  no
newline at the end of `INPUTFILE`.  If there's one:

    $ od --format=cx1 --address-radix=n INPUTFILE | sed -n '$ s/.* //p'
    0a
    ^^
    ✘

Remove it:

    $ ex -Nu NONE -i NONE -e -s -c 'setlocal binary noendofline | write | quitall!' INPUTFILE

##
# `--delimiter='\n'`

This prevents `xargs(1)` from splitting its  input on spaces (only on newlines).
Only useful if the command producing the input items can't use NULLs to separate
them.  You probably  want this if that command outputs  multiples lines, but not
if it only produces one.

Note that `--delimiter='\n'` also prevents `xargs(1)` from removing quotes:

    $ touch '/tmp/a"b"c'
                   ^^^

    $ find /tmp -name 'a"b"c' -type f -print 2>/dev/null | xargs echo
    /tmp/abc
          ^

    $ find /tmp -name 'a"b"c' -type f -print 2>/dev/null | xargs --delimiter='\n' echo
    /tmp/a"b"c
          ^^^

Finally, notice  that `xargs(1)` understands  the special escape  sequence `\n`.
No need to use  the bashism `$'\n'` (which is not portable  to other shells like
sh and fish).

# `--max-args` vs `--max-lines`

   > Trailing blanks cause an input line to be logically continued on the next
   > input line, for the purpose of counting the lines.

Source: `man xargs /OPTIONS/;/^\s*-L max-lines`

                      v      v
    $ printf '%s\n' 'a ' b 'c ' d | xargs --max-args=1 echo
    a
    b
    c
    d

    $ printf '%s\n' 'a ' b 'c ' d | xargs --max-lines=1 echo
    a b
    c d

# `--null`

`--null` is useful for file names containing newlines, but also quotes:

    $ touch '/tmp/a"b"c'
                   ^^^

    $ find /tmp -name 'a"b"c' -type f -print 2>/dev/null | xargs echo
    /tmp/abc
          ^

    $ find /tmp -name 'a"b"c' -type f -print0 2>/dev/null | xargs --null echo
    /tmp/a"b"c
          ^^^

As you can  see, without `--null`, `xargs(1)` removes quotes.   So, not only can
the  command be  executed  on the  wrong  file, `xargs(1)`  might  also give  an
unexpected error:

                   v
    $ touch '/tmp/a"b'
    $ find /tmp -name 'a"b' -type f -print 2>/dev/null | xargs echo
    xargs: unmatched double quote; by default quotes are special to xargs unless you use the -0 option
