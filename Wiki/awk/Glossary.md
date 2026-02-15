# d
## dynamic regex

A regex can be computed by:

   1. evaluating an expression, converted to a string if necessary
   2. using the contents of the evaluated string

A regex computed in this way is called a dynamic regex.

In contrast, a string of characters between  slashes, used as a regex, is called
a *regex constant*.

##
# o
## matching operator

Operator performing a regex comparison:

   - `~`
   - `!~`

## relational operator

Operator performing a numeric or lexicographic comparison:

   - `==`
   - `!=`
   - `<`
   - `>`
   - `<=`
   - `>=`

## comparison operator

Relational or matching operator.

##
## output record

Output from an entire print statement.

   > The output from an entire print statement is called an output record.
   > Each print statement outputs one output record, and then outputs a string called
   > the output record separator (or ORS).
   > The initial value of ORS is the string "\n" (i.e., a newline character).
   > Thus, each print statement normally makes a separate line.

Source: A User’s Guide for GNU Awk Edition 4.2

##
# s
## statement

This can be a `pattern { action }`, or a command inside an action.
