# What's the general syntax of `find(1)`?

    $ find [options] [starting-points] [expression]
                                    ^

Yes, you can search in several directories in a single command:

    $ find /etc ~/.vim -path '*tmp*' 2>/dev/null

## What's the syntax of an expression?

It consists of one or more "primaries", each of which is a separate command-line
argument to `find(1)`.

`find(1)` evaluates the expression each time it processes a file.  An expression
can contain any of the following types of primaries:

   - global options (*): affect overall operation rather than the processing of
     a specific primary; for clarity, it is best to place them at the beginning
     of the expression

   - positional options: affect the processing of following primaries

   - tests: return a true or false value, depending on the file's attributes
   - actions: have side effects and return a true or false value

   - operators: connect the other arguments and affect when and whether they are
     evaluated; if omitted, the implicit `-a` operator is assumed

(*) Not to be confused with the  options `-H`, `-L`, `-P`, `-D`, `-O` which must
appear before the first starting-point (and thus are outside the expression).

---

When a primary expects a numeric argument, the latter can be specified as:

   - `+n`: greater than `n`
   - `-n`: less than `n`
   - `n`: exactly `n`

##
# What's the precedence of `-o` compared to `-a`?

`-a`'s precedence is higher than `-o`'s.

So, here, you actually don't need the parentheses:

    $ find . -name dir -prune -o \( \! -name '*~' -print \)
                                 ^^                      ^^

Because the implicit  `-a` between `-name` and `-print` binds  more tightly than
`-o`:

    $ find . -name dir -prune -o \( \! -name '*~' -a -print \)
                              ^^                  ^^

Note that there is  no implicit `-a` between `\!` and `-name`.  `-a` is a binary
operator which expects tests/actions as operands; and `\!` is not a test/action;
it's a unary operator.

# What should I be aware of before using `-delete`?

The action `-delete` implies the global option `-depth`, so:

   - if you're  testing a `find(1)` command  to which you intend  to append
     `-delete` later, write  `-depth` explicitly, so  that it finds  the exact
     same  files that will be found once you append `-delete`

   - `-prune` fails to prune a directory with `-delete`

---

Write `-delete`  as late as  possible (i.e. right  after you've written  all the
tests which fully  specify the nodes that  you want to match).  If  you write it
right after the starting points, `find(1)` will delete everything below them.

---

You might also want to use `-ignore_readdir_race`: suppose that between the time
that `find(1)` reads the name of a file  from a directory, and the time it tries
to `-delete`  it, the file has  disappeared.  Then, an error  diagnostic will be
output, and the return code of `-delete` will be `false`. `-ignore_readdir_race`
lets you ignore such errors.

---

The implied `-depth` lets you delete a directory which only satisfies your tests
after its contents has been processed.  For example, suppose you have this:

    $ mkdir -p foo/bar
    $ find -mindepth 1 -type d -print
    ./foo
    ./foo/bar

Notice how `find(1)` processes `./foo/` before `./foo/bar/`.
Now, suppose you want to delete all empty directories:

    $ find -depth -mindepth 1 -type d -empty -delete
    $ tree
    .
    0 directories, 0 files

Both `./foo/`  and `./foo/bar/` were deleted,  which is what you  want.  Without
the implied `-depth`, `./foo/` would have been processed before `./foo/bar/` (as
shown earlier), and  `-empty` would have been false  (because `./foo/bar/` would
not have been deleted yet).

# What's the difference between `-executable` and `-perm /100`?

`-executable` means: "executable for the current user".
`-perm /100` means: "executable for the file's owner".

A  similar distinction  applies  to  `-readable` and  `-perm /400`,  as well  as
`-writable` and `-perm /200`.

##
# How does `find(1)` compare
## a node path to a `-[i]path` pattern?

The pattern  is matched against the  node path starting with  the starting-point
specified on  the command-line.  It is  *not* matched against the  absolute node
path.

## the timestamp of a file to the `N` integer following `-[amc]time`?

In the timestamp, the fractional part is discarded.

So, if you write `-atime +1`, and a file was last read `1.5` days ago, `find(1)`
will not output  its path (because `.5`  is discarded, and the  remaining `1` is
not bigger than the supplied `+1`).

IOW, to find files which were  last read/written/changed more than `N` days ago,
you have to write `-[amc]time +M` where `M` is `N-1`.

---

Note that similar primaries exist to compare the timestamp of processed nodes to
the last data modification of a reference file (so-called "timestamp file"):

   - `-anewer REFERENCE` (`-atime [-+]N`)
   - `-newer REFERENCE` (`-mtime [-+]N`)
   - `-cnewer REFERENCE` (`-ctime [-+]N`)

