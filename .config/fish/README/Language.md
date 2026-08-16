# Variables
## What is “variable expansion”?

The  step during  which fish  replaces `$name`  with the  value assigned  to the
variable `name`.

##
## What's the implicit scope of a variable
### which has never been defined, and is set in a block inside a function?

It's local to the function.  Not to the block:
```fish
function func
    if true
        set number 123
    end
    set --show number
end
func
```
    $number: set in local scope, unexported, with 1 elements
    $number[1]: |123|

From `man set`:

   > • If a variable is not explicitly set to be either universal, global or
   >   local  and  has never before been defined, the variable will be local
   >   to the currently executing function.

### which *has* been defined, and is set again?

It's reset in the same scope as when it was defined.

From `man set`:

   > • If a variable is not explicitly set to be either universal, global or
   >   local,  but  has been previously defined, the previous variable scope
   >   is used.

##
## How to make the shell expand the value of a variable which contains special characters (e.g. `~`, `*`, ...)?

Use the `eval(1)` command:

    $ set tilde '~'
    $ eval set tilde $tilde
    $ echo $tilde
    /home/lgc

Without `eval`, the shell would simply dereference the variable.
With `eval`, the shell dereferences the variable when **evaluating** the
arguments, then expands its value when **executing** the resulting command.

Note  that the  `eval(1)`  shell  command has  a  different  semantics than  the
`eval()` function in Vim script.  It's actually closer to `:execute`.

However, using `eval(1)` on *arbitrary* data can be a bad idea:

    $ printf 'this is an important file' >file
    $ set arbitrary '; rm file'
    $ ls file
    file

    $ eval set arbitrary $arbitrary
    $ ls file
    ls: cannot access 'file': No such file or directory

Also, in practice, it often gives confusing errors.
Use it only if you've asserted that the data doesn't contain fancy characters.

Note  that the  `eval(1)`  shell  command has  a  different  semantics than  the
`eval()` function in Vim script.  It's actually closer to `:execute`.

##
# Strings
## How are backslashes handled inside a string?

A sequence of consecutive backslashes is always halved:
```fish
echo '\\'
```
    \

In front of a non-backslash character, a backslash is always preserved:
```fish
echo '\!'
```
    \!

## Why should I never pass a parameter expansion to `printf` as its first operand?

If  the  `$param`  expands  into  several  arguments,  the  first  one  will  be
interpreted as a format, which will give unexpected results:
```fish
set param a b c
printf $param
```
    a
    ^
    ✘

Here, you would probably expect `b` and `c` to have been printed.
They were not, because `a` was parsed as  a format in which there is no `%` item
to replace.

To avoid this, always write an explicit format:
```fish
set param a b c
printf '%s' $param
```
    abc
    ^^^
     ✔

##
# Functions
## How is the `--description` option of the `function` command used?

It can be printed in a menu during a Tab completion:

    $ function my_func_A --description='here is what my_func_A does'
    $ end

    $ function my_func_B --description='here is what my_func_B does'
    $ end

    $ my_ Tab
      my_func_A  (here is what my_func_A does)  my_func_B  (here is what my_func_B does)
                  ^-------------------------^               ^-------------------------^

---

It's printed when we ask for its definition:

    $ type my_func_A
    my_func_A is a function with definition
    # Defined interactively
    function my_func_A --description='here is what my_func_A does'
                                      ^-------------------------^
    end

---

It's also printed when we ask for details:

                v-----------------v
    $ functions --details --verbose my_func_A
    stdin
    n/a
    0
    scope-shadowing
    here is what my_func_A does
    ^-------------------------^

##
# Expansions
## How can I express a list?  (3)

With a brace expansion surrounding a comma-separated list of strings:

                    v-----v
    $ printf '%s\n' {a,b,c}
    a˜
    b˜
    c˜

See: `man fish-language /PARAMETER EXPANSION/;/Brace expansion`

---

With a variable expansion:

    $ set var a b c
                    v--v
    $ printf '%s\n' $var
    a˜
    b˜
    c˜

---

With a command substitution:

                    v-----------------v
    $ printf '%s\n' $(printf 'a\nb\nc')
    a˜
    b˜
    c˜

