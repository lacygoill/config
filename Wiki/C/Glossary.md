# a
## ANSI

American National Standards Institute

It's  a  private  non-profit  organization  that  oversees  the  development  of
voluntary consensus  standards for  products, services, processes,  systems, and
personnel in the United States.
The organization also coordinates U.S. standards with international standards so
that American products can be used worldwide.

These standards ensure that the  characteristics and performance of products are
consistent, that  people use the same  definitions and terms, and  that products
are tested the same way.

## ANSI C, ANSI/ISO C, ISO C

Can mean C89, C99, C11, C17 or C23.

<https://en.wikipedia.org/wiki/ANSI_C>

## automatic variable

Variable local to a function.  It comes into existence only when the function is
called and disappears when the function is exited.

##
# b
## block

Synonym for compound statement.

## bounds-checker

C doesn't  require array subscripts  to be  checked; a bounds-checker  adds this
capability.

##
# c
## C89

Version of the  C language described in the standard  ANSI X3.159-1989, in 1989,
and ISO/IEC 9899:1990, in 1990.

## C99

Version of the C language described in the standard ISO/IEC 9899:1999, in 1999.

- <https://en.wikipedia.org/wiki/C99>
- <https://gcc.gnu.org/c99status.html>

## C11

Version of the C language described in the standard ISO/IEC 9899:2011, in 2011.

- <https://en.wikipedia.org/wiki/C11_%28C_standard_revision%29>
- <https://gcc.gnu.org/wiki/C11Status>

## C17

Version of the C language described in the standard ISO/IEC 9899:2018, in 2018.

<https://en.wikipedia.org/wiki/C18_(C_standard_revision)>

The Wikipedia page  uses the term `C18`, but  on the web, and on  the latest man
page for GCC, `C17` is used more often.

## GNU C

Version of the C language used by GCC by default.

GNU C provides several language features not found in ISO standard C.

##
## Clang

C  compiler  from  the  LLVM  project which  has  gained  popularity.   It's  an
alternative to the GNU Compiler Collection, GCC.

##
## compound assignment operator

Assignment operator  of the  form `X=`,  where `X` is  a binary  operator, which
first  performs the  operation of  `X` on  both operands,  before assigning  the
result to the left operand.

For example:

    i += 3
      ^^

Here, before assigning  anything to `i`, the code performs  the `+` operation on
both operands:

    the operands around +=
    v   v
    i + 3
      ^
      the operator at the start of +=

Then, the result is assigned to `i`.

---

Other examples of compound assignment operators include:

    -=
    *=
    /=
    %=

---

Compound and simple assignment operators are similar.
They are both right-associative.
They both yield the lvalue as it is after the assignment.

## compound statement

Groups  several statements  into a  single statement  (by surrounding  them with
curly  braces).   The compound  statement  is  commonly  used in  selection  and
iteration statements, where the syntax only allows for 1 statement, but where we
might need more.

Example:
```c
    if (i > j)
    {
        // swap values of i and j
        int temp = i ;
        i = j;
        j = temp;
    }
```
##
## constant

Number that appear in the text of a program; not read, written, or computed.

    height = 8;
             ^

## controlling expression

Expression evaluated by a control flow statement.

For example, it  can be an expression  tested by a `switch`  statement to decide
where control  should jump.  Or an  expression evaluated by a  `for`, `while` or
`do` loop, to decide whether it should run its next iteration.

## conversion specification

`%x` token which can be included inside a format string passed to
`printf()`/`scanf()`, and is meant to be replaced with some value.

Once replaced, the result is written:

   - on the program stdout in the case of `printf()`
   - in a variable in the case of `scanf()`

---

The information that follows `%` *specifies* how the value is *converted*:

   - from its internal form (binary) to printed from (characters) in the case of `printf()`
   - from its inputted form (characters) to internal form (binary) in the case of `scanf()`

That's where the term "conversion specification" comes from.

For example, the  conversion specification `%d` specifies that  `printf()` is to
convert an `int` value to a string of decimal digits.

---

In `%x`,  `x` is  called conversion  specifier.  It determines  the type  of the
value which is meant to replace `%x`.

---

