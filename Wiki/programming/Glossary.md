# c
## control flow

Order  in which  individual statements,  instructions  or function  calls of  an
imperative program are executed or evaluated.

<https://en.wikipedia.org/wiki/Control_flow>

## control flow graph

Representation,  using graph  notation, of  all  paths that  might be  traversed
through a program during its execution.

<https://en.wikipedia.org/wiki/Control_flow_graph>

## control flow statement

Within  an  imperative programming  language,  a  control  flow statement  is  a
statement, the execution of which results in  a choice being made as to which of
two or more paths to follow.

Here are a few categories of control flow statements:

   - alternatives (if, if–else,  switch, ...)
   - loops (while, do–while, for, ...)
   - exception handling constructions (try–catch,  ...)

##
# e
## evaluation

Process through which a programming language:

   1. interprets an expression (according to its particular rules of precedence
      and of association)

   2. computes it

   3. from the result, produces a new value of a given type (numerical, string,
      logical - true / false, function, ...)

## expression

A combination of one or more:

   - arrays
   - constants
   - functions
   - operators
   - variables
   ...

##
# i
## idiom

A syntax which is specific to a language.

Usually, using an  idiom makes the code  less verbose.  Often, it  makes it also
easier to  read and understand.   But in  general, that's not  necessarily true;
e.g. bash provides some obscure idioms which are hard to read.

A list  comprehension is an  example of  idiom in Python;  you won't find  it in
other languages.  In  contrast, a `for` loop  is not an idiom; you  can find the
same syntax in many other languages.

##
# o
## operator associativity

Property  of an  operator  which determines  how operations  are  grouped in  an
expression containing  several operators  of equal  precedence, adjacent  to the
same operand, and without parentheses.

An operator can be:

   - associative: the operations can be grouped arbitrarily

   - left-associative: the operations must be grouped from left to right
   - right-associative: the operations must be grouped from right to left

   - non-associative: the operations cannot be chained (probably because
     the type of the result of an operation is incompatible with the type of
     expression expected by the operator)

Grouping from left  to right means that  we first group the  operands around the
leftmost  operator.  Here  is an  abstract example  where `Op`  stands for  some
operator, and `a`, `b`, `c` are operands:

    a Op b Op c

If `Op` is left-associative, the operations are grouped like this:

    (a Op b) Op c

Because the leftmost operation is the first one.

If `Op` is right-associative, the operations are grouped like this:

    a Op (b Op c)

Because the rightmost operation is the last one.

---

Real  examples of  left-associative operators  are: `*`,  `/`, `%`,  `+` (binary
version), `-` (binary version).  Consequently:

      i - j - k
    ⇔
      (i - j) - k

      i * j / k
    ⇔
      (i * j) / k

Examples of  right-associative operators  are: `+`  (unary version),  `-` (unary
version).  Consequently:

      - + i
    ⇔
      -(+i)

### Why must operators with the same precedence have the same associativity?

To prevent  cases where operands would  be associated with two  operators, or no
operator at all.

---

Suppose that `/` was right-associative, while `*` was still left-associative.
In which order should the operators in this expression be grouped?

    1 * 2 / 3

There  would be  an ambiguity.   That's  why `*`  and  `/` which  have the  same
precedence, can *not* have different associativities.

##
## binary operator

Operator associating a value to 2 operands.

As an example, `+`  is a binary arithmetic operator, and the  expression `1 + 2`
produces the number `3`.

## unary operator

Operator associating a value to 1 operand.

As an  example, `?` is a  unary regex operator,  and the regex `r?`  matches the
text `r` or an empty text.

##
# r
## REPL

read-evaluate-print-loop

##
# s
## SCM

Source Code Management.

The most well-known SCM system is probably Git.

An SCM  utility typically creates some  sort of administrative directory  at the
root of the project it manages: `.git` for Git, `.svn` for Subversion, `CVS` for
CVS, and so on.

## syntactic sugar

A construction can be considered “syntactic sugar” if, and only if:

   - it simplifies the reading/writing of another syntactic construction

   - its removal wouldn't make the language less expressive, nor would it remove
     any feature of the language

Example 1 (AWK):

    printf "fmt", expr

is probably syntactic sugar for:

    printf("fmt", expr)

Example 2 (AWK):

    my_array[1, 2]

is probably syntactic sugar for something like:

    get_array(my_array, vector(1, 2))

And similarly (AWK):

    my_array[1, 2] = 345

is probably syntactic sugar for something like:

    set_array(my_array, vector(1, 2), 345)

### desugaring

Process during  which the processors  of a language  (interpreter, preprocessor,
compiler,  ...)  expand syntactic  sugar  into  more fundamental  constructions,
before processing the code.