##
## Brace Expansion
### On which condition are braces removed during an expansion?

They must surround a list.
Either an explicit comma-separated list of strings:

    $ echo {a,b}
    a b˜

Or an implicit list of items resulting from the expansion of a variable:

    $ set var a b
    $ echo {$var}
    a b˜

Otherwise, braces have no special meaning and are not removed:

    $ echo {x}
    {x}˜

###
### How to avoid repeating
#### `+` in `x+1 y+1 x+2 y+2`?

    $ echo {x,y}'+'{1,2}

#### `X` and `Y` in `XaY XbY XcY`?

    $ echo X{a,b,c}Y

#### `{` and `}` in `{a} {b} {c}`?

    $ echo {{a,b,c}}

Notice that  the inner  braces are  removed during  the expansion  of `{a,b,c}`,
because `a,b,c` is a list.  But the  outer braces are not, because `{a} {b} {c}`
is not a list.

#### `We ` in `We were born, We live, We die`

                          to suppress special meaning of comma
                          v      v
    $ echo 'We '{were born\,,live\,,die}
    We were born, We live, We die˜

##
### What happens if a list in a brace expansion contains 2 consecutive commas, or a comma right next to a brace?

It's expanded into an empty element:

    $ printf '%s\n' {a,}
    a˜
    ∅˜

    $ printf '%s\n' {,a}
    ∅˜
    a

    $ printf '%s\n' {a,,b}
    a˜
    ∅˜
    b˜

You can check that it's empty like so:
```fish
for i in {,}
    if ! set --query $i[1]
        echo 'the element is empty'
    end
end
```
    the element is empty
    the element is empty

##
## Cartesian Product
### What's that?

In set theory,  the [Cartesian product][1] of 2  sets A and B, is  the set whose
elements are all ordered pairs `(a, b)`, where `a` is in A and `b` is in `B`.

###
### How to get the cartesian product of
#### 2 lists?

Write them next to each other, without any space.

    $ echo {a,b,c}{A,B,C}
    aA bA cA aB bB cB aC bC cC˜

If you refer to them with variables, don't quote any of them:

    $ set var1 a b c
    $ set var2 A B C
    $ echo "$var1""$var2"
    a b cA B C˜
    ^---^^---^
    var1  var2

Quotes would turn  a list of possibly  several elements into a list  of a single
element.

#### a list assigned to a variable and a string?

A variable expansion can be nested inside a brace expansion:

    $ set l a b c
           v--v
    $ echo {$l}_word
    a_word b_word c_word˜

Without the braces, there would be ambiguity between a cartesian product (`$l` x
`_word`), and a simple variable expansion (`l_word`); and the latter would win:

    $ echo $l_word
    ∅˜

###
### What are these expanded into?
#### `xxx{$undefined}`

Nothing:

    $ echo xxx{$undefined}
    ∅˜

Since `$undefined` is not set, it expands into nothing.

In turn, `{$undefined}`  expands into nothing.  This is a  special case of brace
expansion: an empty list expands into nothing.

In turn, `xxx{$undefined}` expands into nothing.   This is a special case of the
cartesian product: the product  of the empty set with another  set is always the
empty  set.  Just  like the  arithmetic product  of `0`  with another  number is
always `0`.

#### `xxx{$defined_with_0_elements}`

Nothing:

    $ set defined_with_0_elements
    $ echo xxx{$defined_with_0_elements}
    ∅˜

For the same reason as `xxx{$undefined}`.

#### `xxx{$empty_string}`

`xxx`:

    $ set empty_string ''
    $ echo xxx{$empty_string}
    xxx˜

More generally, the product of an empty element with another element is the latter:

    $ echo {a,}b
    ab b˜

    $ echo {,a}b
    b ab˜

    $ echo {,}b
    b b˜

In these  outputs, every `b`  is the  result of the  product between `b`  and an
empty element.

#### `xxx$(printf '%s' '')`

Nothing:

    $ echo xxx$(printf '%s' '')
    ∅˜

`printf` prints nothing, so this is nothing times `xxx`, which is nothing.

#### `xxx$(printf '%s\n' '')`

    $ echo xxx$(printf '%s\n' '')
    xxx˜