In the case of `printf()`, the expression can be formatted according to optional
information located between `%` and `x`:

    printf("%10.3f", x);
             ^--^
             controls how to print the float

##
# d
## dangling else

A nested `else` preceded by a simple (!= compound) statement.

It's ambiguous because you might think that  such an `else` belongs to the outer
`if`,  while  in  reality it  belongs  to  the  nested  one (especially  if  its
indentation is wrong).

The compiler can warn you against this pitfall:
```c
    #include <stdio.h>

        int
    main(void)
    {
        int i = 1, j = 2;
        if (j != 0)
            if (i != 0)
                j = i / j;
        else
            printf("Error: j is equal to 0\n");
    }
```
    error: suggest explicit braces to avoid ambiguous ‘else’ [-Werror=dangling-else]
                                                                      ^-----------^

Putting braces around the nested `if` might be necessary:
```c
    #include <stdio.h>

        int
    main(void)
    {
        int i = 1, j = 2;
        if (j != 0)
        {
            if (i != 0)
                j = i / j;
        }
     // ^
     // terminate the nested `if` early so that the subsequent `else` belongs to the
     // outer `if`
        else
            printf("Error: j is equal to 0\n");
    }
```
## (data) object

A region of data storage that can be used to hold values.

One way to identify an object is by using:

   - the name of a variable
   - an element of an array
   - a member of a structure
   - use a pointer expression that involves the address of the object
   ...

Object refers  to the  actual data  storage, but an  lvalue is  a label  used to
identify, or locate, that storage.

## directive

Statement beginning with `#`, which will be obeyed by the preprocessor.

##
# e
## EOF

An OS needs some way to tell where a file ends.  One method is to embed a Ctrl+Z
character in the file to mark its end.  Another method, used by Unix, is to keep
track of  the file size: if  a file has 3000  bytes and a program  has read 3000
bytes, the program has reached the end.

In  any case,  when the  end of  a file  is reached,  `getchar()` and  `scanf()`
returns a special value: EOF.  The latter is defined in `stdio.h`:

    #define EOF (-1)

Some systems may define  EOF to be a value other than -1,  but the definition is
always different from a return value produced by a legitimate input character.

---

When the  input is  the keyboard,  to type  the EOF  character (which  sends the
end-of-file signal), you need to press Ctrl+D at the beginning of a line.

## expression statement

Any expression turned into a statement with an appended semicolon.

The value of such an expression is discarded.
Thus, it's only useful if it has a side effect.

Examples:

    ++i;
       ^

    i = 1;
         ^

Here, `++i` and `i = 1` are both expressions, which evaluate to the new value of `i`.
They remain useful even when turned  into statements, because they have the side
effect of changing the value of `i`.

OTOH, this expression statement is useless:

    i * j - 1;
             ^

Because it has no side effect.

## external variable

An external variable:

   - is defined outside any function
   - is globally accessible
   - retain its value even after the function that sets it has returned

It  must be  defined, exactly  once, outside  of any  function; this  sets aside
storage for it.  It must also be  declared in each function that wants to access
it; this states  the type of the  variable.  The declaration can  be an explicit
`extern` statement or can be implicit from context.

You  only need  an  `extern` statement  if  the variable  is  defined *after*  a
function uses it; otherwise `extern ...` can be omitted.

##
# f
## fetch

Retrieving the value of a variable from memory to perform some computation which
refers to it.

A variable typically  lives in RAM, while  a fetched value is copied  into a CPU
register.  The two values are independent.  In particular, changing the value of
a variable has no effect on a prior copy living in a CPU register.

## float

A datatype whose name comes from "floating-point"; the latter is a technique for
storing numbers  in which the  binary point (decimal  point for a  computer) can
"float"; that is, it can be placed anywhere relative to the significant digits.
This position is given by the exponent component.

For more info: <https://en.wikipedia.org/wiki/Floating-point_arithmetic>

---

A  float value  is  stored in  2  parts:  the fraction  (aka  mantissa) and  the
exponent.  For example, 12.0 might be stored as:

           exponent
           v
    1.5 x 2³
    ^^^
    fraction

## format string

First string argument passed to `printf()` or `scanf()`.

It controls how  `printf()` formats printed text, and how  `scanf()` reads input
text.