##
# How to ignore
## a given directory?

    -name PATTERN -prune -o
                  ^-------^

This construct should come before tests which specify the nodes you're looking for.

## a given file?

    \! -name PATTERN
    ^^

For example:

    $ find ~/.ssh \( -name 'id_*' -o -name 'task-*' \) \! -name '*.pub' -print
                                                       ^--------------^

##
# tests/actions
## `-[amc]min`

Similar to `-[amc]time`.  The only difference is the time unit (minutes instead of days).

Useful to find files which were changed recently (e.g. less than an hour ago):

    $ find . -cmin -60 -type f

## `-cnewer` might not mean what you think.

It does  *not* mean  that the  last status change  of the  current file  is more
recent than the one  of the reference file.  It's actually  compared to the last
data modification of the reference file:

   > -cnewer reference
   >        Time of the last status change of the current file is  more  re‐
   >        cent  than  that  of the **last data modification** of the reference
   >        file.

I guess  that's because it  better fits how people  update a timestamp  file: by
writing it.   Anyway, that  doesn't matter  if you  use `touch(1)`.   The latter
updates all three  timestamps (access, data, status), including the  time of the
last data modification.

Same deal with `-anewer` BTW.

## `-empty`

True when the file is empty and is either a regular file or a directory.
Often used with `-type d` to find empty directories.

###
## `-exec`
### Why is `-exec` less secure than `-execdir`?

Suppose you run:

    $ find /tmp -path /tmp/dir/passwd -exec /bin/rm \;

You expect `/tmp/dir/passwd` to be deleted.

Now, suppose that an attacker can create this symlink:

    $ ln -s /etc /tmp/dir

`find(1)`  would  ignore  it  (unless  you  pass  it  `-L`).   But  suppose  the
attacker can  create the symlink between  the time `find(1)` decides  to process
`/tmp/dir/passwd`  and the  time it  calls  `rm(1)`. `rm(1)`  would then  remove
`/etc/passwd`, a  vital system file,  which is  definitely not what  you wanted.
More generally, the attacker can use  such a technique to make `find(1)` operate
on a file for which *you* have enough permissions but *they* don't.

`-execdir` is  not exposed  to such  a race condition.   It changes  the working
directory to `/tmp/dir/` before calling `rm(1)`.  The latter is given `./passwd`
as  argument  instead  of  `/tmp/dir/passwd`.  Thus,  the  previously  mentioned
symlink can  no longer have  any effect (it  would not change  `rm(1)`'s working
directory).

For more info: `info '(find)Race Conditions with -exec'`.

### Where does the output of an `-exec`uted `CMD` go?

It's part of `find(1)`'s output.

This means that anything can be printed in `find(1)`'s output:

    $ find /tmp -type d -exec /usr/bin/printf 'anything%.0s\n' '{}' \+ 2>/dev/null
    anything
    ...

This  also  means that  if  you  read file  names,  those  were not  necessarily
`-print`ed:

    $ find /usr/include  -name '*.h' -exec /usr/bin/grep --files-with-matches mode_t '{}' \+
    /usr/include/xcb/render.h
    /usr/include/xcb/xproto.h
    /usr/include/xcb/xfixes.h
    ...

Here,  the file  paths are  output by  `grep(1)`; not  by an  implicit `-print`.
`-exec`, like most commands (except  `-prune` and `-quit`), inhibits an implicit
`-print`.

### `-exec[dir] CMD` must be terminated with either `\;` or `\+`.  What are the differences?

With  `\;`, `find(1)`  `fork(3)`s every  time  it finds  a file,  and the  child
process then `exec(3)`utes `CMD`.  If `CMD` can  process more than one file at a
time, this is inefficient.

`\+` builds a command  where multiple file names are appended  at the end; thus,
starts fewer processes than `\;`.

---

With `\+`, `{}`  must appear by itself (to be  replaced by `./FILENAME`).  Thus,
something like `./'{}'` or `'{}'/.git` is only valid with `\;`.

---

`\+` is always true.

Which makes  sense: when the overall  expression is evaluated for  a given file,
`find(1)` might not  `-exec`ute the command immediately (to  append more files).
But it still needs  to get a value; `true` is the  only possible choice (`false`
would prevent other tests to follow after the logical operator `-a`).

In contrast, `\;` is true if, and only if, `CMD` succeeds.

---

If any  invocation of `\+`  returns a non-zero  value as exit  status, `find(1)`
returns a non-zero exit status.

In  contrast,  with  `\;`,  `find(1)`  returns 0  regardless  of  whether  `CMD`
succeeded.