The printf  prints a newline,  so the command  substitution expands to  an empty
string, so this is an empty element times `xxx`, which is `xxx`.

###
### How to get all the files/directories at the root of all directories in `PATH`?
```fish
for entry in $PATH/*
    echo $entry
end
```
`$PATH/*` is the cartesian product between the list variable `PATH` and the string `/*`.
It expands into:

    dir1/* dir2/* dir3/* ...

Where `dir1`, `dir2`, `dir3`, ... are the directories in `PATH`.

Then, in each  `dir123/*` token, `*` is  used as a wildcard to  expand the token
into all the files/subdirectories under `dir123/`.

Note that  if there  are no  directories in `PATH`,  the cartesian  product will
produce an empty list, which prevents the loop from running anything.

##
# bash comparison
## In fish, what's the equivalent of the bash `shift` builtin?

There are no direct equivalent.  But you can erase the undesired argument(s):

    # bash
    shift

    # fish
    set --erase argv[1]

See here for other alternatives:
<https://stackoverflow.com/questions/24093649/how-to-access-remaining-arguments-in-a-fish-script>

## What's the difference between `"$@"` in bash and `"$argv"` in fish?

In fish, the quotes suppress the splitting of the parameters:
```fish
function func; printf "%s\n" "$argv"; end; func a b
```
    a b

But not in bash:
```bash
func() { printf "%s\n" "$@" ;}; func a b
```
    a
    b

From `man bash /PARAMETERS/;/Special Parameters`:

   > When the expansion occurs within double  quotes, each parameter expands to a
   > separate word. That is, "$@" is equivalent to "$1" "$2" ...

## How do bash and fish split a command substitution?

Without quotes, bash splits on *any* whitespace:
```bash
printf '%s|' $(printf 'a b\nc')
```
    a|b|c|

fish only splits on newlines:
```fish
printf '%s|' $(printf 'a b\nc')
```
    a b|c|
     ^
     no bar = no splitting

With quotes, none of them split on any character:
```bash
printf '%s|' "$(printf 'a b\nc')"
```
    a b
    c|
```fish
printf '%s|' "$(printf 'a b\nc')"
```
    a b
    c|

##
# Conventions
## Why should I use `!` instead of `not`, `&&` instead of `and`, `||` instead of `or`?

It makes it easier to read and convert code between fish and bash.

Besides, `not` / `and` / `or` don't provide much benefit.
They do  let you drop  an explicit  continuation line if  you write them  at the
start of the line.  But even then, the result is confusing/misleading because it
looks like there are 2 commands:

    if ...
    and ...

While in reality, there is only 1 command, split on 2 lines.
An explicit continuation line makes the code less confusing.

## Why should I quote variable expansions and command substitutions only when necessary?

There are 3 possibilities:

   - you quote them all the time (assuming it doesn't cause issues)
   - you quote them most of the time, with some exceptions (for when it causes issues)
   - you quote them only when necessary

You can't quote them  all the time (we've had several real  cases where it broke
the code).

So, either you  quote them most of  the time with some exceptions,  or only when
necessary.

In the first case, the *absence* of quotes is meaningful.
In the second case, the *presence* of quotes is meaningful.

Assigning meaning to the absence of something seems like bad design.
Besides, that's what the devs seem to  usually do.  Most of the time, they don't
use quotes around variable references.

## Why should I write `>/path/to/file` instead of `> /path/to/file`?

Only the first form lets you be consistent.

Indeed, you can't  separate the redirection operator when the  next operand is a
file descriptor:
```fish
echo 'error' > &2
```
    fish: Expected a string, but found a '&'
    echo 'error' > &2
                   ^

BTW, the same is true in bash:
```fish
echo 'error' > &2
```
    bash: syntax error near unexpected token `&'

##
# Miscellaneous
## When can I drop continuation lines?

After a line ending with a pipe:
```fish
printf 'a\nb\nc\n' |
wc -l
```
    3

Inside a command substitution, right after `$(`, and right before `)`:
```fish
echo $(
    printf 'a\nb\nc\n' \
  | wc -l
)
```
    3

##
# Reference

[1]: https://en.wikipedia.org/wiki/Cartesian_product