## function prototype

Declaration of a function that declares the types of its parameters.

##
# h
## header

It contains information about some part of the standard library.

##
# i
## ISO

International Organization for Standardization

It's an international standard-setting  organization composed of representatives
from various national standards organizations.

It promotes worldwide proprietary, industrial and commercial standards.

##
## identifier

Name chosen for a variable, function, macro or another similar entity.

An identifier may contain letters, digits, and underscores.
But it cannot start with a digit.

You can make an  identifier as long as you want, but the  compiler needs only to
consider the first  63 characters as significant; better stick  to names shorter
than 63 characters.

An identifier must not match a keyword.

An identifier should not start with an underscore; those are reserved.

Since C is case-sensitive, the case of the chosen name matters.
For example, each of these names identify a different variable:

    job
    JOB
    jOb
    ...

---

Here are some examples of **legal** identifiers:

    times10
    get_next_char
    _done

Here are some examples of **illegal** identifiers:

    get-next-char
       ^    ^
       not a letter, nor a digit, nor an underscore

    10times
    ^
    a digit is allowed, but not at the start

---

In case you wonder whether it was a good or bad choice for C to be case
sensitive, read this: <https://softwareengineering.stackexchange.com/a/10010>

## implementation

The  software needed  to compile,  link, and  execute programs  on a  particular
platform.

## implementation-defined behavior

The C standard  deliberately leaves parts of the language  unspecified, with the
understanding that an implementation will fill in the details.

For example, the behavior of the `/`  and `%` operators for negative operands in
C89 is implementation-defined.

---

The C standard requires any implementation-defined behavior to be documented.

---

To  make  your code  portable  across  platforms,  you  should avoid  making  it
dependent on an  implementation-defined behavior.  If you can't,  then read your
implementation's manual to be sure to understand how your code will work.

## initializer

First value assigned to a declared variable.

    int height = 8;
                 ^
                 initializer of the variable `height`

##
## (buffered) input

Characters you  type are collected  and stored in  an area of  temporary storage
called  a buffer. Pressing  Enter  or filling  the buffer  causes  the block  of
characters you typed to be made available to your program.

The advantage over  unbuffer input is that it's less  time-consuming to transmit
several characters  as a block than  to send them  one by one.  Besides,  if you
mistype, you  can use  your keyboard  correction features  to fix  your mistake.
When you finally press Enter, you can transmit the corrected version.

Buffering comes in two varieties: **fully buffered I/O** and **line-buffered I/O**.  For
fully buffered  input, the  buffer is  **flushed** (the contents  are sent  to their
destination) when it  is full.  This kind of buffering  usually occurs with file
input.  The buffer size depends on the  system, but 512 bytes and 4096 bytes are
common values.  With line-buffered I/O, the buffer is flushed whenever a newline
character shows up.  Keyboard input is  normally line buffered, so that pressing
Enter flushes the buffer.

## (unbuffered) input

The characters you type are immediately made available to the waiting program.
If the latter echoes what you type, and you type something like "Hello", you get:

    HHeelllloo

Unbuffered input  is desirable for  some interactive  programs.  In a  game, for
instance, you would like each command to take place as soon as you press a key.

##
## integer
### signed

Integer whose  leftmost bit encodes  a sign: 0 if the  number is positive,  1 if
it's strictly negative.

### unsigned

Integer with no sign  bit (its leftmost bit is considered  part of the integer's
magnitude).

##
# k
## K&R C

Original version  of C  standardized by  the book  “The C  Programming Language”
written by Brian Kernighan and Dennis Ritchie.

##
## keyword

A token which has a special meaning in  the C language (and thus, cannot be used
as an identifier).  C only recognizes 29 keywords:

    auto
    break
    case
    char
    continue
    default
    do
    double
    else
    extern
    float
    for
    goto
    if
    int
    long
    register
    restrict
    return
    short
    sizeof
    static
    struct
    switch
    typedef
    union
    unsigned
    void
    while

---

The C90 standard adds 4 new keywords to this list:

    const
    enum
    signed
    volatile

---

The C99 standard adds 1 new keyword to this list:

    inline

---

