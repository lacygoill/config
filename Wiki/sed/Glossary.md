# c
## cycle

Application of  all commands in  a sed  script to an  input line in  the pattern
space.  There are as many cycles as there are input lines passed to the `sed(1)`
process.

##
# p
## pattern space

Temporary buffer where a single line of input is held while the `sed(1)` editing
commands are applied.

Its contents are  dynamic; they change after every statement  in the sed script.
So, a previous  command might have an  impact on the next one.   See our pitfall
about replacing `three` with `two`, and `two` with `one`.

As soon as all  the commands have been applied to the  pattern space, the latter
is written on  `sed(1)`'s standard output.  Then, the next  input line is copied
in the pattern space, and the process repeats itself.
