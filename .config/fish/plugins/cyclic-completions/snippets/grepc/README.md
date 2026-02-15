# `--count`

`--count` is equivalent to `| wc -l` (but more readable and efficient), *unless*
you specified multiple files:

    $ grep pat file1 file2 ... | wc -l
    123

In that case,  `--count` outputs one count  per file (instead of  just one count
for all input files as a whole):

    $ grep --count pat file1 file2 ... | wc -l
    file1:12
    file2:34
    ...

Also, `--count` only counts a line once,  even if the latter matches the pattern
multiple times (even in combination with `--only-matching`).

##
# How to include a closing square bracket inside a bracket expression?

You can't escape it (like you could in Vim):

    $ grep '[a\]b]' file
              ^^
              ✘

You must put it in first position:

    $ grep '[]ab]' file
             ^
             ✔

And if the bracket expression is negated, put it in second position:

             negation
             v
    $ grep '[^]ab]' file
              ^
              ✔