The C11 standard adds 9 new keywords to this list:

    _Alignas
    _Alignof
    _Bool
    _Complex
    _Generic
    _Imaginary
    _Noreturn
    _Static_assert
    #_Thread_local

##
# l
## label

Identifier placed at the beginning of a statement:

    identifier: statement;
    ^--------^

A statement might have more than 1 label:

    foo: bar: statement;
    ^^^^ ^^^^

You can use a label name in a  `goto` statement to jump right below the location
of that label:

    goto foo;
         ^^^

## leak-finder

A leak-finder helps locate memory leaks.

##
## library

Archive of object files that can be  built into a program.  For example, there's
a standard math library that many  executables link against, because it provides
trigonometric functions and the like:

    $ nm --defined-only $(locate --basename 'libm-*.a') 2>/dev/null

---

There are 2 kinds of libraries: static (`.a` file extension) and dynamic (`.so`).

At compile time, the decision to link a library statically or dynamically is not
made  based on  its  given file  name (`ld(1)`'s  `-l namespec`  expects a  name
without extension and without the `lib` prefix), but on which one of `-Bdynamic`
or `-Bstatic`  was last given  before `-l namespec`.  By default,  `ld(1)` looks
for a dynamic library, then for a static one:

   > on ELF [...] systems, ld will search a directory for a library called
   > libnamespec.so before searching for one called libnamespec.a.

Source: `man ld /OPTIONS/;/-l namespec`.

### glibc

The GNU C  Library.  It's the most widely  used C library on Linux,  and the one
whose details  are documented in the  relevant pages of the  `man-pages` project
(primarily in Section 3 of the manual).

It  contains  basic functions  (e.g.  to  open  files or  network  connections),
considered to  be part  of the  C programming language.   The static  version is
`libc.a`.  But most programs use the shared version (`libc.so.6`).

---

There are other C libraries (e.g. musl libc).  See `man 7 libc`.

### shared library

Linking a program against a shared library  doesn't copy the code into the final
executable; it just adds references to symbols  in the code of the library file.
At runtime,  `ld.so(8)` will  load the  library's code  into the  process memory
space (*), but only when necessary.

Pros compared to static libraries:

   - efficient (many  processes can share the same  shared library code in
     memory)

   - convenient (you can modify the library without re-compiling any program)

Cons:

   - difficult to manage (e.g. different programs  might require conflicting
     versions of  the same shared library)

   - difficult to link against

---

(*) `ld.so(8)` looks into (in the given order):

   - the environment variable `LD_LIBRARY_PATH`

   - the executable's pre-configured runtime library search path (rpath), if it
     exists

   - `/etc/ld.so.cache`.  This is a fast cache  of the names of library files
     found in directories  listed in  `/etc/ld.so.conf`,  which in  turn
     includes files  from `/etc/ld.so.conf.d/`.

   - `/usr/lib`

If  you add/remove  a library  in one  of `ld.so.conf`'s  directories, you  must
re-build the cache:

    $ sudo ldconfig --verbose

### static library

When a program is linked against  a static library, `ld(1)` copies the necessary
machine code  from the library  file into the  executable; the latter  no longer
needs the former after that (i.e. at runtime).

Cons compared to shared libraries:

   - inefficient in terms of disk space and memory

   - inconvenient (if it needs to be updated because a security bug was found,
     all executables that had  been linked against it need to be re-compiled)

Still, static libraries are useful when you  want to install a recent version of
a program on an old system.  Such  a program might depend on some recent library
which can't be installed on the system.  For this reason, the devs might provide
pre-built statically-linked executables (even glibc can be statically linked).

##
## linker

The linker, `ld(1)`, combines the object code with any additional code needed to
yield  a complete  executable program.   This additional  code includes  library
functions (like  `printf()`) that are used  in the program, as  well as "startup
code" (interface between your program and the OS).

## (string) literal

Sequence of zero  or more multibyte characters enclosed in  double-quotes, as in
"xyz".

Also known as "character string literal".

## logical expression

Expression which  is tested by  an `if` or  `while` statement, or  a conditional
operator.  It  can be  built from relational,  equality, and  logical operators.
It's always considered true or false.

## lvalue

Label used to identify, or locate, the storage of an object in memory.