### What's more efficient: `xargs(1)` or `-exec ... \+`?

`xargs(1)`.   The latter  allows  new command-lines  to be  built  up while  the
previous command is  still executing, and lets you specify  a number of commands
to run in parallel (via `--max-procs`).

### Do I need `--` or `./` to prevent the replacement of `{}` from being wrongly interpreted as a `CMD` option?

That should not be necessary.  `{}` is replaced with an absolute path.

    $ touch -- -file
    $ find . -name '-file' -exec ls -l '{}' \;
    -rwxrw-r-- ... ./-file

Notice how no error is given by `ls(1)`.
That's because `{}` was replaced with `./-file` (not with `-file`).

### How to `-exec`ute a shell command containing a logical operator?

You can't write `&&` nor `||` because they would be interpreted by the current shell:

                  ✘
                  vv
    -execdir CMD1 && CMD2 \;
    -execdir CMD1 || CMD2 \;
                  ^^
                  ✘

You  must use  the `find(1)`-specific  logical  operators `-a`  and `-o`,  which
implies multiple `-execdir` tests:

                     can be omitted
                     vv
    -execdir CMD1 \; -a -execdir CMD2 \;
    -execdir CMD1 \; -o -execdir CMD2 \;
                     ^^
                     ✔

Note that you must terminate all `-execdir`s with `\;`, even if `CMD1` or `CMD2`
support multiple arguments.  With `\+`, the results would be meaningless (always
true).  Also,  since you can't use  `\+`, `-execdir` is guaranteed  to be better
than `-exec` no matter the command you're writing.

###
## `-maxdepth 1`

Only process nodes at the root of the starting-points.
Don't enter any subdirectory.

## `-mindepth 1`

Do not process the starting-points themselves (only their contents).

## `-nouser`

Match nodes no  longer owned by any  user (might happen if their  owner has been
removed with `deluser(8)`).

## `-path` vs `-regex`

Match nodes  whose *paths*  (!= names)  match given  shell pattern  (`-path`) or
regex (`-regex`).  The  pattern/regex must match the *whole* path,  so you might
need to surround it with `*`/`.*`.

Note that `-ipath` and `-iregex` provide case-insensitive comparisons.

## `-perm`

Must be followed  by either the octal  representation or the symbolic  form of a
file mode:

    -perm 644
    -perm u=rw,g=r,o=r
    -perm u+rw,g+r,o+r
           ^    ^   ^
           alternative syntax to equal sign

---

If the file mode is preceded by `/` or `-`:

   - the permissions are connected with resp. the logical operator OR or AND
   - more permissions are allowed

---

If you use the symbolic form, and  you specify the same permissions for multiple
entities, you can shorten it like so:

           vvv vvv
    -perm /u=s,g=s
    ⇔
    -perm /ug=s
           ^--^

But I find the longer syntax more readable.

Also, `ugo` can be further shortened into `a`.
So, these mean:

    ┌───────────────┬──────────────────────────────────────────────────────────┐
    │ -perm -a=r    │ readable by everybody (owner, *and* group, *and* others) │
    ├───────────────┼──────────────────────────────────────────────────────────┤
    │ -perm /a=w    │ writable by somebody (owner, *or* group, *or* others)    │
    ├───────────────┼──────────────────────────────────────────────────────────┤
    │ \! -perm /a=x │ not executable by anybody                                │
    └───────────────┴──────────────────────────────────────────────────────────┘

###
## `-printf`
### `%A@`, `%C@`, `%T@`

File's last access/status change/modification time  in seconds since Epoch, with
fractional part.

### `%P`

Print path relative to starting-point instead of absolute.

### `%s`

File's size in bytes.

### `\0`

Print NUL.   Useful instead of  `\n`, to  reliably handle file  names containing
weird characters (like newlines).

###
## `-user USER`

Match nodes owned by given user.

## `-xdev`

Do not descend directories on other filesystems.
Useful to prevent `find(1)` from "escaping" onto network servers.

## `--`

End of "real" options.

Note that tests and actions like `-name` and `-print` are not options.
Even options like `-mindepth 1` are not real options.

The only real options are:

   - `-H`
   - `-L`
   - `-P`
   - `-D`
   - `-O`

They must be specified before the first starting-point.

When  a  starting-point  starts  with   a  hyphen,  to  prevent  `find(1)`  from
interpreting it as a real option, you  can simply prepend it with `./`. But when
it's the  result of  a runtime  evaluation (e.g. shell  variable), then  `--` is
necessary to avoid such a pitfall:

    $ find -- $starting_point ...
           ^^
