# `$ find . -name afile -o -name bfile` finds `afile`, but not if I append `-print`!

Without any action, `find(1)` applies `-print` to the *whole* expression:

    $ mkdir /tmp/test; cd /tmp/test; touch afile bfile
    $ find . -name afile -o -name bfile
    ./afile
    ./bfile

IOW, this:

    $ find . -name afile -o -name bfile

Actually runs this:

    $ find . \( -name afile -o -name bfile \) -print
             ^^                            ^-------^

But this behavior is inhibited if you specify any action other than `-prune` and
`-quit`.  That includes `-print` itself:

                                        v----v
    $ find . -name afile -o -name bfile -print
    ./bfile

Here, `./afile` is  no longer found, because the explicit  `-print` only applies
to  `-name bfile` (contrary  to  the implicit  one which  applied  to the  whole
expression).

   > The -print action is performed on all files for which the whole expres‐
   > sion  is true, unless it contains an action other than -prune or -quit.
   > Actions which inhibit the default -print are -delete, -exec,  -execdir,
   > -ok, -okdir, -fls, -fprint, -fprintf, -ls, -print and -printf.

Source: `man find /EXPRESSION/;/Actions`

This is also  because the implicit `-a` logical  operator (between `-name bfile`
and  `-print`)  has  a  higher  precedence than  the  explicit  `-o`:

   > Please note that -a when specified implicitly (for example by two tests
   > appearing  without an explicit operator between them) or explicitly has
   > higher precedence than -o.  This means that find . -name afile -o -name
   > bfile -print will never print afile.

Source: `man find /EXPRESSION/;/OPERATORS`

So, the operations are grouped like this:

                                           can be omitted
                            vv             vv        vv
    $ find . -name afile -o \( -name bfile -a -print \)
    ./bfile

If `-o` had the same precedence than  `-a`, the operations would be grouped like
this instead:

             vv                            vv
    $ find . \( -name afile -o -name bfile \) -a -print
    ./bfile
    ./afile
    ^-----^
    this time, `afile` is found

# `$ find /lib -name '*libc*'` doesn't find anything!

`/lib` is symlinked to `/usr/lib`:

    $ ls -ld /lib
    lrwxrwxrwx ... /lib -> usr/lib/
    ^              ^--------------^

And `find(1)` doesn't follow symlinks, unless you pass it `-H` (or `-L`):

    $ find -H /lib -name '*libc*'
           ^^

#
# My command is too slow!
## Try to prune as many directories as possible.

## Make sure `-name` comes before other tests (like `-type`).

Rationale: `-name` is a less costly test:

   > The -name test comes before the -type test  in  order  to  avoid
   > having to call stat(2) on every file.

Source: `man find /EXAMPLES/;/stat(2)`

## If you use `-execdir ... +`, consider using the less secure `-exec ... +` instead.

The former might start many more processes:

    $ find /usr/include  -name '*.h' -execdir /usr/bin/echo grep --files-with-matches mode_t '{}' \+ | wc -l
    619

    $ find /usr/include  -name '*.h' -exec /usr/bin/echo grep --files-with-matches mode_t '{}' \+ | wc -l
    3

which is costly:

    $ time find /usr/include  -name '*.h' -execdir /usr/bin/grep --files-with-matches mode_t '{}' \+ >/dev/null 2>&1
    real    0m0.968s
    ...

    $ time find /usr/include  -name '*.h' -exec /usr/bin/grep --files-with-matches mode_t '{}' \+ >/dev/null 2>&1
    real    0m0.180s
    ...

This is only relevant if you terminate your command with `\+` instead of `\;`.
Otherwise, there is no performance gain in using `-exec`; you only lose in security.

## If you use an `-exec`-like action, make sure paths to binaries are absolute.