A variable name and an array subscript are lvalues.
Constants such as `123`, and expressions such as `i * 2` are not.

Most lvalues can be used on the  LHS of an assignment operator (those are called
"modifiable lvalues");  but not those defined  with `const` (they can  appear on
the LHS of an *initialization*, but not on the LHS of an *assignment*).

BTW, it's pronounced "L-value".

##
# m
## macro

A fragment of code  which has been given a name with a `#define` directive.
Whenever the name is used, the preprocessor replaces it with its contents.

There  are two  kinds of  macros.  They  differ mostly  in what  they look  like
when  they  are used.   Object-like  macros  resemble  data objects  when  used;
function-like macros resemble function calls.

Source: <https://gcc.gnu.org/onlinedocs/cpp/Macros.html>

---

Warning: Try to use macros sparingly.
They  are hard  to  debug,  can have  unexpected  side-effects,  and don't  have
namespaces.

Source: <https://stackoverflow.com/a/14041847>

## magic number

Number whose meaning is hard to understand from the context.

## memory leak

Blocks of memory that are dynamically allocated but never deallocated.

##
# n
## null statement

Special case of an expression statement, where there is no expression.

Example:

    2 assignments
    v----v   v----v
    i = 0; ; j = 1;
           ^
           1 null statement

Another (less contrived) example:

    // look for the smallest divisor d of n
    for (d = 2; d < n && n % d != 0; ++d)
      ;
      ^

##
# o
## object code

Machine instructions obtained after the compiler has translated your source code
file into an object file.  To  build a fully functioning executable program from
some object file(s) and system libraries, `cc(1)` must run `ld(1)`.

##
## operator precedence

Property  of an  operator  which determines  how operations  are  grouped in  an
expression containing several operators, and without parentheses.

For example, in this expression:

    i + j * k

The operations are grouped like this:

    i + (j * k)
        ^     ^

Not like this:

    (i + j) * k
    ^     ^

Because the `*` operator has a higher precedence than `+`.

## operators families
### conditional operator

`?:`

### equality operator

`==` and `!=`

### logical operator

`!`, `&&`, and `||`

### relational operator

`<`, `<=`, `>`, and `>=`

##
# p
## pointer

   - the value of a  pointer is the address of the first byte  of the object to
     which it points

   - applying the `*` operator to a pointer yields the value stored in the
     pointed-to object

   - adding 1 to a pointer increases its value by the size, in bytes, of the
     pointed-to type (e.g. for a `double`, `+ 1` increases the pointer by 8)

Declaring a pointer is not enough.
There are 2 reasons for which you also need to declare its type:

   - to be able to retrieve the next element of an array
   - for `*pointer` to correctly fetch the value

In both cases, C needs to know the size of the pointed-to object.

---

You can use pointer notation with arrays:

    *(array + N) = array[N + 1];

The reverse is also true; you can  use array notation with pointers.  This turns
out to be important when you have a function with an array as an argument:
```c
 #include <stdio.h>
void func(int *);

    int
main(void)
{
    int array[3] = {1, 2, 3};
    func(array);
    return 0;
}
    void
func(int * array)
{
    printf("%d\n", array[0]);
//                 ^------^
//                 array is a pointer, but we can still use array notation with it
}
```
    1

## preprocessor

The preprocessor obeys the directives found in a source code file.
It's  a bit  like an  editor; it  can add  things to  the source  code and  make
modifications.

## prototype

A prototype declares  to the compiler that you are  using a particular function.
It also specifies properties  of the function, such as its  return type, and its
parameters as well as their types.

Thanks to the prototype, when the  compiler reaches the point where the function
is called, it can check to see whether it's used correctly.

##
# r
## remainder

Result of a `%` operation.

For example, `3` is the remainder of `7 % 4`.

## round-off errors

```c
/* floaterr.c--demonstrates round-off error */
 #include <stdio.h>
int main(void)
{
    float a;
    a = 2.0e20f + 1.0f;
    printf("%f\n", a);
    return 0;
}
```
    200000004008175468544.000000

