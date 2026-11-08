# study examples

    $ find /usr/share/doc/ \( -ipath '*awk*/examples/*' -o -ipath '*/examples/*awk*' \) \
        ! -path '*/data/*'  ! -name '*.csv' ! -name '*.data' ! -name '*.po' -type f -print

On my current system, those files seem interesting:

    /usr/share/doc/gawk/examples/lib/getopt.awk
    /usr/share/doc/gawk/examples/lib/inplace.awk
    /usr/share/doc/gawk/examples/lib/ord.awk
    /usr/share/doc/gawk/examples/lib/readable.awk
    /usr/share/doc/gawk/examples/lib/walkarray.awk
    /usr/share/doc/gawk/examples/prog/anagram.awk
    /usr/share/doc/gawk/examples/prog/dupword.awk
    /usr/share/doc/gawk/examples/prog/wordfreq.awk
    /usr/share/doc/lsof/examples/list_fields.awk.gz
    /usr/share/doc/mawk/examples/deps.awk
    /usr/share/doc/mawk/examples/eatc.awk
    /usr/share/doc/mawk/examples/nocomment.awk

    # to learn more about a server and a client communicate
    /usr/share/doc/gawk/examples/network/*

    # to learn how a lexical scanner works
    /usr/share/doc/mawk/examples/decl.awk
    /usr/share/doc/mawk/examples/gdecl.awk

    # to learn some well-known algorithms
    /usr/share/doc/gawk/examples/lib/quicksort.awk
    /usr/share/doc/mawk/examples/primes.awk
    /usr/share/doc/mawk/examples/qsort.awk

    # to learn C
    /usr/share/doc/gawk/examples/lib/grcat.c
    /usr/share/doc/gawk/examples/lib/pwcat.c

---

Some usage examples:

    $ gawk -f /usr/share/doc/gawk/examples/prog/anagram.awk </usr/share/dict/words
    $ lsof -F | awk -f $(gunzip --to-stdout /usr/share/doc/lsof/examples/list_fields.awk.gz | psub)

---

`dupword.awk` finds  duplicates even when they're  not on the same  line, but on
consecutive ones:

    foo bar duplicate
    duplicate baz qux

---

Some scripts might depend on a library function defined in
`/usr/share/doc/gawk/examples/lib/`.

# document how to debug

Start `gawk(1)` in debug mode with `--debug`:

                    v-----v
    /path/to/script --debug /path/to/input_file
    ^-------------^
    if the script uses mawk in its shebang, run this instead:
        gawk -f /path/to/script --debug ...

Then,  for example,  set a  breakpoint  on the  function `Func()`,  and run  the
script:

    b Func
    r

From there,  execute `n`  to execute  the next  statement, `p`  to print  one or
several expressions (`p expr ...`), and `bt` to print a backtrace.  To print all
members of an array, execute `p @array`.

Warning: If you quit with `quit`, two hidden files might be created in the CWD:

    .gawkrc
    .gawk_history

To avoid that, you can press `C-d` to quit.
Or, you can execute:

    o save_history = 0
    o save_options = 0

---

You can  also set  a breakpoint  on a given  line (useful  if your  code doesn't
define any function):

    break 123

But there must be a rule on that line.  Otherwise, an error is given:

    Can't find rule!!!
    Can't set breakpoint at `...':123

# document that `.` can match a newline in `awk(1)` (but not in `sed(1)`)

I read this in ‘Sed & Awk’, page 48 of the pdf, table 3.1.
Make sure it's true.

It's probably because awk can operate on multi-line records.

# document that a newline is also ignored after the keyword `do` (see gawk book)

# finish ‘The AWK Programming Language’

The first time we read our first awk book,  we stopped at the page 84 of the pdf
(72 in the original book).

# read: <http://www.awklang.org/>

Have a look at the links in the sidebar:

- <https://github.com/e36freak/awk-libs>
- <https://github.com/ericpruitt/wcwidth.awk> (Miscellaneous > More AWK libraries...)
...

# assimilate awk-warn.nvim plugin

<https://github.com/HiPhish/awk-ward.nvim>:221 sloc

# <https://lwn.net/Articles/820829/>

# interesting third-party projects

- plot.awk: <https://gist.github.com/katef/fb4cb6d47decd8052bd0e8d88c03a102>
- <https://github.com/patsie75/awk-graph>
- <https://github.com/patsie75/awk-videoplayer>

# code testing and its role in teaching

<https://www.cs.princeton.edu/~bwk/testing.html>

Could this be used to build our own testing framework?