For example, compare the amount of `execve(2)` called by `-exec printf`:

    execve("/home/lgc/bin/printf", ["printf", "anything%.0s\\n", "."], 0x...) = -1 ENOENT (No such file or directory)
    execve("/home/lgc/.local/bin/printf", ["printf", "anything%.0s\\n", "."], 0x...) = -1 ENOENT (No such file or directory)
    execve("/usr/local/sbin/printf", ["printf", "anything%.0s\\n", "."], 0x...) = -1 ENOENT (No such file or directory)
    execve("/usr/sbin/printf", ["printf", "anything%.0s\\n", "."], 0x...) = -1 ENOENT (No such file or directory)
    execve("/usr/local/go/bin/printf", ["printf", "anything%.0s\\n", "."], 0x...) = -1 ENOENT (No such file or directory)
    execve("/home/lgc/.local/go/bin/printf", ["printf", "anything%.0s\\n", "."], 0x...) = -1 ENOENT (No such file or directory)
    execve("/home/lgc/.luarocks/bin/printf", ["printf", "anything%.0s\\n", "."], 0x...) = -1 ENOENT (No such file or directory)
    execve("/home/lgc/.fzf/bin/printf", ["printf", "anything%.0s\\n", "."], 0x...) = -1 ENOENT (No such file or directory)
    execve("/home/lgc/.cargo/bin/printf", ["printf", "anything%.0s\\n", "."], 0x...) = -1 ENOENT (No such file or directory)
    execve("/home/lgc/.gem/ruby/2.7.0/bin/printf", ["printf", "anything%.0s\\n", "."], 0x...) = -1 ENOENT (No such file or directory)
    execve("/usr/local/bin/printf", ["printf", "anything%.0s\\n", "."], 0x...) = -1 ENOENT (No such file or directory)
    execve("/usr/bin/printf", ["printf", "anything%.0s\\n", "."], 0x...) = 0

Versus the single `execve(2)` called by `-exec /usr/bin/printf`:

    execve("/usr/bin/printf", ["/usr/bin/printf", "anything%.0s\\n", "."], 0x...) = 0

This applies to `-exec`, `-execdir`, `-ok`, and `-okdir`.

## Try to use the comma operator to perform multiple independent tests in a single call.

           Starting-Point
           vv
    $ find SP TESTS1 ACTION1
    $ find SP TESTS2 ACTION2

    ⇔

    $ find SP TESTS1 ACTION1 , TESTS2 ACTION2
                             ^

With  the latter  syntax, `find(1)`  only  needs to  make one  scan through  the
directory tree (which is one of the most time consuming parts of its work).

The  comma  doesn't  logically connect  `TESTS1 ACTION1`  and  `TESTS2 ACTION2`.
They'll   be   evaluated  independently   (i.e.   it   doesn't  matter   whether
`TESTS1 ACTION1` is  `true` or  `false`; `TESTS2 ACTION2`  will be  evaluated no
matter what).

For more info: `man find /EXPRESSION/;/OPERATORS/;/expr1 , expr2`.

   > expr1 , expr2
   >        List;  both  expr1 and expr2 are always evaluated.  The value of
   >        expr1 is discarded; the value of the list is the value of expr2.
   >        The  comma operator can be useful for searching for several dif‐
   >        ferent types of thing, but traversing the  filesystem  hierarchy
   >        only  once.  The -fprintf action can be used to list the various
   >        matched items into several different output files.

You'll probably want  `ACTION1` and `ACTION2` to be  `-fprint`/`-fprintf` to log
the output in separate files.

## Try to increase the parallelism of the process.

If the  directory hierarchy you are  searching is spread across  separate disks,
try to make `find(1)` process each disk in parallel:

    $ find dir1 ... &
    $ find dir2 ... &
    $ find dir3 ... &
    $ wait

Here, 3  separate instances  of `find(1)`  are used to  search 3  directories in
parallel.  `wait` simply  waits  for all  of these  to  complete.  Whether  this
approach is more  or less efficient than a single  instance of `find(1)` depends
on a number of things:

   - Are the directories being searched in parallel actually on separate disks?
     If not, this parallel search might just result in a lot of disk head
     movement and so the speed might even be slower.

   - Other activity - are other programs also doing things on those disks?
