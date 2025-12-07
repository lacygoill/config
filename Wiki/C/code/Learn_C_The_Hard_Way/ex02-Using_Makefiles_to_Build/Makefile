CFLAGS=-Wall -g
#      ^---^ ^^
#        |   produce debugging information
#      tell `cc(1)` to report all warnings

# The  first target  present  in a  makefile  is the  one  implicitly used  when
# `make(1)` is  invoked without  argument.  If  the default  target you  want to
# build is `all`, then put it near the top of the file, before any other target.
# v
all: ex01 ex03

# A target can depend on another target.{{{
#
# For example, `all` could depend on `clean`:
#
#     all: clean ...
#
# That is, when `all` is built, `clean`  is too.  That would be useful to remove
# a previously  built binary to  test changes in `ex1.c`.   Otherwise, `make(1)`
# bail out if it finds an existing `ex1` binary:
#
#     make: Nothing to be done for 'all'.
#}}}
# We don't make `all` depend on `clean` though.{{{
#
# Because that's probably not how it  works in most projects.  Instead, take the
# habit of running:
#
#     $ make clean all
#            ^-------^
#            notice that `make(1)` can build multiple targets in a single command
#}}}
clean:
	rm -f ex01 ex03
# shell command to run when `clean` is built