The reason for this odd result is that the computer doesn't keep track of enough
decimal places to  do the operation correctly.  The number  2.0e20 is 2 followed
by 20 zeros  and, by adding 1, you  are trying to change the 21st  digit.  To do
this correctly, the program would need to be able to store a 21-digit number.  A
float number is typically  just six or seven digits scaled  to bigger or smaller
numbers with an exponent.  The attempt is doomed. On the other hand, if you used
2.0e4 instead of 2.0e20, you would get the correct answer because you are trying
to change the fifth digit, and float numbers are precise enough for that.

## round toward 0

For an inexact division whose result is positive: round down (`floor()`).
For an inexact division whose result is negative: round up (`ceil()`).

## round toward -∞

Round down.

##
## rvalue

The value of an expression which can appear on the RHS of an assignment.  It can
be a variable, a constant, or a more complex expression.

##
# s
## scope

Region of program text within which an identifier can be referenced.

There are four kinds of scopes:

   - block
   - function
   - function prototype
   - file

For  the same  identifier to  designate different  entities, it  must either  be
written  in different  scopes (e.g.  block vs  function), or  in different  name
spaces (e.g. 2 different files).

The scope of an identifier is determined by the placement of its declaration.
Except  a label  name, which  always has  function scope,  no matter  where it's
declared.

## segmentation fault

This means that the program attempted to access memory not allocated to it.

## selection statement

A statement which selects a code path out of several possibilities, like `if` or
`switch`.

## sequence point

Some location in the code where it is guaranteed that at runtime:

   - all side effects of some previous evaluations will have been performed
   - no side effects from some subsequent evaluations will have yet been performed

---

Adding more sequence  points is sometimes necessary to make  an expression valid
and  predictable  (by enforcing  a  single  valid  order  of evaluation  of  its
subexpressions).

The absence  of any  sequence point  between 2  subexpressions which  share some
state (i.e. whose values both depend on the same object), and whose execution of
evaluations can overlap, might cause a UB.

For example:

    (a = 123) + (b = a)

Here, there is no sequence point  between `(a = 123)` and `(b = a)`, which means
it's possible for `(b = a)`  to be evaluated in the middle  of the evaluation of
`(a = 123)`.  That is, in the middle of the process writing the bits of `123` in `a`:

    123 in binary
    v-----v
    1111011
       ^--^

Only the last  4 bits `1011` might  have been assigned to `a`  when `(b = a)` is
evaluated.   If that  happens, `b`  will be  assigned `00001011`  (decimal `11`)
instead  of `11111011`  (decimal `123`).   In effect,  `b` might  be assigned  a
meaningless value.

---

There are various kinds of sequence points.

The `;` terminating an expression statement  is one of them.  Before a statement
can be executed, the previous one must have been fully executed.  In particular,
all its increments and decrements must have been performed.

The end of  any full expression is  a sequence point.  A full  expression is one
that's not a subexpression of a larger expression.

The logical  `&&` / `||`, the  ternary conditional `?:`, and  the comma operator
also impose a sequence point.

So do function calls: a function body  is not entered until all the arguments in
the call have been fully evaluated.
Although,  there is  no requirement  on  the order  in which  the arguments  are
evaluated.  For example, in `f(a, b)`, `b`  might be evaluated before, after, or
at the same time as `a`.
Similarly, there is no requirement between several function calls.
For example:

    f(i++) + g(j++)

We have the guarantee that:

   - `i` is incremented before `f()`'s body is entered
   - `j` is incremented before `g()`'s body is entered

But there is *no* guarantee that:

   - `i` is incremented before `j`
   - `i` is incremented before `g()`'s body is entered
   - `f()` returns before `g()`'s body is entered

## spaghetti code

Code which gets too difficult to  read/maintain because of an excessive usage of
`goto`s.  Its control flow can be compared with a bowl of spaghetti: twisted and
tangled.

## standard I/O package

It creates a standard model and a standard set of I/O functions for dealing with
files.   At  this higher  level,  differences  between  systems are  handled  by
specific C implementations so that you deal with a uniform interface.

What sort of differences are we talking about?:

   - some systems store  the  file  contents  in one  place  and information
     about the file elsewhere; others build a description of the file into the
     file itself

   - some  systems use  a single  newline character to mark  the end of a  line;
     others might use the  combination of the carriage return  and linefeed
     characters

   - some systems measure file sizes to the nearest byte; others in blocks of
     bytes

When you use the standard I/O  package, you are shielded from these differences.
Therefore, to check for a newline, you can use:

    if  (ch  == '\n')

If  the  system actually  uses  the  carriage return/linefeed  combination,  the
I/O  functions   automatically  translate  back   and  forth  between   the  two
representations.

---

`getchar()`,  `putchar()`, `printf()`,  and  `scanf()` are  all  members of  the
standard I/O package, and they deal with the `stdin`/`stdout` streams.

## stdin / stdout (streams)

A stream  is an idealized flow  of data to which  the actual input or  output is
mapped.  Conceptually, a C program deals  with a stream instead of directly with
a file.

That means various  kinds of input with differing properties  are represented by
streams  with more  uniform  properties.  The  process of  opening  a file  then
becomes one of associating a stream with  the file, and reading and writing take
place via the stream.

C treats input and output devices the same as it treats regular files on storage
devices.  In particular, the keyboard and the screen are treated as files opened
automatically by  every C program.   Keyboard input  is represented by  a stream
called  `stdin`, and  output to  the screen  is represented  by a  stream called
`stdout`.

One  implication of  all this  is  that you  can  use the  same techniques  with
keyboard input  as you  do with files.   For example, a  program reading  a file
needs  a way  to detect  the end  of the  file so  that it  knows where  to stop
reading.  Therefore, C input functions come equipped with a builtin, end-of-file
detector.  Because keyboard input is treated like  a file, you should be able to
use that end-of-file detector to terminate keyboard input, too.

---

`stdin` can be redirected to a file via `<file` (associates `file` with `stdin` stream).
`stdout` can be redirected to a file via `>file` (associates `file` with `stdout` stream).

## subnormal (underflow)

A float number is stored as an exponent  and a mantissa.  There is a number that
has the  smallest possible exponent  and also  the smallest mantissa  that still
uses all  the bits available  to represent the  mantissa.  This is  the smallest
number that  still is  represented to  the full precision  available to  a float
value.

Now  divide it  by 2.   Normally, this  reduces the  exponent, but  the exponent
already is as small as it can get.   So, instead, the computer moves the bits in
the mantissa over, vacating the first position and losing the last binary digit.

An analogy would be taking a base 10 value with four significant digits, such as
0.1234E-10, dividing  by 10,  and getting  0.0123E-10.  You  get an  answer, but
you've lost a digit in the process.  This situation is called **underflow**, and
C refers to floating-point values that have  lost the full precision of the type
as subnormal.

##
# t
## token

A group of characters that can't be split up without changing their meaning.

Tokens can be:

   - identifiers
   - keywords
   - operators
   - punctuation marks (like commas and semicolons)
   - string literals

As an example, this statement:

    printf("Height: %d\n", height);

can be split into these 7 tokens:

   1. `printf`
   2. `(`
   3. `"Height: %d\n"`
   4. `,`
   5. `height`
   6. `)`
   7. `;`

`1.` and `5.` are identifiers.
`2.`, `4.`, `6.` and `7.` are punctuation marks.
`3.` is a string literal.

##
# u
## undefined behavior (aka UB)

According to the C standard, some statements such as:

    a = b / 0;
    c = (b = a + 2) - (a = 1);
    j = i * i++

cause  **undefined  behavior**.  If  the  code  of  a  program contains  such  a
statement, all bets are off; the program might:

   - not compile at all
   - compile, but not run
   - compile, run, but crash or behave unexpectedly

And for a particular  UB, there is not even any  guarantee of consistency across
compilers.  For example, a statement causing UB might:

   - not compile with a compiler A
   - compile, but not run with a compiler B
   - compile, run, but crash or behave unexpectedly with a compiler C

That's why you should avoid writing a statement causing UB.

---

UB is not the same thing as implementation-defined behavior.

With UB, anything can happen.
With an implementation-defined behavior, the implementation has to document what
should happen.  Obviously it should also  respect its own documentation; i.e. if
it  *says* "A"  should  happen,  then, *in  practice*,  "A"  should happen;  not
something else.

## uninitialized

This is said of a variable which has been declared, but not yet assigned any value.
